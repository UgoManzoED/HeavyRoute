package com.heavyroute.core.controller;

import com.heavyroute.core.dto.RouteValidationRequest;
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

@Slf4j
@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripManagementController {

    private final TripService tripService;

    // ================== ENDPOINT DI LETTURA ==================

    @GetMapping
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'TRAFFIC_COORDINATOR')")
    public ResponseEntity<List<TripResponseDTO>> getAllTrips() {
        return ResponseEntity.ok(tripService.getAllTrips());
    }

    @GetMapping("/planning")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<TripResponseDTO>> getTripsToPlan() {
        return ResponseEntity.ok(tripService.getTripsByStatus(TripStatus.IN_PLANNING));
    }

    @GetMapping("/ping")
    public String ping() {
        return "Pong!";
    }

    // ================== ENDPOINT DI SCRITTURA ==================

    /**
     * NUOVO: Endpoint per l'Autista.
     * Aggiorna lo stato del viaggio (es. da IN_VIAGGIO a SCARICO_COMPLETATO).
     */
    @PatchMapping("/{tripId}/status")
    @PreAuthorize("hasAnyRole('DRIVER', 'LOGISTIC_PLANNER')")
    public ResponseEntity<Void> updateTripStatus(
            @PathVariable Long tripId,
            @RequestBody String newStatus) {

        log.info("Aggiornamento stato viaggio ID {}: {}", tripId, newStatus);
        tripService.updateStatus(tripId, newStatus);

        return ResponseEntity.ok().build();
    }

    @PostMapping("/{requestId}/approve")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<TripResponseDTO> approve(@PathVariable Long requestId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.approveRequest(requestId));
    }

    @PutMapping("/{tripId}/plan")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<Void> planResources(
            @PathVariable Long tripId,
            @Valid @RequestBody TripAssignmentDTO dto) {
        dto.setTripId(tripId);
        tripService.planTrip(tripId, dto);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{tripId}/route/approve")
    @PreAuthorize("hasRole('TRAFFIC_COORDINATOR')")
    public ResponseEntity<Void> validateRoute(@PathVariable Long tripId,
                                              @RequestBody RouteValidationRequest request) {
        tripService.validateRoute(tripId, request.getApproved(), request.getFeedback());
        return ResponseEntity.ok().build();
    }
}