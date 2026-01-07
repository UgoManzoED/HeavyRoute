package com.heavyroute.resources.service;

import com.heavyroute.resources.dto.RoadEventCreateDTO;
import com.heavyroute.resources.dto.RoadEventResponseDTO;
import com.heavyroute.resources.dto.VehicleDTO;
import java.util.List;

/**
 * Interfaccia di servizio per la gestione delle risorse aziendali e degli eventi stradali.
 * <p>
 * Coordina le operazioni sui veicoli (flotta) e le segnalazioni di criticità sulla rete viaria,
 * garantendo il rispetto dei vincoli di unicità e validità temporale.
 * </p>
 * * @author Heavy Route Team
 */
public interface ResourceService {

    /**
     * Registra un nuovo veicolo nel sistema.
     * * @param dto Dati tecnici del veicolo da censire.
     * @return {@link VehicleDTO} Il veicolo creato.
     * @throws com.heavyroute.common.exception.BusinessRuleException se la targa è già presente.
     */
    VehicleDTO createVehicle(VehicleDTO dto);

    /**
     * Recupera l'elenco di tutti i veicoli della flotta.
     * * @return Lista di {@link VehicleDTO}.
     */
    List<VehicleDTO> getAllVehicles();

    /**
     * Inserisce una nuova segnalazione stradale (incidente, cantiere, ecc.).
     * * @param dto Dati dell'evento geolocalizzato.
     * @return {@link RoadEventResponseDTO} L'evento creato con i campi calcolati (active, blocking).
     */
    RoadEventResponseDTO createRoadEvent(RoadEventCreateDTO dto);

    /**
     * Recupera tutti gli eventi stradali attualmente attivi che influenzano la viabilità.
     * * @return Lista di {@link RoadEventResponseDTO} filtrata per validità temporale.
     */
    List<RoadEventResponseDTO> getActiveEvents();
}