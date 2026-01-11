package com.heavyroute.resources.service.impl;

import com.heavyroute.resources.dto.VehicleCreationDTO;
import com.heavyroute.resources.dto.VehicleResponseDTO;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.resources.mapper.VehicleMapper;
import com.heavyroute.resources.service.VehicleService;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VehicleServiceImpl implements VehicleService {

    private final VehicleRepository vehicleRepository;
    private final VehicleMapper vehicleMapper;

    @Override
    @Transactional(readOnly = true)
    public List<VehicleResponseDTO> findAvailableVehicles() {
        // Recuperiamo i veicoli pronti all'uso
        List<Vehicle> entities = vehicleRepository.findAllByStatus(VehicleStatus.AVAILABLE);

        return vehicleMapper.toResponseDTOList(entities);
    }
}