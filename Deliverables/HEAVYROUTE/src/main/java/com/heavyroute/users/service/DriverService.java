package com.heavyroute.users.service;

import com.heavyroute.users.dto.UserResponseDTO;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.model.Driver;

import java.util.List;

/**
 * Servizio per la gestione operativa degli Autisti.
 */
public interface DriverService {

    /**
     * Recupera la lista degli autisti disponibili (Stato: FREE).
     * Utilizzato dal Pianificatore Logistico per l'assegnazione dei viaggi.
     * * @return Lista di UserResponseDTO contenenti anagrafica e ID degli autisti liberi.
     */
    List<UserResponseDTO> findAvailableDrivers();

    /**
     * Recupera gli autisti in base al loro stato operativo (FREE, BUSY, etc.)
     */
    List<Driver> findByDriverStatus(DriverStatus status);
}