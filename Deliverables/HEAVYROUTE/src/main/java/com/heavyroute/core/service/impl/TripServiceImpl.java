package com.heavyroute.core.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.repository.RouteRepository;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.core.mapper.TripMapper;
import com.heavyroute.core.service.ExternalMapService;
import com.heavyroute.core.service.TripService;
import com.heavyroute.notification.enums.NotificationType;
import com.heavyroute.notification.service.NotificationService;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.repository.DriverRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Implementazione concreta della logica di business per la gestione dei viaggi (Trip).
 * <p>
 * Questa classe gestisce l'intero ciclo di vita di un viaggio:
 * <ul>
 * <li>Creazione da una richiesta di trasporto approvata.</li>
 * <li>Pianificazione e assegnazione delle risorse (Autista e Veicolo).</li>
 * <li>Calcolo delle rotte tramite servizi esterni.</li>
 * <li>Gestione degli stati operativi e aggiornamenti dall'app mobile.</li>
 * <li>Rilascio delle risorse al completamento del viaggio.</li>
 * </ul>
 * </p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TripServiceImpl implements TripService {

    private final TripRepository tripRepository;
    private final TransportRequestRepository requestRepository;
    private final DriverRepository driverRepository;
    private final VehicleRepository vehicleRepository;
    private final RouteRepository routeRepository;
    private final TripMapper tripMapper;
    private final NotificationService notificationService;
    private final ExternalMapService externalMapService;

    /**
     * Approva una richiesta di trasporto e genera il relativo viaggio.
     * <p>
     * Verifica l'idempotenza (se il viaggio esiste già, lo restituisce).
     * Calcola la rotta ottimale tramite il servizio cartografico e salva il nuovo viaggio
     * in stato {@code WAITING_VALIDATION}.
     * </p>
     *
     * @param requestId ID della {@link TransportRequest} da approvare.
     * @return {@link TripResponseDTO} contenente i dettagli del viaggio creato.
     * @throws ResourceNotFoundException se la richiesta non viene trovata.
     */
    @Override
    @Transactional
    public TripResponseDTO approveRequest(Long requestId) {
        // 1. CHECK IDEMPOTENZA
        Optional<Trip> existingTrip = tripRepository.findByRequestId(requestId);
        if (existingTrip.isPresent()) {
            log.info("✅ Viaggio già esistente per Request ID {}. Restituisco esistente.", requestId);
            return mapToDTOWithDriverInfo(existingTrip.get());
        }

        TransportRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Richiesta non trovata con ID: " + requestId));

        log.info("📡 Creazione nuovo viaggio per Richiesta #{}", requestId);

        // 2. Calcolo Rotta
        Route realRoute = externalMapService.calculateFullRoute(
                request.getOriginAddress(),
                request.getDestinationAddress()
        );

        // 3. Creazione Entità Trip
        Trip trip = new Trip();
        trip.setRequest(request);

        // Associazione bidirezionale
        trip.setRoute(realRoute);
        realRoute.setTrip(trip);

        trip.setStatus(TripStatus.IN_PLANNING);
        trip.getRequest().setRequestStatus(RequestStatus.APPROVED);
        trip.setTripCode("T-" + LocalDateTime.now().getYear() + "-" + String.format("%04d", requestId));

        // 4. Salvataggio a cascata (Trip -> Route)
        routeRepository.save(realRoute);
        Trip savedTrip = tripRepository.save(trip);

        log.info("✅ Viaggio creato: {}", savedTrip.getTripCode());
        return mapToDTOWithDriverInfo(savedTrip);
    }

    /**
     * Pianifica un viaggio assegnando le risorse necessarie (Autista e Veicolo).
     * <p>
     * Esegue controlli di validità sullo stato del viaggio, sulla disponibilità dell'autista
     * e sulla capacità di carico del veicolo. Gestisce inoltre il rilascio di risorse
     * precedentemente assegnate in caso di ri-pianificazione.
     * </p>
     *
     * @param tripId ID del viaggio da pianificare.
     * @param dto DTO contenente gli ID delle risorse da assegnare.
     * @throws ResourceNotFoundException se il viaggio o le risorse non vengono trovate.
     * @throws BusinessRuleException se lo stato del viaggio non è valido, se le risorse sono occupate o se la capacità del veicolo è insufficiente.
     */
    @Override
    @Transactional
    public void planTrip(Long tripId, TripAssignmentDTO dto) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        if (trip.getStatus() != TripStatus.IN_PLANNING &&
                trip.getStatus() != TripStatus.WAITING_VALIDATION &&
                trip.getStatus() != TripStatus.CONFIRMED) {

            throw new BusinessRuleException("Stato non valido per pianificazione: " + trip.getStatus());
        }

        // 2. GESTIONE RISORSE PRECEDENTI
        if (trip.getDriver() != null) {
            log.info("✅ Rilascio autista precedente: {}", trip.getDriver().getUsername());
            trip.getDriver().setDriverStatus(DriverStatus.FREE);
            driverRepository.save(trip.getDriver());
        }
        if (trip.getVehicle() != null) {
            log.info("✅ Rilascio veicolo precedente: {}", trip.getVehicle().getLicensePlate());
            trip.getVehicle().setStatus(VehicleStatus.AVAILABLE);
            vehicleRepository.save(trip.getVehicle());
        }

        // 3. RECUPERO E VALIDAZIONE NUOVE RISORSE
        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new ResourceNotFoundException("Autista non trovato"));

        if (driver.getDriverStatus() != DriverStatus.FREE) {
            throw new BusinessRuleException("L'autista " + driver.getLastName() + " è occupato.");
        }

        Vehicle vehicle = vehicleRepository.findByLicensePlate(dto.getVehiclePlate())
                .orElseThrow(() -> new ResourceNotFoundException("Veicolo non trovato"));

        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new BusinessRuleException("Il veicolo " + vehicle.getLicensePlate() + " non è disponibile.");
        }

        // Check Capacità di Carico
        Double pesoRichiesto = trip.getRequest().getLoad().getWeightKg();
        if (vehicle.getMaxLoadCapacity() < pesoRichiesto) {
            throw new BusinessRuleException("Portata veicolo insufficiente (" + vehicle.getMaxLoadCapacity() + "kg < " + pesoRichiesto + "kg)");
        }

        // 4. ASSEGNAZIONE
        trip.setDriver(driver);
        trip.setVehicle(vehicle);
        trip.setStatus(TripStatus.WAITING_VALIDATION); // Torna in validazione dopo cambio risorse

        // Blocca le risorse
        driver.setDriverStatus(DriverStatus.ASSIGNED);
        vehicle.setStatus(VehicleStatus.IN_USE);

        if (trip.getRequest().getRequestStatus() == RequestStatus.PENDING) {
            trip.getRequest().setRequestStatus(RequestStatus.APPROVED);
            requestRepository.save(trip.getRequest());
        }

        // Persistenza
        driverRepository.save(driver);
        vehicleRepository.save(vehicle);
        tripRepository.save(trip);

        log.info("✅ Risorse assegnate al viaggio {}: Autista {}, Veicolo {}", tripId, driver.getLastName(), vehicle.getLicensePlate());

        // 5. NOTIFICA
        notificationService.send(
                driver.getId(),
                "Nuovo Incarico",
                "Assegnato viaggio " + trip.getTripCode() + " per " + trip.getRequest().getDestinationAddress(),
                NotificationType.ASSIGNMENT,
                trip.getId()
        );
    }

    /**
     * Ricalcola la rotta per un viaggio esistente.
     * <p>
     * Utile in caso di modifiche agli indirizzi o aggiornamenti del percorso.
     * </p>
     *
     * @param tripId ID del viaggio.
     * @throws ResourceNotFoundException se il viaggio non viene trovato.
     */
    @Override
    @Transactional
    public void calculateRoute(Long tripId) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        Route newRoute = externalMapService.calculateFullRoute(
                trip.getRequest().getOriginAddress(),
                trip.getRequest().getDestinationAddress()
        );
        newRoute.setTrip(trip);

        trip.setRoute(newRoute);
        routeRepository.save(newRoute);
        tripRepository.save(trip);
    }

    // --- METODI DI LETTURA ---

    /**
     * Recupera un viaggio tramite ID.
     *
     * @param id ID del viaggio.
     * @return DTO del viaggio.
     */
    @Override
    @Transactional(readOnly = true)
    public TripResponseDTO getTripById(Long id) {
        Trip trip = tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + id));
        return mapToDTOWithDriverInfo(trip);
    }

    /**
     * Recupera la lista dei viaggi filtrata per stato.
     *
     * @param status Stato dei viaggi da recuperare.
     * @return Lista di DTO.
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByStatus(TripStatus status) {
        return tripRepository.findByStatus(status).stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByStatuses(List<TripStatus> statuses) {
        return tripRepository.findByStatusIn(statuses).stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    /**
     * Recupera tutti i viaggi presenti nel sistema.
     *
     * @return Lista completa di DTO.
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getAllTrips() {
        return tripRepository.findAll().stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    /**
     * Recupera i viaggi assegnati a uno specifico autista.
     * <p>
     * Utilizzato dalla dashboard mobile dell'autista per visualizzare le proprie assegnazioni.
     * </p>
     *
     * @param driverId ID dell'autista.
     * @return Lista di viaggi ordinati per data di creazione decrescente.
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByDriver(Long driverId) {
        return tripRepository.findByDriverIdOrderByCreatedAtDesc(driverId)
                .stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    /**
     * Aggiorna lo stato operativo di un viaggio.
     * <p>
     * Questo metodo include una logica di sanitizzazione dell'input per gestire stringhe "sporche"
     * (es. con virgolette o spazi) provenienti da client esterni.
     * Gestisce inoltre il rilascio automatico delle risorse (Autista = FREE, Veicolo = AVAILABLE)
     * quando lo stato diventa {@code COMPLETED}.
     * </p>
     *
     * @param tripId ID del viaggio da aggiornare.
     * @param newStatus Nuovo stato sotto forma di stringa (corrispondente a {@link TripStatus}).
     * @throws ResourceNotFoundException se il viaggio non esiste.
     * @throws BusinessRuleException se la stringa di stato non è valida.
     */
    @Override
    @Transactional
    public void updateStatus(Long tripId, String newStatus) {
        log.info("🔍 DEBUG UPDATE - ID: {}, Raw Input: [{}]", tripId, newStatus);

        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato"));

        try {
            if (newStatus == null) throw new IllegalArgumentException("Stato nullo");

            String cleanStatus = newStatus.replaceAll("[^A-Z_]", "");
            if (cleanStatus.equals("ASSIGNED")) cleanStatus = "ACCEPTED";

            TripStatus statusEnum = TripStatus.valueOf(cleanStatus);
            trip.setStatus(statusEnum); // Aggiorna il Viaggio (per Autista e Coordinator)

            // 2. SINCRONIZZAZIONE STATO CLIENTE (RequestStatus)
            switch (statusEnum) {
                case IN_TRANSIT:
                case DELIVERING:
                case PAUSED:
                    trip.getRequest().setRequestStatus(RequestStatus.IN_PROGRESS);
                    break;

                case COMPLETED:
                    trip.getRequest().setRequestStatus(RequestStatus.COMPLETED);
                    _releaseResources(trip); // Metodo helper per liberare autista/veicolo
                    break;

                case CANCELLED:
                    trip.getRequest().setRequestStatus(RequestStatus.CANCELLED);
                    _releaseResources(trip);
                    break;

                default:
                    break;
            }

            requestRepository.save(trip.getRequest());
            tripRepository.save(trip);

            log.info("✅ Stato aggiornato: Trip={}, Request={}", statusEnum, trip.getRequest().getRequestStatus());

        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException("Stato non valido: '" + newStatus + "'");
        }
    }

    private void _releaseResources(Trip trip) {
        if (trip.getDriver() != null) {
            trip.getDriver().setDriverStatus(DriverStatus.FREE);
            driverRepository.save(trip.getDriver());
        }
        if (trip.getVehicle() != null) {
            trip.getVehicle().setStatus(VehicleStatus.AVAILABLE);
            vehicleRepository.save(trip.getVehicle());
        }
    }

    /**
     * Gestisce la validazione della rotta da parte del Traffic Coordinator.
     *
     * @param tripId ID del viaggio.
     * @param isApproved true se la rotta è approvata, false altrimenti.
     * @param feedback Messaggio opzionale di feedback (in caso di rifiuto).
     * @throws ResourceNotFoundException se il viaggio non esiste.
     */
    @Override
    @Transactional
    public void validateRoute(Long tripId, boolean isApproved, String feedback) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato"));

        if (isApproved) {
            trip.setStatus(TripStatus.CONFIRMED);
            trip.getRequest().setRequestStatus(RequestStatus.PLANNED);
            log.info("✅ Rotta approvata. Trip CONFIRMED, Request PLANNED.");
            requestRepository.save(trip.getRequest());
            tripRepository.save(trip);
        } else {
            log.info("❌ Rotta rifiutata: {}", feedback);
            // In un sistema reale, qui invieremmo una notifica al Planner
        }
    }

    // --- MAPPER HELPER ---

    /**
     * Metodo di utilità per convertire un'entità Trip in DTO.
     * <p>
     * Arricchisce il DTO base con informazioni aggiuntive su Autista, Veicolo e Rotta
     * se presenti e associate al viaggio.
     * </p>
     *
     * @param trip Entità Trip da convertire.
     * @return DTO completo pronto per la risposta API.
     */
    private TripResponseDTO mapToDTOWithDriverInfo(Trip trip) {
        TripResponseDTO tripDTO = tripMapper.toDTO(trip);

        // Arricchimento dati Autista
        if (trip.getDriver() != null) {
            tripDTO.setDriverId(trip.getDriver().getId());
            tripDTO.setDriverName(trip.getDriver().getFirstName());
            tripDTO.setDriverSurname(trip.getDriver().getLastName());
        }

        // Arricchimento dati Veicolo
        if (trip.getVehicle() != null) {
            tripDTO.setVehiclePlate(trip.getVehicle().getLicensePlate());
            tripDTO.setVehicleModel(trip.getVehicle().getModel());
        }

        // Arricchimento dati Rotta
        if (trip.getRoute() != null) {
            Route r = trip.getRoute();
            com.heavyroute.core.dto.RouteResponseDTO routeDTO = new com.heavyroute.core.dto.RouteResponseDTO();
            routeDTO.setId(r.getId());
            routeDTO.setRouteDescription(r.getDescription());
            routeDTO.setDistance(r.getRouteDistance());
            routeDTO.setDuration(r.getRouteDuration());
            routeDTO.setPolyline(r.getPolyline());

            if (r.getStartLocation() != null) {
                routeDTO.setStartLat(r.getStartLocation().getLatitude());
                routeDTO.setStartLon(r.getStartLocation().getLongitude());
            }
            if (r.getEndLocation() != null) {
                routeDTO.setEndLat(r.getEndLocation().getLatitude());
                routeDTO.setEndLon(r.getEndLocation().getLongitude());
            }
            tripDTO.setRoute(routeDTO);
        }

        return tripDTO;
    }
}