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

/**
 * Controller REST per la gestione operativa dei viaggi.
 * <p>
 * Espone endpoint per:
 * <ul>
 * <li>Lettura dei viaggi (Dashboard Planner e Coordinator)</li>
 * <li>Approvazione delle richieste di trasporto</li>
 * <li>Pianificazione delle risorse (Autista/Veicolo)</li>
 * <li>Validazione delle rotte</li>
 * <li>Aggiornamento stato operativo (App Autista)</li>
 * </ul>
 * Base URL: {@code /api/trips}
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripManagementController {

    private final TripService tripService;

    // ================== ENDPOINT DI LETTURA ==================

    /**
     * Recupera TUTTI i viaggi presenti a sistema.
     *
     * @return Lista completa dei DTO dei viaggi.
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'TRAFFIC_COORDINATOR')")
    public ResponseEntity<List<TripResponseDTO>> getAllTrips() {
        log.info("GET /api/trips invocato - Recupero lista completa");
        return ResponseEntity.ok(tripService.getAllTrips());
    }

    /**
     * Recupera solo i viaggi in stato {@code IN_PLANNING}.
     *
     * @return Lista dei viaggi in attesa di pianificazione.
     */
    @GetMapping("/planning")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<TripResponseDTO>> getTripsToPlan() {
        return ResponseEntity.ok(tripService.getTripsByStatus(TripStatus.IN_PLANNING));
    }

    /**
     * Recupera i viaggi assegnati a uno specifico Autista.
     * <p>
     * Endpoint dedicato all'App Mobile dell'Autista.
     * </p>
     *
     * @param driverId ID dell'autista loggato.
     * @return Lista dei viaggi assegnati.
     */
    @GetMapping("/driver/{driverId}")
    @PreAuthorize("hasAnyRole('DRIVER', 'LOGISTIC_PLANNER')")
    public ResponseEntity<List<TripResponseDTO>> getDriverTrips(@PathVariable Long driverId) {
        log.info("GET /api/trips/driver/{} - Recupero viaggi per autista", driverId);
        return ResponseEntity.ok(tripService.getTripsByDriver(driverId));
    }

    /**
     * Endpoint di servizio per testare la connettività.
     */
    @GetMapping("/ping")
    public String ping() {
        return "Pong! Il controller risponde correttamente su /api/trips/ping";
    }

    // ================== ENDPOINT DI SCRITTURA ==================

    /**
     * Aggiorna lo stato operativo di un viaggio.
     *
     * @param tripId    ID del viaggio.
     * @param newStatus Nuovo stato (Stringa che deve corrispondere a un enum valido).
     * @return 200 OK se l'aggiornamento ha successo.
     */
    @PatchMapping("/{tripId}/status")
    @PreAuthorize("hasAnyRole('DRIVER', 'LOGISTIC_PLANNER')")
    public ResponseEntity<Void> updateTripStatus(
            @PathVariable Long tripId,
            @RequestBody String newStatus) {

        log.info("Aggiornamento stato richiesto per Trip ID {}: {}", tripId, newStatus);
        tripService.updateStatus(tripId, newStatus);

        return ResponseEntity.ok().build();
    }

    /**
     * Approva una richiesta di trasporto trasformandola in un Viaggio.
     */
    @PostMapping("/{requestId}/approve")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<TripResponseDTO> approve(@PathVariable Long requestId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.approveRequest(requestId));
    }

    /**
     * Assegna le risorse (Autista e Veicolo) a un viaggio.
     */
    @PutMapping("/{tripId}/plan")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<Void> planResources(
            @PathVariable Long tripId,
            @Valid @RequestBody TripAssignmentDTO assignmentDTO) {

        log.info("Pianificazione risorse per Trip ID {}: Driver={}, Vehicle={}",
                tripId, assignmentDTO.getDriverId(), assignmentDTO.getVehiclePlate());

        tripService.planTrip(tripId, assignmentDTO);

        return ResponseEntity.ok().build();
    }

    /**
     * Permette al Coordinator di approvare o rifiutare una rotta.
     */
    @PostMapping("/{tripId}/route/approve")
    @PreAuthorize("hasRole('TRAFFIC_COORDINATOR')")
    public ResponseEntity<Void> validateRoute(
            @PathVariable Long tripId,
            @RequestBody RouteValidationRequest request) {

        log.info("Decisione Coordinator per viaggio ID {}: Approved = {}, Feedback = {}",
                tripId, request.getApproved(), request.getFeedback());

        tripService.validateRoute(tripId, request.getApproved(), request.getFeedback());

        return ResponseEntity.ok().build();
    }
}