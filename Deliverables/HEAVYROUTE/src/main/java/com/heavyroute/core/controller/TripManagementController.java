package com.heavyroute.core.controller;

import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.service.TripService;
import com.heavyroute.core.enums.TripStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller REST per la gestione operativa dei viaggi (Trip Management).
 * <p>
 * Questa classe espone gli endpoint dedicati al <b>Pianificatore Logistico (PL)</b>.
 * Gestisce il ciclo di vita del viaggio dalla fase di approvazione della richiesta
 * fino all'assegnazione delle risorse (Autista e Veicolo).
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripManagementController {

    private final TripService tripService;

    /**
     * Approva una Richiesta di Trasporto e genera il relativo Viaggio.
     * <p>
     * Implementa l'operazione di transizione di stato da <i>Richiesta Commerciale</i>
     * a <i>Viaggio Operativo</i>.
     * </p>
     *
     * <ul>
     * <li><b>OCL Pre-condition:</b> L'utente corrente deve avere ruolo <code>LOGISTIC_PLANNER</code>.</li>
     * <li><b>OCL Pre-condition:</b> La richiesta deve essere in stato <code>PENDING</code>.</li>
     * </ul>
     *
     * @param requestId ID univoco della richiesta di trasporto da approvare.
     * @return <code>201 Created</code> contenente il DTO del viaggio appena generato (stato <code>IN_PLANNING</code>).
     * @throws com.heavyroute.common.exception.ResourceNotFoundException se la richiesta non esiste.
     */
    @PostMapping("/{requestId}/approve")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<TripResponseDTO> approve(@PathVariable Long requestId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.approveRequest(requestId));
    }

    /**
     * Assegna le risorse operative (Autista e Veicolo) a un viaggio esistente.
     * <p>
     * Questo endpoint finalizza la pianificazione verificando la disponibilità delle risorse
     * e la compatibilità tecnica (es. peso del carico vs portata veicolo).
     * </p>
     *
     * <ul>
     * <li><b>OCL Pre-condition:</b> L'utente corrente deve avere ruolo <code>LOGISTIC_PLANNER</code>.</li>
     * <li><b>Validazione Input:</b> Il DTO deve contenere ID autista e Targa veicolo non nulli (<code>@Valid</code>).</li>
     * </ul>
     *
     * @param tripId L'ID del viaggio da pianificare (preso dal path).
     * @param dto Oggetto JSON contenente le risorse selezionate.
     * @return <code>200 OK</code> se l'assegnazione avviene con successo.
     */
    @PutMapping("/{tripId}/plan")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<Void> planResources(
            @PathVariable Long tripId,
            @Valid @RequestBody TripAssignmentDTO dto) {

        // Assicuriamo coerenza tra URL e Body
        dto.setTripId(tripId);

        tripService.planTrip(tripId, dto);
        return ResponseEntity.ok().build();
    }

    /**
     * Recupera la lista dei viaggi in attesa di pianificazione ("Worklist").
     * <p>
     * Utilizzato per popolare la Dashboard del Pianificatore. Restituisce solo i viaggi
     * nello stato <code>IN_PLANNING</code> che necessitano di assegnazione risorse.
     * </p>
     *
     * @return Una lista di {@link TripResponseDTO} filtrata per stato operativo.
     */
    @GetMapping("/api/planning")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<TripResponseDTO>> getTripsToPlan() {
        return ResponseEntity.ok(tripService.getTripsByStatus(TripStatus.IN_PLANNING));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'TRAFFIC_COORDINATOR')")
    public ResponseEntity<List<TripResponseDTO>> getAllTrips() {
        log.info("📡 GET /api/trips invocato da utente autenticato");
        return ResponseEntity.ok(tripService.getAllTrips());
    }

    @GetMapping("/ping")
    public String ping() {
        return "Pong! Il controller funziona all'indirizzo /trips";
    }
}