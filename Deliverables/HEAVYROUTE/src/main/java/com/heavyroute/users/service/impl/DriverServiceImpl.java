package com.heavyroute.users.service.impl;

import com.heavyroute.users.dto.UserDTO;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.repository.DriverRepository;
import com.heavyroute.users.service.DriverService;
import com.heavyroute.users.dto.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DriverServiceImpl implements DriverService {

    private final DriverRepository driverRepository;
    private final UserMapper userMapper;

    @Override
    @Transactional(readOnly = true)
    public List<UserDTO> findAvailableDrivers() {
        // Recupero gli autisti con lo stato FREE (metodo già presente nel tuo repository)
        List<Driver> freeDrivers = driverRepository.findAllByStatus(DriverStatus.FREE);

        // Convertiamo la lista di Driver in UserDTO tramite il mapper esistente
        // Nota: Il mapper gestisce Driver perché estende User
        return userMapper.toDTOList((List) freeDrivers);
    }
}