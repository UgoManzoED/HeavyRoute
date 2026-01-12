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
import java.util.stream.Collectors;

/**
 * Implementazione concreta della logica di business per i viaggi.
 * <p>
 * Questa classe gestisce il ciclo di vita operativo, orchestrando le modifiche
 * tra le entità {@link TransportRequest} e {@link Trip}.
 * Include la logica per l'approvazione, la pianificazione, il calcolo delle rotte
 * e l'aggiornamento dello stato operativo da parte degli autisti.
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
    private final TripMapper tripMapper;
    private final NotificationService notificationService;
    private final ExternalMapService externalMapService;

    /**
     * {@inheritDoc}
     * <p>
     * Crea un nuovo Trip a partire da una richiesta approvata.
     * Inizializza lo stato a {@code WAITING_VALIDATION} e genera il codice univoco del viaggio.
     * </p>
     */
    @Override
    @Transactional
    public TripResponseDTO approveRequest(Long requestId) {
        TransportRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Richiesta non trovata"));

        // Qui potresti avere logica per creare una Route fittizia o iniziale
        Route realRoute = new Route();
        // ... logica creazione route ...

        Trip trip = new Trip();
        trip.setRequest(request);
        trip.setRoute(realRoute);
        trip.setStatus(TripStatus.WAITING_VALIDATION); // In attesa del Coordinator
        trip.setTripCode("T-" + LocalDateTime.now().getYear() + "-" + String.format("%04d", requestId));

        Trip savedTrip = tripRepository.save(trip);

        return tripMapper.toDTO(savedTrip);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Assegna autista e veicolo a un viaggio in fase di pianificazione.
     * Esegue controlli bloccanti ("Fail Fast") su:
     * <ul>
     * <li>Stato del viaggio (deve essere {@code IN_PLANNING})</li>
     * <li>Disponibilità dell'autista</li>
     * <li>Disponibilità del veicolo</li>
     * <li>Congruenza tra portata del mezzo e carico richiesto</li>
     * </ul>
     * Invia una notifica all'autista in caso di successo.
     * </p>
     */
    @Override
    @Transactional
    public void planTrip(Long tripId, TripAssignmentDTO dto) {
        // Recupera il viaggio
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        // Validazione Stato: Si può pianificare solo se è IN_PLANNING
        if (trip.getStatus() != TripStatus.IN_PLANNING) {
            throw new BusinessRuleException("Il viaggio non è in fase di pianificazione. Stato attuale: " + trip.getStatus());
        }

        // Recupera l'Autista reale
        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new ResourceNotFoundException("Autista non trovato con ID: " + dto.getDriverId()));

        if (driver.getDriverStatus() != DriverStatus.FREE) {
            throw new BusinessRuleException("L'autista selezionato non è disponibile (Stato: " + driver.getDriverStatus() + ")");
        }

        // Recupera il Veicolo reale
        Vehicle vehicle = vehicleRepository.findByLicensePlate(dto.getVehiclePlate())
                .orElseThrow(() -> new ResourceNotFoundException("Veicolo non trovato con targa: " + dto.getVehiclePlate()));

        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new BusinessRuleException("Il veicolo selezionato non è disponibile (Stato: " + vehicle.getStatus() + ")");
        }

        // Controllo di Business: Portata del veicolo
        Double pesoRichiesto = trip.getRequest().getLoad().getWeightKg();
        if (vehicle.getMaxLoadCapacity() < pesoRichiesto) {
            throw new BusinessRuleException(String.format(
                    "Il veicolo %s ha una portata insufficiente (%s kg) per il carico richiesto (%s kg)",
                    vehicle.getLicensePlate(), vehicle.getMaxLoadCapacity(), pesoRichiesto));
        }

        // Associa gli oggetti
        trip.setDriver(driver);
        trip.setVehicle(vehicle);

        // Cambia lo stato delle risorse
        driver.setDriverStatus(DriverStatus.ASSIGNED);
        vehicle.setStatus(VehicleStatus.IN_USE);
        trip.setStatus(TripStatus.CONFIRMED);

        driverRepository.save(driver);
        vehicleRepository.save(vehicle);
        tripRepository.save(trip);

        // Invia la notifica
        notificationService.send(
                driver.getId(),
                "Nuovo Incarico",
                "Ti è stato assegnato un nuovo viaggio. Controlla i dettagli.",
                NotificationType.ASSIGNMENT,
                trip.getId()
        );
    }

    /**
     * {@inheritDoc}
     * <p>
     * Calcola e associa il percorso stradale al viaggio.
     * Attualmente implementa una logica MOCK per simulare la risposta di un provider esterno.
     * </p>
     */
    @Override
    @Transactional
    public void calculateRoute(Long tripId) {
        // 1. Fetch dell'entità padre
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        // 2. Simulazione della risposta di un motore di Routing esterno
        Route route = new Route();
        route.setRouteDistance(150.5);
        route.setRouteDuration(120.0);
        route.setPolyline("u{~vFvyys@fGe}A");

        // 3. Gestione della Relazione Bidirezionale
        route.setTrip(trip);
        trip.setRoute(route);

        // 4. Persistenza
        tripRepository.save(trip);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Recupera un viaggio per ID arricchendo il DTO con i dettagli dell'autista, se presente.
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
     * Recupera i viaggi filtrati per stato, mappandoli con le informazioni estese (Driver Info).
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByStatus(TripStatus status) {
        List<Trip> trips = tripRepository.findByStatus(status);
        return trips.stream()
                .map(this::mapToDTOWithDriverInfo) // Usa il metodo arricchito
                .collect(Collectors.toList());
    }

    /**
     * {@inheritDoc}
     * <p>
     * Recupera <b>tutti</b> i viaggi presenti nel sistema.
     * Utilizzato principalmente per la Dashboard del Planner.
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
     * Aggiorna lo stato operativo del viaggio (es. usato dall'app Autista).
     * <p>
     * Gestisce la transizione degli stati e, nel caso in cui il viaggio venga marcato come
     * {@code COMPLETED}, provvede a liberare le risorse (Autista e Veicolo).
     * </p>
     *
     * @param tripId    L'ID del viaggio da aggiornare.
     * @param newStatus Il nuovo stato in formato Stringa (deve corrispondere all'enum {@link TripStatus}).
     * @throws BusinessRuleException se la stringa di stato non è valida.
     */
    @Override
    @Transactional
    public void updateStatus(Long tripId, String newStatus) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato: " + tripId));

        try {
            // Conversione stringa -> Enum
            TripStatus statusEnum = TripStatus.valueOf(newStatus);
            trip.setStatus(statusEnum);

            // Se lo stato è COMPLETATO, libera autista e mezzo
            if (statusEnum == TripStatus.COMPLETED) {
                if (trip.getDriver() != null) {
                    trip.getDriver().setDriverStatus(DriverStatus.FREE);
                    driverRepository.save(trip.getDriver()); // Salva esplicitamente se non in cascata
                }
                if (trip.getVehicle() != null) {
                    trip.getVehicle().setStatus(VehicleStatus.AVAILABLE);
                    vehicleRepository.save(trip.getVehicle()); // Salva esplicitamente se non in cascata
                }
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
     * Gestisce la validazione della rotta da parte del Coordinator.
     * Se approvata, il viaggio passa in {@code IN_PLANNING}.
     * Se rifiutata, il viaggio viene cancellato (o resettato) e viene inviata una notifica di allerta al Planner.
     * </p>
     */
    @Override
    @Transactional
    public void validateRoute(Long tripId, boolean isApproved, String feedback) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato"));

        if (isApproved) {
            // COORDINATOR APPROVA
            trip.setStatus(TripStatus.IN_PLANNING); // Ora si possono assegnare i mezzi
            trip.getRequest().setRequestStatus(RequestStatus.APPROVED);
            log.info("✅ Rotta approvata dal Coordinator per viaggio {}", tripId);
            tripRepository.save(trip);
        } else {
            // COORDINATOR RIFIUTA
            Long plannerId = 1L; // TODO: Recuperare l'ID reale del Planner creatore

            notificationService.send(
                    plannerId,
                    "Rotta Rifiutata",
                    "Il Coordinator ha rifiutato il piano per il viaggio " + trip.getTripCode() + ". Nota: " + feedback,
                    NotificationType.ALERT,
                    trip.getRequest().getId()
            );

            // Pulizia: eliminiamo il trip bocciato per permettere una nuova pianificazione
            // La request torna disponibile per essere riprocessata o modificata
            requestRepository.save(trip.getRequest());
            tripRepository.delete(trip);
            log.info("❌ Rotta rifiutata. Notifica inviata al Planner.");
        }
    }

    // --- HELPER PRIVATI ---

    /**
     * Metodo di utilità per convertire l'Entity in DTO arricchendolo con i dati dell'autista.
     * <p>
     * Questo metodo centralizza la logica di mapping custom che non è gestita
     * automaticamente dal Mapper base, garantendo che nome e cognome dell'autista
     * siano presenti nelle risposte verso il Frontend.
     * </p>
     *
     * @param trip L'entità Trip da convertire.
     * @return Il DTO arricchito.
     */
    private TripResponseDTO mapToDTOWithDriverInfo(Trip trip) {
        TripResponseDTO dto = tripMapper.toDTO(trip);

        if (trip.getDriver() != null) {
            dto.setDriverId(trip.getDriver().getId());
            dto.setDriverName(trip.getDriver().getFirstName());
            dto.setDriverSurname(trip.getDriver().getLastName());
            // Esempio: dto.setCurrentLocation("Posizione simulata");
        }
        return dto;
    }
}