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
 * Utilizza l'annotazione {@link Transactional} per garantire l'atomicità delle operazioni
 * che coinvolgono scritture su database.
 * </p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TripServiceImpl implements TripService {

    private final TripRepository tripRepository;
    private final TransportRequestRepository requestRepository;
    private final TripMapper tripMapper;
    private final DriverRepository driverRepository;
    private final VehicleRepository vehicleRepository;
    private final RouteRepository routeRepository;
    private final NotificationService notificationService;
    private final ExternalMapService externalMapService;

    /**
     * {@inheritDoc}
     * <p>
     * <b>Logica Transazionale:</b> Questo metodo modifica lo stato di due entità distinte.
     * L'annotazione {@code @Transactional} garantisce che se il salvataggio del Trip fallisce,
     * l'aggiornamento dello stato della Request venga annullato (Rollback), mantenendo il sistema consistente.
     * </p>
     */
    @Override
    @Transactional
    public TripResponseDTO approveRequest(Long requestId) {
        TransportRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Richiesta non trovata"));

        Route realRoute = externalMapService.calculateFullRoute(
                request.getOriginAddress(),
                request.getDestinationAddress()
        );
        routeRepository.save(realRoute);

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
     * Questo metodo applica il pattern "Fail Fast": verifica subito l'esistenza
     * e la coerenza dello stato prima di applicare qualsiasi modifica.
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

        // Salva
        tripRepository.save(trip);

        // Cambia lo stato delle risorse
        driver.setDriverStatus(DriverStatus.ASSIGNED);
        vehicle.setStatus(VehicleStatus.IN_USE);
        trip.setStatus(TripStatus.CONFIRMED);

        driverRepository.save(driver);
        vehicleRepository.save(vehicle);
        tripRepository.save(trip);

        // Invia la notifica (usa la tua NotificationService)
        notificationService.send(
                driver.getId(),
                "Nuovo Incarico",
                "Ti è stato assegnato un nuovo viaggio. Controlla i dettagli.",
                NotificationType.ASSIGNMENT,
                trip.getId()
        );
    }

    /**
     * Calcola e associa il percorso stradale al viaggio.
     * <p>
     * Attualmente implementa una logica MOCK: invece di interrogare un provider
     * cartografico esterno, istanzia un percorso statico
     * per testare la persistenza e le relazioni del database.
     * </p>
     *
     * @param tripId L'ID del viaggio per cui calcolare il percorso.
     * @throws ResourceNotFoundException se il viaggio non esiste.
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
     * <b>Ottimizzazione:</b> {@code readOnly = true} suggerisce a Hibernate di non fare
     * il "dirty checking" (controllo modifiche) sulle entità caricate, migliorando le performance
     * e riducendo il consumo di memoria per operazioni di sola lettura.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public TripResponseDTO getTripById(Long id) {
        Trip trip = tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + id));
        return tripMapper.toDTO(trip);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Esegue una query di lettura ottimizzata (readOnly = true).
     * Converte le entità in DTO utilizzando il Mapper per disaccoppiare il dominio dalla vista.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByStatus(TripStatus status) {
        // 1. Recupero entità dal DB tramite il metodo aggiunto nel Repository
        List<Trip> trips = tripRepository.findByStatus(status);

        // 2. Conversione Entity -> DTO tramite Stream API e Mapper
        return trips.stream()
                .map(tripMapper::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getAllTrips() {
        // Recupera tutti i viaggi dal DB
        List<Trip> trips = tripRepository.findAll();

        // Li converte in DTO usando il Mapper
        return trips.stream()
                .map(tripMapper::toDTO)
                .toList();
    }

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
        } else {
            // COORDINATOR RIFIUTA
            Long plannerId = 1L; // Qui dovresti recuperare l'ID del Planner che ha creato il Trip

            notificationService.send(
                    plannerId,
                    "Rotta Rifiutata",
                    "Il Coordinator ha rifiutato il piano per il viaggio " + trip.getTripCode() + ". Nota: " + feedback,
                    NotificationType.ALERT,
                    trip.getRequest().getId()
            );

            // Pulizia: eliminiamo il trip bocciato per permettere una nuova pianificazione
            requestRepository.save(trip.getRequest()); // Torna gestibile dal planner
            tripRepository.delete(trip);
            log.info("❌ Rotta rifiutata. Notifica inviata al Planner.");
        }
    }
}