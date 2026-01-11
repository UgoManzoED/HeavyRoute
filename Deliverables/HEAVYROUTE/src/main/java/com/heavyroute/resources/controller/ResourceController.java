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
 */
@RestController
@RequestMapping("/api/resources")
@RequiredArgsConstructor
public class ResourceController {

    private final ResourceService resourceService;

    /**
     * Registra un nuovo veicolo nella flotta.
     * Ritorna il DTO con l'ID generato.
     */
    @PostMapping("/vehicles")
    public ResponseEntity<VehicleResponseDTO> addVehicle(@Valid @RequestBody VehicleCreationDTO dto) {
        return ResponseEntity.ok(resourceService.createVehicle(dto));
    }

    /**
     * Elenca tutti i veicoli presenti nel sistema.
     */
    @GetMapping("/vehicles")
    public ResponseEntity<List<VehicleResponseDTO>> listVehicles() {
        return ResponseEntity.ok(resourceService.getAllVehicles());
    }

    /**
     * Recupera i veicoli disponibili che soddisfano i requisiti di carico specificati.
     */
    @GetMapping("/vehicles/compatible")
    public ResponseEntity<List<VehicleResponseDTO>> getCompatibleVehicles(
            @RequestParam Double weight,
            @RequestParam Double height,
            @RequestParam Double width,
            @RequestParam Double length) {
        return ResponseEntity.ok(resourceService.getAvailableCompatibleVehicles(weight, height, width, length));
    }

    /**
     * Inserisce una segnalazione stradale (es. dall'App Autista).
     */
    @PostMapping("/events")
    public ResponseEntity<RoadEventResponseDTO> reportEvent(@Valid @RequestBody RoadEventCreationDTO dto) {
        return ResponseEntity.ok(resourceService.createRoadEvent(dto));
    }

    /**
     * Recupera le segnalazioni stradali attualmente attive.
     */
    @GetMapping("/events/active")
    public ResponseEntity<List<RoadEventResponseDTO>> listActiveEvents() {
        return ResponseEntity.ok(resourceService.getActiveEvents());
    }
}