package com.heavyroute.core.service;

import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.enums.TripStatus;

import java.util.List;

/**
 * Contratto della Logica di Business per la gestione dei Viaggi.
 * <p>
 * Questa interfaccia agisce da confine (boundary) tra il livello web (Controller)
 * e il livello di persistenza (Repository).
 * </p>
 */
public interface TripService {

    /**
     * Trasforma una "Richiesta di Trasporto" approvata in un "Viaggio" effettivo.
     *
     * @param requestId L'ID della richiesta pendente.
     * @return Il DTO del nuovo viaggio creato.
     */
    TripResponseDTO approveRequest(Long requestId);

    /**
     * Assegna le risorse operative (Autista, Veicolo) a un viaggio esistente.
     *
     * @param tripId L'ID del viaggio da pianificare.
     * @param dto I dati di pianificazione (driverId, vehiclePlate).
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
     *
     * @param status Lo stato dei viaggi da ricercare (es. IN_PLANNING).
     * @return Lista di DTO.
     */
    List<TripResponseDTO> getTripsByStatus(TripStatus status);

    /**
     * Recupera tutti i viaggi assegnati a uno specifico autista.
     * <p>
     * <b>Nuovo metodo per App Autista.</b>
     * </p>
     * @param driverId ID dell'autista.
     * @return Lista viaggi assegnati.
     */
    List<TripResponseDTO> getTripsByDriver(Long driverId);

    /**
     * Calcola e associa un percorso ottimale al viaggio.
     *
     * @param tripId L'ID del viaggio per cui calcolare il percorso.
     */
    void calculateRoute(Long tripId);

    /**
     * Recupera tutti i viaggi del sistema.
     */
    List<TripResponseDTO> getAllTrips();

    /**
     * Gestisce la validazione della rotta da parte del Coordinator.
     */
    void validateRoute(Long tripId, boolean isApproved, String feedback);

    /**
     * Aggiorna lo stato del viaggio (es. da IN_TRANSIT a DELIVERED).
     */
    void updateStatus(Long tripId, String newStatus);

    List<TripResponseDTO> getTripsByStatuses(List<TripStatus> statuses);
}