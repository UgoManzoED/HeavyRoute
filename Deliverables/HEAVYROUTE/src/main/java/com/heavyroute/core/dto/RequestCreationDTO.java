package com.heavyroute.core.dto;

import jakarta.validation.constraints.*;
import lombok.Data;


@Data
public class RequestCreationDTO {
    @NotBlank private String origin;
    @NotBlank private String destination;

    @NotNull
    @Future
    private String pickupDate;

    @Positive private Double weight;
    @Positive private Double height;
    @Positive private Double length;
    @Positive private Double width;
}

