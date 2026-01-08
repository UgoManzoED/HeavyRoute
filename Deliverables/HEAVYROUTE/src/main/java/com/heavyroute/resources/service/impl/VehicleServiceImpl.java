package com.heavyroute.resources.service.impl;

import com.heavyroute.resources.dto.VehicleDTO;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.resources.service.VehicleMapper;
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
    public List<VehicleDTO> findAvailableVehicles() {
        // Recuperiamo i veicoli pronti all'uso (AVAILABLE)
        List<Vehicle> entities = vehicleRepository.findAllByStatus(VehicleStatus.AVAILABLE);

        // Trasformiamo la lista usando il nuovo mapper
        return vehicleMapper.toDTOList(entities);
    }
}