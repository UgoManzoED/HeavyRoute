package com.heavyroute.core.service;

import com.heavyroute.core.dto.RouteResponseDTO;
import java.util.List;

/**
 * Service Interface per la gestione della logica di business relativa ai percorsi.
 */
public interface RouteService {

    /**
     * Recupera tutti i percorsi che necessitano di validazione da parte del Traffic Coordinator.
     * Solitamente sono quelli con stato PENDING.
     */
    List<RouteResponseDTO> getProposedRoutes();

    /**
     * Aggiorna lo stato di un percorso (Approva o Rifiuta).
     *
     * @param routeId L'ID della route da aggiornare.
     * @param isApproved true per approvare, false per rifiutare.
     */
    void validateRoute(Long routeId, boolean isApproved);
}