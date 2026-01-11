package com.heavyroute.core.service;

import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.enums.TripStatus;

import java.util.List;

/**
 * Contratto della Logica di Business per la gestione dei Viaggi.
 * <p>
 * Questa interfaccia agisce da confine (boundary) tra il livello web (Controller)
 * e il livello di persistenza (Repository). Definisce le operazioni atomiche
 * che possono essere eseguite, garantendo l'integrità dei dati e il rispetto
 * delle regole aziendali.
 * </p>
 */
public interface TripService {

    /**
     * Trasforma una "Richiesta di Trasporto" approvata in un "Viaggio" effettivo.
     * <p>
     * Questo metodo incapsula la logica di transizione da una fase di vendita/richiesta
     * a una fase operativa.
     * </p>
     *
     * @param requestId L'ID della richiesta pendente (es. da un sistema CRM o modulo Request).
     * @return Il DTO del nuovo viaggio creato (Read Model), pronto per la visualizzazione.
     * @throws com.heavyroute.common.exception.ResourceNotFoundException se la richiesta non esiste
     * @throws com.heavyroute.common.exception.BusinessRuleException se la richiesta non è in stato PENDING
     */
    TripResponseDTO approveRequest(Long requestId);

    /**
     * Assegna le risorse operative (Autista, Veicolo) a un viaggio esistente.
     * <p>
     * Questo metodo valida la disponibilità delle risorse e aggiorna lo stato del viaggio.
     * </p>
     *
     * @param tripId L'ID del viaggio da pianificare.
     * @param dto I dati di pianificazione (driverId, vehiclePlate) validati dal TC.
     * @throws com.heavyroute.common.exception.ResourceNotFoundException se il viaggio non esiste
     * @throws com.heavyroute.common.exception.BusinessRuleException se il viaggio non è in pianificazione o le risorse non sono
     */
    void planTrip(Long tripId, TripAssignmentDTO dto);

    /**
     * Recupera i dettagli di un viaggio per la visualizzazione.
     *
     * @param id L'identificativo del viaggio.
     * @return Un DTO arricchito con descrizioni utile al Frontend.
     */
    TripResponseDTO getTripById(Long id);

    /**
     * Recupera una lista di viaggi filtrata per stato operativo.
     * <p>
     * Utilizzato principalmente per popolare le dashboard operative (es. Worklist del Pianificatore).
     * </p>
     *
     * @param status Lo stato dei viaggi da ricercare (es. IN_PLANNING).
     * @return Lista di DTO, vuota se non vengono trovati viaggi in quello stato.
     */
    List<TripResponseDTO> getTripsByStatus(TripStatus status);

    /**
     * Calcola e associa un percorso ottimale al viaggio.
     * <p>
     * Questo metodo invoca il motore di routing (simulato) e salva l'entità Route.
     * </p>
     *
     * @param tripId L'ID del viaggio per cui calcolare il percorso.
     */
    void calculateRoute(Long tripId);

    List<TripResponseDTO> getAllTrips();
}