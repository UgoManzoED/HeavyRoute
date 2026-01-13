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

        trip.setStatus(TripStatus.WAITING_VALIDATION);
        trip.setTripCode("T-" + LocalDateTime.now().getYear() + "-" + String.format("%04d", requestId));

        // 4. Salvataggio a cascata (Trip -> Route)
        routeRepository.save(realRoute);
        Trip savedTrip = tripRepository.save(trip);

        log.info("✅ Viaggio creato: {}", savedTrip.getTripCode());
        return mapToDTOWithDriverInfo(savedTrip);
    }

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

    @Override
    @Transactional(readOnly = true)
    public TripResponseDTO getTripById(Long id) {
        Trip trip = tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + id));
        return mapToDTOWithDriverInfo(trip);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByStatus(TripStatus status) {
        return tripRepository.findByStatus(status).stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getAllTrips() {
        return tripRepository.findAll().stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    /**
     * Implementazione del recupero viaggi per autista.
     * Utilizzato dalla Dashboard Mobile.
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getTripsByDriver(Long driverId) {
        return tripRepository.findByDriverIdOrderByCreatedAtDesc(driverId)
                .stream()
                .map(this::mapToDTOWithDriverInfo)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void updateStatus(Long tripId, String newStatus) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato: " + tripId));

        try {
            TripStatus statusEnum = TripStatus.valueOf(newStatus);
            trip.setStatus(statusEnum);

            // Se il viaggio è finito, libera le risorse
            if (statusEnum == TripStatus.COMPLETED) {
                if (trip.getDriver() != null) {
                    trip.getDriver().setDriverStatus(DriverStatus.FREE);
                    driverRepository.save(trip.getDriver());
                }
                if (trip.getVehicle() != null) {
                    trip.getVehicle().setStatus(VehicleStatus.AVAILABLE);
                    vehicleRepository.save(trip.getVehicle());
                }
                log.info("✅ Viaggio {} completato. Risorse liberate.", tripId);
            }

            tripRepository.save(trip);
        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException("Stato non valido: " + newStatus);
        }
    }

    @Override
    @Transactional
    public void validateRoute(Long tripId, boolean isApproved, String feedback) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato"));

        if (isApproved) {
            trip.setStatus(TripStatus.CONFIRMED);
            trip.getRequest().setRequestStatus(RequestStatus.APPROVED);
            log.info("✅ Rotta approvata dal Coordinator. Viaggio CONFIRMED.");
            tripRepository.save(trip);
        } else {
            log.info("❌ Rotta rifiutata: {}", feedback);
            // In un sistema reale, qui invieremmo una notifica al Planner
        }
    }

    // --- MAPPER HELPER ---

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