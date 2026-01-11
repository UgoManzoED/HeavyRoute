package com.heavyroute.users.controller;

import com.heavyroute.users.dto.UserResponseDTO;
import com.heavyroute.users.service.DriverService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/drivers")
@RequiredArgsConstructor
public class DriverController {

    private final DriverService driverService;

    /**
     * Endpoint per recuperare gli autisti selezionabili per un nuovo viaggio.
     * OCL: currentUser.role == LOGISTIC_PLANNER
     */
    @GetMapping("/available")
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<UserResponseDTO>> getAvailableDrivers() {
        return ResponseEntity.ok(driverService.findAvailableDrivers());
    }
}