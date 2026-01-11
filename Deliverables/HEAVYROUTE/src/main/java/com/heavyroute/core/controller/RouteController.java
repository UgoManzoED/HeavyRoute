package com.heavyroute.core.controller;

import com.heavyroute.core.dto.RouteResponseDTO;
import com.heavyroute.core.service.RouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/traffic-coordinator/routes")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;

    @GetMapping
    public ResponseEntity<List<RouteResponseDTO>> getProposedRoutes() {
        return ResponseEntity.ok(routeService.getProposedRoutes());
    }

    @PatchMapping("/{id}/validate")
    public ResponseEntity<Void> validateRoute(
            @PathVariable Long id,
            @RequestParam boolean approved) {
        routeService.validateRoute(id, approved);
        return ResponseEntity.ok().build();
    }
}