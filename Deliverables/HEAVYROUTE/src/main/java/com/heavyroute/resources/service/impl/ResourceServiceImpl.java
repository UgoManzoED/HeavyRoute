package com.heavyroute.resources.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.resources.dto.*;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.service.RoadEventMapper;
import com.heavyroute.resources.service.VehicleMapper;
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
 * Implementazione del servizio per la gestione delle risorse (Veicoli ed Eventi Stradali).
 * <p>
 * Questa classe orchestra l'interazione tra i repository e i mapper, applicando le
 * regole di business definite nell'ODD, come il controllo di unicità della targa
 * e la verifica della compatibilità dei mezzi.
 * </p>
 * * @author Heavy Route Team
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
    public VehicleDTO createVehicle(VehicleDTO dto) {
        if (vehicleRepository.existsByLicensePlate(dto.getLicensePlate())) {
            throw new BusinessRuleException("Esiste già un veicolo con targa: " + dto.getLicensePlate());
        }

        Vehicle vehicle = vehicleMapper.toEntity(dto);
        Vehicle saved = vehicleRepository.save(vehicle);
        return vehicleMapper.toDTO(saved);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    @Transactional(readOnly = true)
    public List<VehicleDTO> getAllVehicles() {
        return vehicleRepository.findAll().stream()
                .map(vehicleMapper::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * {@inheritDoc}
     * <p>
     * Ricerca i mezzi che soddisfano i criteri tecnici e hanno stato {@code AVAILABLE}.
     * </p>
     */

    @Transactional(readOnly = true)
    public List<VehicleDTO> getAvailableCompatibleVehicles(Double weight, Double height, Double width, Double length) {
        return vehicleRepository.findCompatibleVehicles(weight, height, width, length, VehicleStatus.AVAILABLE)
                .stream()
                .map(vehicleMapper::toDTO)
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
    public RoadEventResponseDTO createRoadEvent(RoadEventCreateDTO dto) {
        RoadEvent event = eventMapper.toEntity(dto);
        RoadEvent saved = eventRepository.save(event);
        return eventMapper.toResponseDTO(saved);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Recupera solo le segnalazioni attive basandosi sulla finestra temporale
     * {@code validFrom} - {@code validTo}.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public List<RoadEventResponseDTO> getActiveEvents() {
        return eventRepository.findAll().stream()
                .filter(RoadEvent::isActive)
                .map(eventMapper::toResponseDTO)
                .collect(Collectors.toList());
    }
}