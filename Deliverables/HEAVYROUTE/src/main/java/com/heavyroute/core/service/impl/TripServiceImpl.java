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

    // ... (approveRequest, planTrip, calculateRoute rimangono uguali) ...

    @Override
    @Transactional
    public TripResponseDTO approveRequest(Long requestId) {
        // ... codice esistente ...
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
        trip.setStatus(TripStatus.WAITING_VALIDATION);
        trip.setTripCode("T-" + LocalDateTime.now().getYear() + "-" + String.format("%04d", requestId));

        return tripMapper.toDTO(tripRepository.save(trip));
    }

    @Override
    @Transactional
    public void planTrip(Long tripId, TripAssignmentDTO dto) {
        // ... codice esistente ...
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        // (Logica validazione omessa per brevità, usa quella che avevi)

        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new ResourceNotFoundException("Autista non trovato"));
        Vehicle vehicle = vehicleRepository.findByLicensePlate(dto.getVehiclePlate())
                .orElseThrow(() -> new ResourceNotFoundException("Veicolo non trovato"));

        trip.setDriver(driver);
        trip.setVehicle(vehicle);
        trip.setStatus(TripStatus.CONFIRMED);
        driver.setDriverStatus(DriverStatus.ASSIGNED);
        vehicle.setStatus(VehicleStatus.IN_USE);

        driverRepository.save(driver);
        vehicleRepository.save(vehicle);
        tripRepository.save(trip);
    }

    @Override
    @Transactional
    public void calculateRoute(Long tripId) {
        // ... codice esistente ...
    }

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
        List<Trip> trips = tripRepository.findByStatus(status);
        return trips.stream()
                .map(this::mapToDTOWithDriverInfo) // Usa il metodo arricchito
                .collect(Collectors.toList());
    }

    /**
     * Recupera TUTTI i viaggi e popola i dati autista per la Dashboard Planner.
     */
    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDTO> getAllTrips() {
        return tripRepository.findAll().stream()
                .map(this::mapToDTOWithDriverInfo) // Metodo custom per arricchimento
                .toList();
    }

    /**
     * NUOVO: Aggiorna lo stato su richiesta dell'Autista.
     */
    @Override
    @Transactional
    public void updateStatus(Long tripId, String newStatus) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato: " + tripId));

        try {
            // Conversione stringa -> Enum (es. "IN_VIAGGIO" -> TripStatus.IN_VIAGGIO)
            TripStatus statusEnum = TripStatus.valueOf(newStatus);
            trip.setStatus(statusEnum);

            // Se lo stato è COMPLETATO, libera autista e mezzo
            if (statusEnum == TripStatus.COMPLETED) {
                if (trip.getDriver() != null) trip.getDriver().setDriverStatus(DriverStatus.FREE);
                if (trip.getVehicle() != null) trip.getVehicle().setStatus(VehicleStatus.AVAILABLE);
            }

            tripRepository.save(trip);
            log.info("Stato aggiornato per Trip {}: {}", tripId, statusEnum);

        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException("Stato non valido: " + newStatus);
        }
    }

    @Override
    @Transactional
    public void validateRoute(Long tripId, boolean isApproved, String feedback) {
        // ... codice esistente ...
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato"));

        if (isApproved) {
            trip.setStatus(TripStatus.IN_PLANNING);
            trip.getRequest().setRequestStatus(RequestStatus.APPROVED);
        } else {
            tripRepository.delete(trip);
        }
    }

    // --- HELPER PRIVATO ---
    /**
     * Converte Entity in DTO assicurandosi di copiare i dati dell'autista.
     */
    private TripResponseDTO mapToDTOWithDriverInfo(Trip trip) {
        TripResponseDTO dto = tripMapper.toDTO(trip);

        if (trip.getDriver() != null) {
            dto.setDriverId(trip.getDriver().getId());
            dto.setDriverName(trip.getDriver().getFirstName());
            dto.setDriverSurname(trip.getDriver().getLastName());
            // dto.setCurrentLocation("Posizione simulata");
        }
        return dto;
    }
}