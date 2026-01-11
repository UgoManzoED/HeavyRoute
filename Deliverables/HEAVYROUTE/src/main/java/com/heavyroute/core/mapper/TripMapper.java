package com.heavyroute.core.mapper;

import com.heavyroute.core.dto.TransportRequestResponseDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TripMapper {

    // Injection del mapper
    private final RouteMapper routeMapper;

    public TripResponseDTO toDTO(Trip trip) {
        if (trip == null) return null;

        TripResponseDTO dto = new TripResponseDTO();
        dto.setId(trip.getId());
        dto.setTripCode(trip.getTripCode());
        dto.setStatus(trip.getStatus());

        // 1. Mappatura Driver
        if (trip.getDriver() != null) {
            dto.setDriverId(trip.getDriver().getId());
            String fullName = trip.getDriver().getFirstName() + " " + trip.getDriver().getLastName();
            dto.setDriverName(fullName);
        }

        // 2. Mappatura Veicolo
        if (trip.getVehicle() != null) {
            dto.setVehiclePlate(trip.getVehicle().getLicensePlate());
            dto.setVehicleModel(trip.getVehicle().getModel());
        }

        // 3. Mappatura Richiesta
        if (trip.getRequest() != null) {
            TransportRequestResponseDTO requestDTO = toRequestDTO(trip.getRequest());
            dto.setRequest(requestDTO);

            // Flattening dei dati cliente per comodità
            dto.setClientId(requestDTO.getClientId());
            dto.setClientFullName(requestDTO.getClientFullName());
        }

        // 4. Mappatura Rotta
        if (trip.getRoute() != null) {
            dto.setRoute(routeMapper.toDTO(trip.getRoute()));
        }

        return dto;
    }

    // Mappatura interna della richiesta
    public TransportRequestResponseDTO toRequestDTO(TransportRequest entity) {
        if (entity == null) return null;

        TransportRequestResponseDTO dto = new TransportRequestResponseDTO();
        dto.setId(entity.getId());
        dto.setOriginAddress(entity.getOriginAddress());
        dto.setDestinationAddress(entity.getDestinationAddress());
        dto.setPickupDate(entity.getPickupDate());
        dto.setRequestStatus(entity.getRequestStatus());

        if (entity.getClient() != null) {
            dto.setClientId(entity.getClient().getId());
            dto.setClientFullName(entity.getClient().getFirstName() + " " + entity.getClient().getLastName());
        }

        if (entity.getLoad() != null) {
            TransportRequestResponseDTO.LoadDetailsDTO loadDto = new TransportRequestResponseDTO.LoadDetailsDTO();
            loadDto.setType(entity.getLoad().getType());
            loadDto.setWeightKg(entity.getLoad().getWeightKg());
            loadDto.setHeight(entity.getLoad().getHeight());
            loadDto.setLength(entity.getLoad().getLength());
            loadDto.setWidth(entity.getLoad().getWidth());
            dto.setLoad(loadDto);
        }

        return dto;
    }
}