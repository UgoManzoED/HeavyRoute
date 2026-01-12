package com.heavyroute.core.dto;

import com.heavyroute.core.enums.TripStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TripResponseDTO {

    private Long id;
    private String tripCode;
    private TripStatus status;

    // --- DATI AUTISTA (Arricchiti) ---
    private Long driverId;
    private String driverName;     // Es. "Mario"
    private String driverSurname;  // NUOVO: Es. "Rossi"
    private String currentLocation; // NUOVO: Es. "A1 - km 45" (Opzionale)
    // ---------------------------------

    private String vehiclePlate;
    private String vehicleModel;

    private TransportRequestResponseDTO request;

    private Long clientId;
    private String clientFullName;

    private RouteResponseDTO route;
}