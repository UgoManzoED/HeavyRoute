package com.heavyroute.core.service;

import com.heavyroute.core.dto.TripAssignmentDTO;
import com.heavyroute.core.dto.TripResponseDTO;
import com.heavyroute.core.enums.TripStatus;

import java.util.List;

public interface TripService {

    TripResponseDTO approveRequest(Long requestId);

    void planTrip(Long tripId, TripAssignmentDTO dto);

    TripResponseDTO getTripById(Long id);

    List<TripResponseDTO> getTripsByStatus(TripStatus status);

    void calculateRoute(Long tripId);

    List<TripResponseDTO> getAllTrips();

    void validateRoute(Long tripId, boolean isApproved, String feedback);

    // --- NUOVO METODO ---
    void updateStatus(Long tripId, String newStatus);
}