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
 * Implementazione concreta della logica di business per i viaggi.
 * <p>
 * Questa classe agisce come "Operational Core" del sistema, gestendo:
 * <ul>
 * <li>La creazione del Viaggio (Trip) a partire da una Richiesta (TransportRequest).</li>
 * <li>Il calcolo e la persistenza della Rotta geografica (Route).</li>
 * <li>L'assegnazione delle risorse (Autista e Veicolo).</li>
 * <li>Le transizioni di stato guidate da Planner, Coordinator e Driver.</li>
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
    private final RouteRepository routeRepository; // Aggiunto per gestire la persistenza della rotta
    private final TripMapper tripMapper;
    private final NotificationService notificationService;
    private final ExternalMapService externalMapService;

    /**
     * {@inheritDoc}
     * <p>
     * <b>Logica di Creazione:</b>
     * <ol>
     * <li>Recupera la richiesta di trasporto.</li>
     * <li>Invoca il servizio cartografico esterno per calcolare la rotta reale (distanza, durata, polilinea).</li>
     * <li>Salva la rotta nel database (`RouteRepository`).</li>
     * <li>Crea il nuovo Trip associandolo alla richiesta e alla rotta appena create.</li>
     * </ol>
     * Lo stato iniziale è {@code WAITING_VALIDATION}.
     * </p>
     */
    @Override
    @Transactional
    public TripResponseDTO approveRequest(Long requestId) {
        // 1. CHECK IDEMPOTENZA
        Optional<Trip> existingTrip = tripRepository.findByRequestId(requestId);
        if (existingTrip.isPresent()) {
            log.info("Viaggio già esistente per Request ID {}. Restituisco esistente.", requestId);
            return mapToDTOWithDriverInfo(existingTrip.get());
        }

        // --- SE NON ESISTE, PROCEDI CON LA CREAZIONE ---

        TransportRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Richiesta non trovata con ID: " + requestId));

        // Calcolo della rotta reale tramite servizio esterno
        Route realRoute = externalMapService.calculateFullRoute(
                request.getOriginAddress(),
                request.getDestinationAddress()
        );

        // Persistenza della rotta
        routeRepository.save(realRoute);

        // Creazione del Viaggio
        Trip trip = new Trip();
        trip.setRequest(request);
        trip.setRoute(realRoute);
        trip.setStatus(TripStatus.WAITING_VALIDATION);
        trip.setTripCode("T-" + LocalDateTime.now().getYear() + "-" + String.format("%04d", requestId));

        Trip savedTrip = tripRepository.save(trip);

        return mapToDTOWithDriverInfo(savedTrip);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Assegna autista e veicolo a un viaggio, eseguendo validazioni "Fail Fast".
     * Verifica la disponibilità delle risorse e la congruenza del carico.
     * </p>
     */
    @Override
    @Transactional
    public void planTrip(Long tripId, TripAssignmentDTO dto) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        // Validazione Stato
        if (trip.getStatus() != TripStatus.IN_PLANNING) {
            throw new BusinessRuleException("Il viaggio non è in fase di pianificazione. Stato attuale: " + trip.getStatus());
        }

        // Recupero e Validazione Autista
        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new ResourceNotFoundException("Autista non trovato"));
        if (driver.getDriverStatus() != DriverStatus.FREE) {
            throw new BusinessRuleException("L'autista selezionato non è disponibile (Stato: " + driver.getDriverStatus() + ")");
        }

        // Recupero e Validazione Veicolo
        Vehicle vehicle = vehicleRepository.findByLicensePlate(dto.getVehiclePlate())
                .orElseThrow(() -> new ResourceNotFoundException("Veicolo non trovato"));
        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new BusinessRuleException("Il veicolo selezionato non è disponibile (Stato: " + vehicle.getStatus() + ")");
        }

        // Controllo Capacità di Carico
        Double pesoRichiesto = trip.getRequest().getLoad().getWeightKg();
        if (vehicle.getMaxLoadCapacity() < pesoRichiesto) {
            throw new BusinessRuleException(String.format(
                    "Portata veicolo insufficiente (%s kg) per il carico richiesto (%s kg)",
                    vehicle.getMaxLoadCapacity(), pesoRichiesto));
        }

        // Aggiornamento Relazioni
        trip.setDriver(driver);
        trip.setVehicle(vehicle);

        // Aggiornamento Stati
        driver.setDriverStatus(DriverStatus.ASSIGNED);
        vehicle.setStatus(VehicleStatus.IN_USE);
        trip.setStatus(TripStatus.CONFIRMED); // Pronto per la partenza

        // Salvataggio
        driverRepository.save(driver);
        vehicleRepository.save(vehicle);
        tripRepository.save(trip);

        // Notifica
        notificationService.send(
                driver.getId(),
                "Nuovo Incarico Assegnato",
                "Ti è stato assegnato il viaggio " + trip.getTripCode() + ". Controlla l'app per i dettagli.",
                NotificationType.ASSIGNMENT,
                trip.getId()
        );
    }

    /**
     * {@inheritDoc}
     * <p>
     * Ricalcola forzatamente la rotta (es. in caso di deviazioni).
     * Nota: Questo metodo sovrascrive la rotta calcolata in fase di approvazione.
     * </p>
     */
    @Override
    @Transactional
    public void calculateRoute(Long tripId) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        // Simulazione ricalcolo (potrebbe chiamare nuovamente externalMapService)
        Route newRoute = new Route();
        newRoute.setRouteDistance(150.5);
        newRoute.setRouteDuration(120.0);
        newRoute.setPolyline("u{~vFvyys@fGe}A");
        newRoute.setTrip(trip);

        trip.setRoute(newRoute);
        tripRepository.save(trip);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Recupera un viaggio per ID, arricchendo il DTO con i dati anagrafici dell'autista.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public TripResponseDTO getTripById(Long id) {
        Trip trip = tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + id));
        return mapToDTOWithDriverInfo(trip);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Filtra i viaggi per stato, restituendo DTO arricchiti.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByStatus(TripStatus status) {
        List<Trip> trips = tripRepository.findByStatus(status);
        return trips.stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    /**
     * {@inheritDoc}
     * <p>
     * Recupera tutti i viaggi per la Dashboard globale.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getAllTrips() {
        return tripRepository.findAll().stream()
                .map(this::mapToDTOWithDriverInfo)
                .toList();
    }

    /**
     * {@inheritDoc}
     * <p>
     * Aggiorna lo stato operativo (chiamato dall'App Autista).
     * Gestisce la liberazione delle risorse (Autista/Veicolo) quando il viaggio è {@code COMPLETED}.
     * </p>
     */
    @Override
    @Transactional
    public void updateStatus(Long tripId, String newStatus) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato: " + tripId));

        try {
            TripStatus statusEnum = TripStatus.valueOf(newStatus);
            trip.setStatus(statusEnum);

            // Logica di rilascio risorse al completamento
            if (statusEnum == TripStatus.COMPLETED) {
                if (trip.getDriver() != null) {
                    trip.getDriver().setDriverStatus(DriverStatus.FREE);
                    driverRepository.save(trip.getDriver());
                }
                if (trip.getVehicle() != null) {
                    trip.getVehicle().setStatus(VehicleStatus.AVAILABLE);
                    vehicleRepository.save(trip.getVehicle());
                }
                log.info("Viaggio {} completato. Risorse liberate.", tripId);
            }

            tripRepository.save(trip);
            log.info("Stato aggiornato per Trip {}: {}", tripId, statusEnum);

        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException("Stato non valido: " + newStatus);
        }
    }

    /**
     * {@inheritDoc}
     * <p>
     * Gestisce il workflow di approvazione della rotta da parte del Coordinator.
     * <ul>
     * <li><b>Approvato:</b> Avanza lo stato a {@code IN_PLANNING}.</li>
     * <li><b>Rifiutato:</b> Cancella il Trip, resetta la Request e notifica il Planner.</li>
     * </ul>
     * </p>
     */
    @Override
    @Transactional
    public void validateRoute(Long tripId, boolean isApproved, String feedback) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato"));

        if (isApproved) {
            // Coordinator APPROVA -> Passa alla pianificazione risorse
            trip.setStatus(TripStatus.IN_PLANNING);
            trip.getRequest().setRequestStatus(RequestStatus.APPROVED);
            log.info("✅ Rotta approvata dal Coordinator per viaggio {}", tripId);
            tripRepository.save(trip);
        } else {
            // Coordinator RIFIUTA -> Rollback logico
            Long plannerId = 1L; // In un caso reale, si recupera l'ID dal contesto di sicurezza o dalla request

            notificationService.send(
                    plannerId,
                    "Rotta Rifiutata - Azione Richiesta",
                    "Il Coordinator ha rifiutato il piano per il viaggio " + trip.getTripCode() + ". Motivo: " + feedback,
                    NotificationType.ALERT,
                    trip.getRequest().getId()
            );

            // Rendi la richiesta nuovamente disponibile per essere processata
            requestRepository.save(trip.getRequest());
            // Elimina il tentativo di viaggio fallito
            tripRepository.delete(trip);

            log.info("❌ Rotta rifiutata. Trip eliminato e notifica inviata al Planner.");
        }
    }

    // --- HELPER PRIVATI ---

    /**
     * Converte Entity in DTO assicurandosi di copiare i dati anagrafici dell'autista.
     * Utile per visualizzare "Chi sta guidando cosa" nelle liste.
     */
    private TripResponseDTO mapToDTOWithDriverInfo(Trip trip) {
        // 1. Mapping automatico base
        TripResponseDTO tripDTO = tripMapper.toDTO(trip);

        // 2. Driver info
        if (trip.getDriver() != null) {
            tripDTO.setDriverId(trip.getDriver().getId());
            tripDTO.setDriverName(trip.getDriver().getFirstName());
            tripDTO.setDriverSurname(trip.getDriver().getLastName());
        }

        // 3. MAPPING ROTTA
        if (trip.getRoute() != null) {
            Route r = trip.getRoute();

            // Creiamo il DTO della rotta
            com.heavyroute.core.dto.RouteResponseDTO routeDTO = new com.heavyroute.core.dto.RouteResponseDTO();

            // Copia i dati semplici
            routeDTO.setId(r.getId());
            routeDTO.setRouteDescription(r.getDescription());
            routeDTO.setDistance(r.getRouteDistance());
            routeDTO.setDuration(r.getRouteDuration());
            routeDTO.setPolyline(r.getPolyline());

            // ESTRAZIONE COORDINAT
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