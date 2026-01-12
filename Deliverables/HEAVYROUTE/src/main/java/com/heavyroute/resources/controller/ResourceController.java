package com.heavyroute.resources.controller;

import com.heavyroute.resources.dto.*;
import com.heavyroute.resources.service.ResourceService;
import com.heavyroute.users.dto.UserResponseDTO;
import com.heavyroute.users.service.DriverService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller REST per la gestione delle risorse aziendali (Veicoli) e risorse umane (Autisti).
 * <p>
 * Espone endpoint per il recupero delle risorse disponibili necessarie
 * al processo di assegnazione viaggi (Dispatching).
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/api/resources")
@RequiredArgsConstructor
public class ResourceController {

    private final ResourceService resourceService;
    private final DriverService driverService; // Assicurati che questo sia iniettato!

    // ================= VEICOLI =================

    /**
     * Elenca TUTTI i veicoli (per la Fleet Tab).
     * @return Lista completa dei veicoli.
     */
    @GetMapping("/vehicles")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<VehicleResponseDTO>> listVehicles() {
        return ResponseEntity.ok(resourceService.getAllVehicles());
    }

    /**
     * Recupera SOLO i veicoli DISPONIBILI (per dropdown semplice).
     * <p>
     * Endpoint: GET /api/resources/vehicles/available
     * </p>
     * @return Lista veicoli con status AVAILABLE.
     */
    @GetMapping("/vehicles/available")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<VehicleResponseDTO>> listAvailableVehicles() {
        log.info("Richiesta veicoli disponibili ricevuta");
        return ResponseEntity.ok(resourceService.getAvailableVehicles());
    }

    /**
     * Filtro Intelligente: Veicoli disponibili E capaci di portare il carico.
     * @param weight Peso del carico.
     * @param height Altezza del carico.
     * @param width Larghezza del carico.
     * @param length Lunghezza del carico.
     * @return Lista veicoli compatibili.
     */
    @GetMapping("/vehicles/compatible")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<VehicleResponseDTO>> getCompatibleVehicles(
            @RequestParam(defaultValue = "0") Double weight,
            @RequestParam(defaultValue = "0") Double height,
            @RequestParam(defaultValue = "0") Double width,
            @RequestParam(defaultValue = "0") Double length) {
        return ResponseEntity.ok(resourceService.getAvailableCompatibleVehicles(weight, height, width, length));
    }

    // ================= AUTISTI =================

    /**
     * Recupera gli autisti con stato FREE.
     * <p>
     * Endpoint: GET /api/resources/drivers/available
     * </p>
     * @return Lista autisti liberi.
     */
    @GetMapping("/drivers/available")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<UserResponseDTO>> getAvailableDrivers() {
        log.info("Richiesta autisti liberi ricevuta");
        return ResponseEntity.ok(driverService.findAvailableDrivers());
    }

    // ================= EVENTI & ALTRO =================

    /**
     * Registra un nuovo veicolo nella flotta.
     * @param dto DTO di creazione veicolo.
     * @return Veicolo creato.
     */
    @PostMapping("/vehicles")
    public ResponseEntity<VehicleResponseDTO> addVehicle(@Valid @RequestBody VehicleCreationDTO dto) {
        return ResponseEntity.ok(resourceService.createVehicle(dto));
    }

    /**
     * Inserisce una segnalazione stradale.
     * @param dto DTO evento stradale.
     * @return Evento creato.
     */
    @PostMapping("/events")
    public ResponseEntity<RoadEventResponseDTO> reportEvent(@Valid @RequestBody RoadEventCreationDTO dto) {
        return ResponseEntity.ok(resourceService.createRoadEvent(dto));
    }

    /**
     * Recupera le segnalazioni stradali attive.
     * @return Lista eventi.
     */
    @GetMapping("/events/active")
    public ResponseEntity<List<RoadEventResponseDTO>> listActiveEvents() {
        return ResponseEntity.ok(resourceService.getActiveEvents());
    }
}