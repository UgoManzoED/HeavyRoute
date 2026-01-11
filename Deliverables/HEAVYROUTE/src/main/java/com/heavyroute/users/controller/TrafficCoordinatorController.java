package com.heavyroute.users.controller;

import com.heavyroute.core.dto.RouteResponseDTO;
import com.heavyroute.users.service.TrafficCoordinatorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/traffic-coordinator")
@RequiredArgsConstructor
public class TrafficCoordinatorController {

    private final TrafficCoordinatorService trafficCoordinatorService;

    // Endpoint aggiornato con il nuovo DTO
    @GetMapping("/routes")
    public ResponseEntity<List<RouteResponseDTO>> getRoutesToValidate() {
        return ResponseEntity.ok(trafficCoordinatorService.getRoutesToValidate());
    }

    @PatchMapping("/routes/{id}/validate")
    public ResponseEntity<Void> validateRoute(
            @PathVariable Long id,
            @RequestParam boolean approved) {

        trafficCoordinatorService.validateRoute(id, approved);
        return ResponseEntity.ok().build();
    }
}