package com.heavyroute.core.mapper;

import com.heavyroute.core.dto.TransportRequestResponseDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import org.springframework.stereotype.Component;

/**
 * Componente responsabile della conversione (Mapping) tra le Entità di persistenza e i DTO.
 * <p>
 * Agisce come un "Traduttore": prende i dati dal formato ottimizzato per il database (Entity)
 * e li travasa nel formato ottimizzato per la visualizzazione API (DTO).
 * Implementato come {@link Component} Spring per poter essere iniettato nei Service.
 * </p>
 */
@Component
public class TripMapper {

    /**
     * Converte un'entità {@link Trip} nel suo corrispondente {@link TripResponseDTO}.
     * <p>
     * Questo metodo gestisce anche la mappatura delle relazioni: se il viaggio
     * ha una richiesta associata, delega la conversione al metodo specifico,
     * creando una struttura gerarchica nel JSON finale.
     * </p>
     *
     * @param trip L'entità sorgente (può essere null, il chiamante dovrebbe gestire il caso).
     * @return Il DTO popolato, pronto per essere restituito dal Controller.
     */
    public TripResponseDTO toDTO(Trip trip) {
        // Best Practice in un mapper manuale, è buona norma controllare se trip è null
        if (trip == null) return null;

        TripResponseDTO dto = new TripResponseDTO();
        dto.setId(trip.getId());
        dto.setTripCode(trip.getTripCode());

        // Conversione Enum in String per stabilità dell'API
        dto.setStatus(trip.getStatus());

        if (trip.getDriver() != null) {
            // Estraiamo l'ID e nome dall'oggetto Driver
            dto.setDriverId(trip.getDriver().getId());
            String fullName = trip.getDriver().getFirstName() + " " + trip.getDriver().getLastName();
            dto.setDriverName(fullName);
        }

        // 2. Mappatura Veicolo
        if (trip.getVehicle() != null) {
            // Estraiamo la targa e modello dall'oggetto Vehicle
            dto.setVehiclePlate(trip.getVehicle().getLicensePlate());
            dto.setVehicleModel(trip.getVehicle().getModel());
        }

        // 3. Mappatura Richiesta
        if (trip.getRequest() != null) {
            TransportRequestResponseDTO requestDTO = toRequestDTO(trip.getRequest());
            dto.setRequest(requestDTO);

            // Portiamo i dati del cliente anche al primo livello del TripResponseDTO
            dto.setClientId(requestDTO.getClientId());
            dto.setClientFullName(requestDTO.getClientFullName());
        }

        return dto;
    }

    /**
     * Converte i dettagli della richiesta di trasporto.
     * <p>
     * <b>Strategia di Flattening (Appiattimento):</b>
     * L'entità {@code TransportRequest} contiene un oggetto annidato {@code Load} (Embeddable).
     * Questo mapper "estrae" i campi interni di {@code Load} (peso, altezza, ecc.) e li porta
     * al primo livello del {@code TransportRequestResponseDTO} per semplificare la vita al Frontend.
     * </p>
     *
     * @param entity L'entità della richiesta.
     * @return Il DTO con i dati di carico "appiattiti".
     */
    public TransportRequestResponseDTO toRequestDTO(TransportRequest entity) {
        if (entity == null) return null;

        TransportRequestResponseDTO dto = new TransportRequestResponseDTO();
        dto.setId(entity.getId());
        dto.setOriginAddress(entity.getOriginAddress());
        dto.setDestinationAddress(entity.getDestinationAddress());
        dto.setPickupDate(entity.getPickupDate());
        dto.setRequestStatus(entity.getRequestStatus());

        // Mapping dei dati del Cliente (User)
        if (entity.getClient() != null) {
            dto.setClientId(entity.getClient().getId());
            dto.setClientFullName(entity.getClient().getFirstName() + " " + entity.getClient().getLastName());
        }

        // Logica di estrazione dati dal Value Object 'Load'
        if (entity.getLoad() != null) {
            TransportRequestResponseDTO.LoadDetailsDTO loadDto = new TransportRequestResponseDTO.LoadDetailsDTO();

            loadDto.setType(entity.getLoad().getType());
            loadDto.setWeightKg(entity.getLoad().getWeightKg());
            loadDto.setHeight(entity.getLoad().getHeight());
            loadDto.setLength(entity.getLoad().getLength());
            loadDto.setWidth(entity.getLoad().getWidth());

            // Setta l'oggetto annidato nel DTO padre
            dto.setLoad(loadDto);
        }

        return dto;
    }
}