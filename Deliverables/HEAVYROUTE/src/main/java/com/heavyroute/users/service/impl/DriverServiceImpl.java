package com.heavyroute.users.service.impl;

import com.heavyroute.users.dto.UserResponseDTO;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;
import com.heavyroute.users.repository.DriverRepository;
import com.heavyroute.users.service.DriverService;
import com.heavyroute.users.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementazione del servizio dedicato alla gestione operativa delle risorse Autista (Driver).
 * <p>
 * Questa classe si occupa di gestire il ciclo di vita operativo degli autisti, fornendo
 * i dati necessari alla pianificazione logistica e garantendo il disaccoppiamento tra
 * il livello di persistenza e il livello di presentazione tramite l'uso di DTO.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class DriverServiceImpl implements DriverService {

    private final DriverRepository driverRepository;
    private final UserMapper userMapper;

    /**
     * Recupera la lista di tutti gli autisti attualmente disponibili per l'assegnazione.
     * <p>
     * Un autista è considerato disponibile quando il suo stato operativo è {@link DriverStatus#FREE}.
     * Il metodo utilizza la Stream API per convertire le entità {@link Driver} in {@link UserResponseDTO},
     * esponendo solo le informazioni anagrafiche necessarie per popolare i componenti UI (dropdown).
     * </p>
     * <p>
     * <b>Nota tecnica:</b> L'annotazione {@code @Transactional(readOnly = true)} ottimizza
     * la query su database evitando l'esecuzione del dirty checking di Hibernate.
     * </p>
     *
     * @return Una lista di {@link UserResponseDTO} rappresentante gli autisti liberi.
     * Restituisce una lista vuota se non sono presenti autisti con stato FREE.
     */
    @Override
    @Transactional(readOnly = true)
    public List<UserResponseDTO> findAvailableDrivers() {
        // Recupera le entità dal repository filtrando per stato operativo
        // Nota: Assicurati che nel Repository il metodo si chiami 'findByDriverStatus'
        List<Driver> freeDrivers = driverRepository.findByDriverStatus(DriverStatus.FREE);

        // Converte la collezione di entità in una lista di DTO tramite mapping
        return freeDrivers.stream()
                .map(userMapper::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<Driver> findByDriverStatus(DriverStatus status) {
        return List.of();
    }
}