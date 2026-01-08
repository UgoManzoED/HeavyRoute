package com.heavyroute.resources.service;

import com.heavyroute.resources.dto.VehicleDTO;

import java.util.List;

public interface VehicleService {
    /**
     * Restituisce la lista dei veicoli disponibili per una nuova missione.
     */
    List<VehicleDTO> findAvailableVehicles();
}