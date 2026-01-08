package com.heavyroute.core.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.core.dto.PlanningDTO;
import com.heavyroute.core.dto.RequestDetailDTO;
import com.heavyroute.core.dto.TripDTO;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.core.service.TripMapper;
import com.heavyroute.core.service.TripService;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.repository.DriverRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementazione concreta della logica di business per i viaggi.
 * <p>
 * Questa classe gestisce il ciclo di vita operativo, orchestrando le modifiche
 * tra le entità {@link TransportRequest} e {@link Trip}.
 * Utilizza l'annotazione {@link Transactional} per garantire l'atomicità delle operazioni
 * che coinvolgono scritture su database.
 * </p>
 */

@Service
@RequiredArgsConstructor
public class TripServiceImpl implements TripService {

    private final TripRepository tripRepository;
    private final TransportRequestRepository requestRepository;
    private final TripMapper tripMapper;
    private final DriverRepository driverRepository;
    private final VehicleRepository vehicleRepository;

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
    public TripDTO approveRequest(Long requestId) {
        // 1. Recupera la richiesta dal DB
        TransportRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Richiesta non trovata con ID: " + requestId));

        // 2. Validazione di Business, si può approvare solo se è PENDING
        if (request.getRequestStatus() != RequestStatus.PENDING) {
            throw new BusinessRuleException("Impossibile approvare una richiesta che si trova nello stato: " + request.getRequestStatus());
        }

        // 3. Aggiorna lo stato della richiesta
        request.setRequestStatus(RequestStatus.APPROVED);
        requestRepository.save(request);

        // 4. Crea il nuovo oggetto Viaggio (Trip)
        Trip trip = new Trip();
        trip.setStatus(TripStatus.IN_PLANNING);
        trip.setRequest(request);

        // 5. Converte in DTO e restituisce
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
    public void planTrip(Long tripId, PlanningDTO dto) {
        // 1. Recupera il viaggio
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + tripId));

        // 2. Validazione Stato: Si può pianificare solo se è IN_PLANNING
        if (trip.getStatus() != TripStatus.IN_PLANNING) {
            throw new BusinessRuleException("Il viaggio non è in fase di pianificazione. Stato attuale: " + trip.getStatus());
        }

        // 3a. Recupera l'Autista reale
        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new ResourceNotFoundException("Autista non trovato con ID: " + dto.getDriverId()));

        if (driver.getStatus() != DriverStatus.FREE) {
            throw new BusinessRuleException("L'autista selezionato non è disponibile (Stato: " + driver.getStatus() + ")");
        }

        // 3b. Recupera il Veicolo reale
        Vehicle vehicle = vehicleRepository.findByLicensePlate(dto.getVehiclePlate())
                .orElseThrow(() -> new ResourceNotFoundException("Veicolo non trovato con targa: " + dto.getVehiclePlate()));

        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new BusinessRuleException("Il veicolo selezionato non è disponibile (Stato: " + vehicle.getStatus() + ")");
        }

        // 3c. Controllo di Business: Portata del veicolo
        Double pesoRichiesto = trip.getRequest().getLoad().getWeightKg();
        if (vehicle.getMaxLoadCapacity() < pesoRichiesto) {
            throw new BusinessRuleException(String.format(
                    "Il veicolo %s ha una portata insufficiente (%s kg) per il carico richiesto (%s kg)",
                    vehicle.getLicensePlate(), vehicle.getMaxLoadCapacity(), pesoRichiesto));
        }

        // 4. Associa gli oggetti
        trip.setDriver(driver);
        trip.setVehicle(vehicle);

        // 5. Salva
        tripRepository.save(trip);
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
    public TripDTO getTrip(Long id) {
        Trip trip = tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Viaggio non trovato con ID: " + id));
        return tripMapper.toDTO(trip);
    }
}