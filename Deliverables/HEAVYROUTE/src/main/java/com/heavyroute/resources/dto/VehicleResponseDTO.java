package com.heavyroute.resources.dto;

import com.heavyroute.resources.enums.VehicleStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VehicleResponseDTO {

    private Long id;

    private String licensePlate;
    private String model;

    private Double maxLoadCapacity;
    private Double maxHeight;
    private Double maxWidth;
    private Double maxLength;

    private VehicleStatus status;

    // Helper per il frontend
    private boolean available;
    private boolean inMaintenance;
}