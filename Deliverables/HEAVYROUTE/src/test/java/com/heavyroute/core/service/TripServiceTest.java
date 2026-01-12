package com.heavyroute.core.service;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.mapper.TripMapper;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.repository.RouteRepository;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.core.service.impl.TripServiceImpl;
import com.heavyroute.notification.service.NotificationService;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.repository.DriverRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TripServiceTest {

    @Mock private TripRepository tripRepository;
    @Mock private TransportRequestRepository requestRepository;
    @Mock private DriverRepository driverRepository;
    @Mock private VehicleRepository vehicleRepository;
    @Mock private RouteRepository routeRepository;
    @Mock private NotificationService notificationService; // Aggiunto
    @Mock private TripMapper tripMapper;

    @InjectMocks
    private TripServiceImpl tripService;

    @Test
    @DisplayName("TC-CORE-03: Approvazione Richiesta - Creazione Viaggio (UC3)")
    void approveRequest_ShouldCreateTrip() {
        // ARRANGE
        Long reqId = 1L;
        TransportRequest req = new TransportRequest();
        req.setId(reqId);
        req.setRequestStatus(RequestStatus.PENDING);

        when(requestRepository.findById(reqId)).thenReturn(Optional.of(req));
        when(routeRepository.save(any(Route.class))).thenAnswer(i -> i.getArgument(0));
        when(tripRepository.save(any(Trip.class))).thenAnswer(i -> {
            Trip t = i.getArgument(0);
            t.setId(100L);
            return t;
        });
        when(tripMapper.toDTO(any(Trip.class))).thenReturn(new TripResponseDTO());

        // ACT
        tripService.approveRequest(reqId);

        // ASSERT
        assertEquals(RequestStatus.APPROVED, req.getRequestStatus()); // Side Effect: Stato aggiornato
        verify(tripRepository).save(argThat(trip ->
                trip.getStatus() == TripStatus.WAITING_VALIDATION && // Stato: IN_PIANIFICAZIONE
                        trip.getTripCode().startsWith("T-2026")
        ));
    }

    @Test
    @DisplayName("TC-CORE-04: Assegnazione Risorse - Successo (Happy Path)")
    void planTrip_ShouldAssignResources_WhenValid() {
        Long tripId = 50L;
        Long driverId = 200L;
        String plate = "VE-001-AB";

        Trip trip = createMockTrip(tripId, 1500.0, TripStatus.IN_PLANNING);
        Driver driver = createMockDriver(driverId, DriverStatus.FREE);
        Vehicle vehicle = createMockVehicle(plate, 5000.0, VehicleStatus.AVAILABLE);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(driverRepository.findById(driverId)).thenReturn(Optional.of(driver));
        when(vehicleRepository.findByLicensePlate(plate)).thenReturn(Optional.of(vehicle));

        // ACT
        TripAssignmentDTO dto = new TripAssignmentDTO(tripId, driverId, plate);
        tripService.planTrip(tripId, dto);

        // ASSERT (Oracle dal LaTeX Sezione 4.4)
        assertEquals(DriverStatus.ASSIGNED, driver.getDriverStatus());
        assertEquals(VehicleStatus.IN_USE, vehicle.getStatus());
        assertEquals(TripStatus.CONFIRMED, trip.getStatus());
        verify(notificationService).send(eq(driverId), anyString(), anyString(), any(), any());
    }

    @Test
    @DisplayName("TC-CORE-05: Assegnazione Risorse - Errore Capacità Insufficiente")
    void planTrip_ShouldThrowException_WhenWeightExceedsCapacity() {
        Long tripId = 50L;
        Long driverId = 200L;
        String plate = "VE-SMALL";

        Trip trip = createMockTrip(tripId, 15000.0, TripStatus.IN_PLANNING);
        Driver driver = createMockDriver(driverId, DriverStatus.FREE);
        Vehicle vehicle = createMockVehicle(plate, 10000.0, VehicleStatus.AVAILABLE);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(driverRepository.findById(driverId)).thenReturn(Optional.of(driver));
        when(vehicleRepository.findByLicensePlate(plate)).thenReturn(Optional.of(vehicle));

        // ACT & ASSERT
        TripAssignmentDTO dto = new TripAssignmentDTO(tripId, driverId, plate);
        BusinessRuleException ex = assertThrows(BusinessRuleException.class, () -> tripService.planTrip(tripId, dto));

        assertTrue(ex.getMessage().contains("portata insufficiente"));
        verify(tripRepository, times(0)).save(any());
    }

    @Test
    @DisplayName("TC-CORE-07: Validazione Rotta - Aggiornamento Coerenza Stati")
    void validateRoute_ShouldUpdateBothTripAndRequest() {
        // ARRANGE
        Long tripId = 1L;
        TransportRequest req = new TransportRequest();
        req.setRequestStatus(RequestStatus.APPROVED);

        Trip trip = new Trip();
        trip.setStatus(TripStatus.WAITING_VALIDATION);
        trip.setRequest(req);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));

        // ACT
        tripService.validateRoute(tripId);

        // ASSERT
        assertEquals(TripStatus.VALIDATED, trip.getStatus());
        assertEquals(RequestStatus.PLANNED, req.getRequestStatus());
    }

    // --- HELPER METHODS ---
    private Trip createMockTrip(Long id, Double weight, TripStatus status) {
        Trip trip = new Trip();
        trip.setId(id);
        trip.setStatus(status);
        TransportRequest req = new TransportRequest();
        var load = new com.heavyroute.core.model.LoadDetails();
        load.setWeightKg(weight);
        req.setLoad(load);
        trip.setRequest(req);
        return trip;
    }

    private Driver createMockDriver(Long id, DriverStatus status) {
        Driver d = new Driver();
        d.setId(id);
        d.setDriverStatus(status);
        return d;
    }

    private Vehicle createMockVehicle(String plate, Double capacity, VehicleStatus status) {
        Vehicle v = new Vehicle();
        v.setLicensePlate(plate);
        v.setMaxLoadCapacity(capacity);
        v.setStatus(status);
        return v;
    }
}