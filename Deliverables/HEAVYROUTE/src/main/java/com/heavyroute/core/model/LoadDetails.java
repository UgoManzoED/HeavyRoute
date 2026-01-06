package com.heavyroute.core.model;

import jakarta.persistence.Embeddable;
import lombok.Data;

@Embeddable
@Data
public class LoadDetails {
    private Double weightKg; // [cite: 388, 1080]
    private Double height;   // [cite: 1081]
    private Double width;    // [cite: 1083]
    private Double length;   // [cite: 1082]
}
