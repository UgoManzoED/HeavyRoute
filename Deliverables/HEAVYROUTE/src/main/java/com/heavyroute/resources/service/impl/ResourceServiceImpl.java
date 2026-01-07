package com.heavyroute.resources.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.resources.dto.*;
import com.heavyroute.resources.model.*;
import com.heavyroute.resources.repository.*;
import com.heavyroute.resources.service.ResourceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementazione concreta del servizio {@link ResourceService}.
 * <p>
 * Gestisce la persistenza e la validazione dei dati per i moduli Veicoli ed Eventi.
 * Utilizza {@link VehicleRepository} e {@link RoadEventRepository} per l'accesso ai dati.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class ResourceServiceImpl implements ResourceService {

    private final VehicleRepository vehicleRepository;
    private final RoadEventRepository eventRepository;

    @Override
    @Transactional
    public VehicleDTO createVehicle(VehicleDTO dto) {
        // Verifica unicità targa (Requisito ODD)
        if (vehicleRepository.existsByLicensePlate(dto.getLicensePlate())) {
            throw new BusinessRuleException("Veicolo già registrato con targa: " + dto.getLicensePlate());
        }

        Vehicle vehicle = Vehicle.builder()
                .licensePlate(dto.getLicensePlate())
                .model(dto.getModel())
                .maxLoadCapacity(dto.getMaxLoadCapacity())
                .maxHeight(dto.getMaxHeight())
                .maxWidth(dto.getMaxWidth())
                .maxLength(dto.getMaxLength())
                .status(dto.getStatus())
                .build();

        Vehicle saved = vehicleRepository.save(vehicle);
        return mapToVehicleDTO(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<VehicleDTO> getAllVehicles() {
        return vehicleRepository.findAll().stream()
                .map(this::mapToVehicleDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public RoadEventResponseDTO createRoadEvent(RoadEventCreateDTO dto) {
        RoadEvent event = RoadEvent.builder()
                .type(dto.getType())
                .severity(dto.getSeverity())
                .description(dto.getDescription())
                .location(new com.heavyroute.common.model.GeoLocation(dto.getLatitude(), dto.getLongitude()))
                .validFrom(dto.getValidFrom())
                .validTo(dto.getValidTo())
                .build();

        RoadEvent saved = eventRepository.save(event);
        return mapToEventResponseDTO(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RoadEventResponseDTO> getActiveEvents() {
        return eventRepository.findAll().stream()
                .filter(RoadEvent::isActive)
                .map(this::mapToEventResponseDTO)
                .collect(Collectors.toList());
    }

    // --- Helper Mappers (In produzione usare MapStruct) ---

    private VehicleDTO mapToVehicleDTO(Vehicle v) {
        return new VehicleDTO(v.getLicensePlate(), v.getModel(), v.getMaxLoadCapacity(),
                v.getMaxHeight(), v.getMaxWidth(), v.getMaxLength(), v.getStatus());
    }

    private RoadEventResponseDTO mapToEventResponseDTO(RoadEvent e) {
        RoadEventResponseDTO res = new RoadEventResponseDTO();
        res.setId(e.getId());
        res.setType(e.getType());
        res.setSeverity(e.getSeverity());
        res.setDescription(e.getDescription());
        res.setLatitude(e.getLocation().getLatitude());
        res.setLongitude(e.getLocation().getLongitude());
        res.setValidFrom(e.getValidFrom());
        res.setValidTo(e.getValidTo());
        res.setActive(e.isActive());
        res.setBlocking(e.isBlocking());
        return res;
    }
}