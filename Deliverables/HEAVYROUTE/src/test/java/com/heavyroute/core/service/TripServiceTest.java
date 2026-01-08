package com.heavyroute.core.service;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.core.dto.PlanningDTO;
import com.heavyroute.core.dto.TripDTO;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.core.service.impl.TripServiceImpl;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.repository.DriverRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit Test per la classe {@link TripServiceImpl}.
 * <p>
 * Utilizza Mockito per isolare la logica di business dalle dipendenze esterne (Database, Mapper).
 * Segue il pattern AAA: Arrange (prepara i dati), Act (chiama il metodo), Assert (verifica i risultati).
 * </p>
 */
@ExtendWith(MockitoExtension.class)
class TripServiceTest {

    // --- DIPENDENZE MOCKATE ---
    @Mock private TripRepository tripRepository;
    @Mock private TransportRequestRepository requestRepository;
    @Mock private DriverRepository driverRepository;
    @Mock private VehicleRepository vehicleRepository;
    @Mock private TripMapper tripMapper;

    // --- SOGGETTO DEL TEST ---
    @InjectMocks
    private TripServiceImpl tripService;

    /**
     * Test dello scenario positivo (Happy Path) per l'approvazione.
     * Verifica che una richiesta PENDING diventi APPROVED e generi un nuovo Trip.
     */
    @Test
    void approveRequest_ShouldCreateTrip_WhenRequestIsPending() {
        // ARRANGE
        Long reqId = 1L;
        TransportRequest req = new TransportRequest();
        req.setId(reqId);
        req.setRequestStatus(RequestStatus.PENDING);

        when(requestRepository.findById(reqId)).thenReturn(Optional.of(req));

        // Quando salva, simuliamo che il DB assegni un ID e ritorni l'oggetto
        when(tripRepository.save(any(Trip.class))).thenAnswer(i -> {
            Trip t = i.getArgument(0);
            t.setId(100L);
            t.setTripCode("TRP-TEST");
            return t;
        });

        // Mockiamo il mapper per evitare NullPointerException
        when(tripMapper.toDTO(any(Trip.class))).thenReturn(new TripDTO());

        // ACT
        tripService.approveRequest(reqId);

        // ASSERT
        verify(requestRepository).save(req); // Verifica salvataggio richiesta
        assertEquals(RequestStatus.APPROVED, req.getRequestStatus()); // Verifica cambio stato
        verify(tripRepository).save(any(Trip.class)); // Verifica salvataggio viaggio
    }

    /**
     * Test dell'assegnazione risorse con validazione di capacità.
     * Verifica che il sistema accetti un veicolo capiente e un autista libero.
     */
    @Test
    void planTrip_ShouldAssignResources_WhenValid() {
        // ARRANGE
        Long tripId = 100L;
        Long driverId = 200L;
        String plate = "AB123CD";

        // Setup Viaggio
        Trip trip = new Trip();
        trip.setId(tripId);
        trip.setStatus(TripStatus.IN_PLANNING);

        // Setup Richiesta (per controllo peso)
        TransportRequest req = new TransportRequest();
        var load = new com.heavyroute.core.model.LoadDetails();
        load.setWeightKg(5000.0);
        req.setLoad(load);
        trip.setRequest(req);

        // Setup Driver (LIBERO)
        Driver driver = new Driver();
        driver.setId(driverId);
        driver.setStatus(DriverStatus.FREE);

        // Setup Vehicle (DISPONIBILE e CAPIENTE)
        Vehicle vehicle = new Vehicle();
        vehicle.setLicensePlate(plate);
        vehicle.setStatus(VehicleStatus.AVAILABLE);
        vehicle.setMaxLoadCapacity(10000.0);

        // Mocks
        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(driverRepository.findById(driverId)).thenReturn(Optional.of(driver));
        when(vehicleRepository.findByLicensePlate(plate)).thenReturn(Optional.of(vehicle));

        // ACT
        PlanningDTO dto = new PlanningDTO(tripId, driverId, plate);
        tripService.planTrip(tripId, dto);

        // ASSERT
        assertEquals(driver, trip.getDriver());
        assertEquals(vehicle, trip.getVehicle());
        verify(tripRepository).save(trip);
    }

    /**
     * Test negativo ("Sad Path"): Conflitto risorse.
     * Verifica che venga lanciata un'eccezione se il veicolo è già in uso.
     */
    @Test
    void planTrip_ShouldThrowException_WhenVehicleNotAvailable() {
        // ARRANGE
        Long tripId = 100L;
        Long driverId = 200L;
        String plate = "AB123CD";

        Trip trip = new Trip();
        trip.setStatus(TripStatus.IN_PLANNING);

        Driver driver = new Driver();
        driver.setStatus(DriverStatus.FREE);

        // Veicolo OCCUPATO
        Vehicle vehicle = new Vehicle();
        vehicle.setStatus(VehicleStatus.IN_USE);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(driverRepository.findById(driverId)).thenReturn(Optional.of(driver));
        when(vehicleRepository.findByLicensePlate(plate)).thenReturn(Optional.of(vehicle));

        // ACT & ASSERT
        PlanningDTO dto = new PlanningDTO(tripId, driverId, plate);

        BusinessRuleException exception = assertThrows(BusinessRuleException.class, () -> {
            tripService.planTrip(tripId, dto);
        });

        assertTrue(exception.getMessage().contains("non è disponibile"));
        verify(tripRepository, never()).save(trip);
    }

    /**
     * Test dell'integrazione del routing.
     * Usa ArgumentCaptor per ispezionare l'oggetto passato al metodo save().
     */
    @Test
    void calculateRoute_ShouldAttachRouteToTrip() {
        // ARRANGE
        Long tripId = 100L;
        Trip trip = new Trip();
        trip.setId(tripId);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));

        // ACT
        tripService.calculateRoute(tripId);

        // ASSERT
        // Usiamo un Captor per vedere cosa è stato passato al metodo save
        ArgumentCaptor<Trip> tripCaptor = ArgumentCaptor.forClass(Trip.class);
        verify(tripRepository).save(tripCaptor.capture());

        Trip savedTrip = tripCaptor.getValue();
        assertNotNull(savedTrip.getRoute()); // Verifica che la rotta sia stata creata
        assertEquals(150.5, savedTrip.getRoute().getRouteDistance()); // Verifica dati finti
        assertEquals(trip, savedTrip.getRoute().getTrip()); // Verifica relazione inversa
    }
}