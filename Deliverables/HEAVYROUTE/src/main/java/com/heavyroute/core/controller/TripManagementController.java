package com.heavyroute.core.controller;

import com.heavyroute.core.dto.PlanningDTO;
import com.heavyroute.core.dto.TripDTO;
import com.heavyroute.core.service.TripService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller REST per la gestione operativa dei viaggi.
 * <p>
 * Espone gli endpoint API consumati dal Frontend o da app.
 * Gestisce la mappatura delle richieste HTTP sui metodi del {@link TripService}.
 * </p>
 */

@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripManagementController {

    private final TripService tripService;

    /**
     * UC4: Approva una richiesta e genera il relativo viaggio.
     * <p>
     * Endpoint idempotente che avvia il ciclo di vita operativo.
     * Simula un controllo di sicurezza che in produzione verrebbe gestito
     * da Spring Security.
     * </p>
     *
     * @param requestId ID della richiesta da trasformare.
     * @return 200 OK con il JSON del viaggio appena creato.
     */
    @PostMapping("/{requestId}/approve")
    public ResponseEntity<TripDTO> approveTrip(@PathVariable Long requestId) {
        TripDTO createdTrip = tripService.approveRequest(requestId);
        return ResponseEntity.ok(createdTrip);
    }

    /**
     * UC4: Pianifica le risorse (Autista/Veicolo) per un viaggio.
     *
     * @param tripId L'ID del viaggio preso dal path dell'URL.
     * @param dto Il payload JSON contenente autista e targa.
     * L'annotazione {@code @Valid} attiva le validazioni definite nel DTO
     * (es. @NotNull, @NotBlank). Se falliscono, Spring lancia un 400 Bad Request
     * prima ancora di entrare nel metodo.
     * @return 200 OK (senza corpo) se l'operazione ha successo.
     */
    @PutMapping("/{tripId}/plan")
    public ResponseEntity<Void> planTripResources(
            @PathVariable Long tripId,
            @Valid @RequestBody PlanningDTO dto) {

        dto.setTripId(tripId);
        tripService.planTrip(tripId, dto);
        return ResponseEntity.ok().build();
    }

    /**
     * Recupera i dettagli di un singolo viaggio.
     *
     * @param id L'ID del viaggio.
     * @return 200 OK con il DTO, oppure 404 Not Found.
     */
    @GetMapping("/{id}")
    public ResponseEntity<TripDTO> getTrip(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.getTrip(id));
    }
}