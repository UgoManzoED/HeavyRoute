package com.heavyroute.resources.controller;

import com.heavyroute.resources.dto.*;
import com.heavyroute.resources.service.ResourceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller REST per la gestione delle risorse aziendali (Veicoli) ed eventi stradali.
 * <p>
 * Espone API per il censimento dei mezzi e la visualizzazione delle criticità stradali.
 * </p>
 */
@RestController
@RequestMapping("/api/resources")
@RequiredArgsConstructor
public class ResourceController {

    private final ResourceService resourceService;

    /**
     * Registra un nuovo veicolo nella flotta.
     * * @param dto Dati validati del veicolo.
     * @return 200 OK con il veicolo creato.
     */
    @PostMapping("/vehicles")
    public ResponseEntity<VehicleDTO> addVehicle(@Valid @RequestBody VehicleDTO dto) {
        return ResponseEntity.ok(resourceService.createVehicle(dto));
    }

    /**
     * Elenca tutti i veicoli presenti nel sistema.
     * * @return Lista di tutti i veicoli.
     */
    @GetMapping("/vehicles")
    public ResponseEntity<List<VehicleDTO>> listVehicles() {
        return ResponseEntity.ok(resourceService.getAllVehicles());
    }

    /**
     * Inserisce una segnalazione stradale (es. dall'App Autista).
     * * @param dto Dati dell'evento.
     * @return 200 OK con i dettagli dell'evento creato.
     */
    @PostMapping("/events")
    public ResponseEntity<RoadEventResponseDTO> reportEvent(@Valid @RequestBody RoadEventCreateDTO dto) {
        return ResponseEntity.ok(resourceService.createRoadEvent(dto));
    }

    /**
     * Recupera le segnalazioni stradali attualmente attive.
     * * @return Lista di eventi filtrati.
     */
    @GetMapping("/events/active")
    public ResponseEntity<List<RoadEventResponseDTO>> listActiveEvents() {
        return ResponseEntity.ok(resourceService.getActiveEvents());
    }

    /**
     * Recupera i veicoli disponibili che soddisfano i requisiti di carico specificati.
     * <p>
     * Utilizzato nella fase di pianificazione risorse per filtrare automaticamente
     * i mezzi idonei al trasporto eccezionale richiesto.
     * </p>
     * @param weight Peso richiesto.
     * @param height Altezza richiesta.
     * @param width Larghezza richiesta.
     * @param length Lunghezza richiesta.
     * @return ResponseEntity con la lista dei veicoli compatibili.
     */
    @GetMapping("/vehicles/compatible")
    public ResponseEntity<List<VehicleDTO>> getCompatibleVehicles(
            @RequestParam Double weight,
            @RequestParam Double height,
            @RequestParam Double width,
            @RequestParam Double length) {
        return ResponseEntity.ok(resourceService.getAvailableCompatibleVehicles(weight, height, width, length));
    }
}