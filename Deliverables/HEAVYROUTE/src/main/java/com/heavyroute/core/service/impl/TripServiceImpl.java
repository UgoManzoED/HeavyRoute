package com.heavyroute.core.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.core.dto.PlanningDTO;
import com.heavyroute.core.dto.RequestDetailDTO; // Importante: DTO del Collega 1
import com.heavyroute.core.dto.TripDTO;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.core.service.TripService;
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
        Trip savedTrip = tripRepository.save(trip);

        // 5. Converte in DTO e restituisce
        return mapToDTO(savedTrip);
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

        // 3. Aggiorna le risorse (Autista e Veicolo)
        // In un sistema completo qui chiameremmo il ResourceService per verificare la disponibilità
        trip.setDriverId(dto.getDriverId());
        trip.setVehiclePlate(dto.getVehiclePlate());

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
        return mapToDTO(trip);
    }

    // --- METODI DI AIUTO (MAPPING) ---

    private TripDTO mapToDTO(Trip trip) {
        TripDTO dto = new TripDTO();
        dto.setId(trip.getId());
        dto.setTripCode(trip.getTripCode());
        dto.setStatus(trip.getStatus().name());

        // Risorse assegnate
        dto.setDriverId(trip.getDriverId());
        dto.setVehiclePlate(trip.getVehiclePlate());

        // Mapping dei dati della richiesta originale
        if (trip.getRequest() != null) {
            dto.setRequest(mapRequestToDTO(trip.getRequest()));
        }

        return dto;
    }

    private RequestDetailDTO mapRequestToDTO(TransportRequest entity) {
        RequestDetailDTO dto = new RequestDetailDTO();
        dto.setId(entity.getId());
        dto.setStatus(entity.getRequestStatus());

        // Mapping dati di indirizzo
        dto.setOriginAddress(entity.getOriginAddress());
        dto.setDestinationAddress(entity.getDestinationAddress());
        dto.setPickupDate(entity.getPickupDate());

        // Mapping dati di carico
        if (entity.getLoad() != null) {
            dto.setWeight(entity.getLoad().getWeightKg());
            dto.setHeight(entity.getLoad().getHeight());
            dto.setWidth(entity.getLoad().getWidth());
            dto.setLength(entity.getLoad().getLength());
        }
        return dto;
    }
}