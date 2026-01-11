package com.heavyroute.resources.service;

import com.heavyroute.resources.dto.RoadEventCreationDTO;
import com.heavyroute.resources.dto.RoadEventResponseDTO;
import com.heavyroute.resources.dto.VehicleCreationDTO;
import com.heavyroute.resources.dto.VehicleResponseDTO;

import java.util.List;

/**
 * Interfaccia di servizio per la gestione delle risorse aziendali e degli eventi stradali.
 * <p>
 * Coordina le operazioni sui veicoli e le segnalazioni di criticità sulla rete viaria.
 * </p>
 */
public interface ResourceService {

    /**
     * Registra un nuovo veicolo nel sistema.
     * @param dto Dati tecnici del veicolo.
     * @return {@link VehicleCreationDTO} Il veicolo creato.
     */
    VehicleResponseDTO createVehicle(VehicleCreationDTO dto);

    /**
     * Recupera l'elenco di tutti i veicoli della flotta.
     * @return Lista di {@link VehicleCreationDTO}.
     */
    List<VehicleResponseDTO> getAllVehicles();

    /**
     * Ricerca i mezzi attualmente disponibili e compatibili con le specifiche di un carico.
     * <p>
     * Questo metodo è fondamentale per il processo di pianificazione dei trasporti eccezionali,
     * permettendo di filtrare solo i veicoli con portata e dimensioni idonee.
     * </p>
     * @param weight Peso del carico (kg).
     * @param height Altezza del carico (m).
     * @param width Larghezza del carico (m).
     * @param length Lunghezza del carico (m).
     * @return Lista di {@link VehicleResponseDTO} filtrata.
     */
    List<VehicleResponseDTO> getAvailableCompatibleVehicles(Double weight, Double height, Double width, Double length);

    /**
     * Inserisce una nuova segnalazione stradale.
     * @param dto Dati dell'evento.
     * @return {@link RoadEventResponseDTO} L'evento creato.
     */
    RoadEventResponseDTO createRoadEvent(RoadEventCreationDTO dto);

    /**
     * Recupera tutti gli eventi stradali attualmente attivi.
     * @return Lista di {@link RoadEventResponseDTO}.
     */
    List<RoadEventResponseDTO> getActiveEvents();
}