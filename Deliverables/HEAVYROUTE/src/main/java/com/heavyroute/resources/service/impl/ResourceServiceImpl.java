package com.heavyroute.resources.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.resources.dto.*;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.mapper.RoadEventMapper;
import com.heavyroute.resources.mapper.VehicleMapper;
import com.heavyroute.resources.model.RoadEvent;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.RoadEventRepository;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.resources.service.ResourceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementazione del servizio per la gestione delle risorse.
 */
@Service
@RequiredArgsConstructor
public class ResourceServiceImpl implements ResourceService {

    private final VehicleRepository vehicleRepository;
    private final RoadEventRepository eventRepository;
    private final VehicleMapper vehicleMapper;
    private final RoadEventMapper eventMapper;

    /**
     * {@inheritDoc}
     * <p>
     * <b>Logica di Business:</b> Verifica preventivamente l'esistenza della targa
     * per evitare violazioni di vincoli a livello DB.
     * </p>
     */
    @Override
    @Transactional
    public VehicleResponseDTO createVehicle(VehicleCreationDTO dto) {
        if (vehicleRepository.existsByLicensePlate(dto.getLicensePlate())) {
            throw new BusinessRuleException("Esiste già un veicolo con targa: " + dto.getLicensePlate());
        }

        Vehicle vehicle = vehicleMapper.toEntity(dto);
        Vehicle saved = vehicleRepository.save(vehicle);

        // USARE toResponseDTO PER AVERE L'ID
        return vehicleMapper.toResponseDTO(saved);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    @Transactional(readOnly = true)
    public List<VehicleResponseDTO> getAllVehicles() {
        return vehicleRepository.findAll().stream()
                .map(vehicleMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<VehicleResponseDTO> getAvailableCompatibleVehicles(Double weight, Double height, Double width, Double length) {
        return vehicleRepository.findCompatibleVehicles(weight, height, width, length, VehicleStatus.AVAILABLE)
                .stream()
                .map(vehicleMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * {@inheritDoc}
     * <p>
     * Salva una nuova segnalazione stradale geolocalizzata.
     * </p>
     */
    @Override
    @Transactional
    public RoadEventResponseDTO createRoadEvent(RoadEventCreationDTO dto) {
        RoadEvent event = eventMapper.toEntity(dto);
        RoadEvent saved = eventRepository.save(event);
        return eventMapper.toResponseDTO(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RoadEventResponseDTO> getActiveEvents() {
        return eventRepository.findAll().stream()
                .filter(RoadEvent::isActive)
                .map(eventMapper::toResponseDTO)
                .collect(Collectors.toList());
    }
}