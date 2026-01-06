package com.heavyroute.core.service;

import com.heavyroute.core.dto.PlanningDTO;
import com.heavyroute.core.dto.TripDTO;
import com.heavyroute.core.model.Trip;

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
     */
    TripDTO approveRequest(Long requestId);

    /**
     * Assegna le risorse operative (Autista, Veicolo) a un viaggio esistente.
     * <p>
     * Questo metodo valida la disponibilità delle risorse e aggiorna lo stato del viaggio.
     * </p>
     *
     * @param tripId L'ID del viaggio da pianificare.
     * @param dto I dati di pianificazione (driverId, vehiclePlate) validati dal TC.
     * @throws jakarta.persistence.EntityNotFoundException se il viaggio o l'autista non esistono.
     */
    void planTrip(Long tripId, PlanningDTO dto);

    /**
     * Recupera i dettagli di un viaggio per la visualizzazione.
     *
     * @param id L'identificativo del viaggio.
     * @return Un DTO arricchito con descrizioni utile al Frontend.
     */
    TripDTO getTrip(Long id);
}