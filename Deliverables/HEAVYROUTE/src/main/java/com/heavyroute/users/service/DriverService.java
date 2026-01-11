package com.heavyroute.users.service;

import com.heavyroute.users.dto.UserResponseDTO;

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
}