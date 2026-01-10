package com.heavyroute.core.dto;

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
     * Converte un'entità {@link Trip} nel suo corrispondente {@link TripDTO}.
     * <p>
     * Questo metodo gestisce anche la mappatura delle relazioni: se il viaggio
     * ha una richiesta associata, delega la conversione al metodo specifico,
     * creando una struttura gerarchica nel JSON finale.
     * </p>
     *
     * @param trip L'entità sorgente (può essere null, il chiamante dovrebbe gestire il caso).
     * @return Il DTO popolato, pronto per essere restituito dal Controller.
     */
    public TripDTO toDTO(Trip trip) {
        // Best Practice in un mapper manuale, è buona norma controllare se trip è null
        if (trip == null) return null;

        TripDTO dto = new TripDTO();
        dto.setId(trip.getId());
        dto.setTripCode(trip.getTripCode());

        // Conversione Enum in String per stabilità dell'API
        dto.setStatus(trip.getStatus().name());

        if (trip.getDriver() != null) {
            // Estraiamo l'ID dall'oggetto Driver
            dto.setDriverId(trip.getDriver().getId());

            String fullName = trip.getDriver().getFirstName() + " " + trip.getDriver().getLastName();
            dto.setDriverName(fullName);
        }

        // 2. Mappatura Veicolo
        if (trip.getVehicle() != null) {
            // Estraiamo la targa dall'oggetto Vehicle
            dto.setVehiclePlate(trip.getVehicle().getLicensePlate());

            dto.setVehicleModel(trip.getVehicle().getModel());
        }

        // 3. Mappatura Richiesta
        if (trip.getRequest() != null) {
            RequestDetailDTO requestDTO = toRequestDTO(trip.getRequest());
            dto.setRequest(requestDTO);

            // Portiamo i dati del cliente anche al primo livello del TripDTO (Denormalizzazione)
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
     * al primo livello del {@code RequestDetailDTO} per semplificare la vita al Frontend.
     * </p>
     *
     * @param entity L'entità della richiesta.
     * @return Il DTO con i dati di carico "appiattiti".
     */
    public RequestDetailDTO toRequestDTO(TransportRequest entity) {
        if (entity == null) return null;

        RequestDetailDTO dto = new RequestDetailDTO();
        dto.setId(entity.getId());
        dto.setOriginAddress(entity.getOriginAddress());
        dto.setDestinationAddress(entity.getDestinationAddress());
        dto.setPickupDate(entity.getPickupDate());
        dto.setStatus(entity.getRequestStatus());

        // Mapping dei dati del Cliente (User)
        if (entity.getClient() != null) {
            dto.setClientId(entity.getClient().getId());
            dto.setClientFullName(entity.getClient().getFirstName() + " " + entity.getClient().getLastName());
        }

        // Logica di estrazione dati dal Value Object 'Load'
        if (entity.getLoad() != null) {
            dto.setWeight(entity.getLoad().getWeightKg());
            dto.setHeight(entity.getLoad().getHeight());
            dto.setWidth(entity.getLoad().getWidth());
            dto.setLength(entity.getLoad().getLength());
        }
        return dto;
    }
}