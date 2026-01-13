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
 * Questa classe espone gli endpoint API necessari per gestire il ciclo di vita dei viaggi,
 * servendo diversi attori del sistema:
 * <ul>
 * <li><b>Logistic Planner:</b> Visualizzazione globale, pianificazione risorse, approvazione richieste.</li>
 * <li><b>Traffic Coordinator:</b> Validazione delle rotte e monitoraggio.</li>
 * <li><b>Driver (App Mobile):</b> Visualizzazione assegnazioni e aggiornamento stato.</li>
 * </ul>
 * Base URL: {@code /api/trips}
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PATCH, RequestMethod.PUT})
public class TripManagementController {

    private final TripService tripService;

    // ================== ENDPOINT DI LETTURA ==================

    /**
     * Recupera TUTTI i viaggi presenti a sistema.
     * <p>
     * Utilizzato dalle dashboard amministrative (Planner e Coordinator) per avere
     * una visione d'insieme di tutte le operazioni.
     * </p>
     *
     * @return {@link ResponseEntity} contenente la lista completa dei {@link TripResponseDTO}.
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'TRAFFIC_COORDINATOR')")
    public ResponseEntity<List<TripResponseDTO>> getTrips(
            @RequestParam(required = false) TripStatus[] status
    ) {
        if (status != null && status.length > 0) {
            return ResponseEntity.ok(tripService.getTripsByStatuses(List.of(status)));
        }

        log.info("GET /api/trips invocato - Recupero lista completa");
        return ResponseEntity.ok(tripService.getAllTrips());
    }

    /**
     * Recupera solo i viaggi in stato {@code IN_PLANNING}.
     * <p>
     * Endpoint specifico per la "Worklist" del Planner, mostra solo i viaggi
     * che richiedono un intervento manuale per l'assegnazione delle risorse.
     * </p>
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
     * <b>Endpoint Mobile:</b> Utilizzato dall'applicazione Android/Flutter per mostrare
     * all'autista loggato solo le sue consegne pertinenti.
     * </p>
     *
     * @param driverId ID dell'autista loggato.
     * @return Lista cronologica dei viaggi assegnati a quell'autista.
     */
    @GetMapping("/driver/{driverId}")
    @PreAuthorize("hasAnyRole('DRIVER', 'LOGISTIC_PLANNER')")
    public ResponseEntity<List<TripResponseDTO>> getDriverTrips(@PathVariable Long driverId) {
        log.info("GET /api/trips/driver/{} - Recupero viaggi per autista", driverId);
        return ResponseEntity.ok(tripService.getTripsByDriver(driverId));
    }

    /**
     * Endpoint di servizio per testare la connettività e lo stato del controller.
     *
     * @return Messaggio di conferma "Pong".
     */
    @GetMapping("/ping")
    public String ping() {
        return "Pong! Il controller risponde correttamente su /api/trips/ping";
    }

    // ================== ENDPOINT DI SCRITTURA ==================

    /**
     * Aggiorna lo stato operativo di un viaggio.
     * <p>
     * <b>Endpoint Mobile:</b> Invocato dall'app autista per segnalare avanzamenti
     * (es. IN_TRANSIT, DELIVERED).
     * </p>
     *
     * @param tripId    ID del viaggio da aggiornare.
     * @param newStatus Nuovo stato come Stringa (es. "IN_TRANSIT").
     * @return 200 OK se l'operazione ha successo.
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
     * Approva una richiesta di trasporto trasformandola in un Viaggio effettivo.
     * <p>
     * Questo endpoint innesca il calcolo della rotta e la creazione del record Trip.
     * </p>
     *
     * @param requestId ID della richiesta di trasporto originale.
     * @return 201 Created con il DTO del nuovo viaggio.
     */
    @PostMapping("/{requestId}/approve")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<TripResponseDTO> approve(@PathVariable Long requestId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.approveRequest(requestId));
    }

    /**
     * Assegna le risorse (Autista e Veicolo) a un viaggio.
     * <p>
     * Esegue la validazione dei vincoli (disponibilità autista, capacità veicolo)
     * e aggiorna lo stato del viaggio.
     * </p>
     *
     * @param tripId        ID del viaggio da pianificare.
     * @param assignmentDTO DTO contenente ID Autista e Targa Veicolo.
     * @return 200 OK se l'assegnazione va a buon fine.
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
     * Permette al Traffic Coordinator di approvare o rifiutare una rotta calcolata.
     * <p>
     * Se approvata, il viaggio diventa confermato. Se rifiutata, viene richiesto un ricalcolo.
     * </p>
     *
     * @param tripId  ID del viaggio.
     * @param request Oggetto contenente l'esito (booleano) e il feedback testuale.
     * @return 200 OK.
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