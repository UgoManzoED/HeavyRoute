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
 * Controller REST per la gestione operativa dei viaggi.
 * Base URL: /api/trips
 */
@Slf4j
@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripManagementController {

    private final TripService tripService;

    // ================== ENDPOINT DI LETTURA ==================

    /**
     * Endpoint: GET /api/trips
     * Recupera TUTTI i viaggi (Coordinator + Planner)
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'TRAFFIC_COORDINATOR')")
    public ResponseEntity<List<TripResponseDTO>> getAllTrips() {
        log.info("GET /api/trips invocato");
        return ResponseEntity.ok(tripService.getAllTrips());
    }

    /**
     * Endpoint: GET /api/trips/planning
     * Recupera solo i viaggi IN_PLANNING (Planner Dashboard)
     */
    @GetMapping("/planning")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<TripResponseDTO>> getTripsToPlan() {
        return ResponseEntity.ok(tripService.getTripsByStatus(TripStatus.IN_PLANNING));
    }

    /**
     * Endpoint: GET /api/trips/ping
     * Debug semplice per testare la connessione
     */
    @GetMapping("/ping")
    public String ping() {
        return "Pong! Il controller risponde correttamente su /api/trips/ping";
    }

    // ================== ENDPOINT DI SCRITTURA ==================

    /**
     * Endpoint: POST /api/trips/{requestId}/approve
     * Planner approva la richiesta -> Crea Viaggio
     */
    @PostMapping("/{requestId}/approve")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<TripResponseDTO> approve(@PathVariable Long requestId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.approveRequest(requestId));
    }

    /**
     * Endpoint: PUT /api/trips/{tripId}/plan
     * Planner assegna Autista e Veicolo
     */
    @PutMapping("/{tripId}/plan")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<Void> planResources(
            @PathVariable Long tripId,
            @Valid @RequestBody TripAssignmentDTO dto) {
        dto.setTripId(tripId);
        tripService.planTrip(tripId, dto);
        return ResponseEntity.ok().build();
    }

    /**
     * Endpoint: POST /api/trips/{tripId}/route/approve
     * Coordinator valida la rotta
     */
    @PostMapping("/{tripId}/route/approve")
    @PreAuthorize("hasRole('TRAFFIC_COORDINATOR')")
    public ResponseEntity<Void> validateRoute(@PathVariable Long tripId) {
        log.info("Traffic Coordinator sta validando il viaggio ID: {}", tripId);
        tripService.validateRoute(tripId);
        return ResponseEntity.ok().build();
    }
}