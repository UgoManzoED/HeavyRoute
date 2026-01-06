package com.heavyroute.core.dto;

import com.heavyroute.core.enums.RequestStatus;
import lombok.Data;


@Data
public class RequestDetailDTO {
    private Long id;
    private String originAddress;
    private String destinationAddress;
    private String pickupDate;
    private RequestStatus status;
    private Double weight;
}

