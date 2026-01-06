package com.heavyroute.core.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.core.enums.RequestStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "transport-request")
@Getter
@Setter
public class TransportRequest extends BaseEntity{

    @Column(nullable = false, unique = true)
    private Long id;

    @Column(nullable = false, name = "origin_address")
    private String originAddress;

    @Column(nullable = false, name = "destiantion_address")
    private String destinationAddress;

    @Column(nullable = false, name = "pickUp_date")
    private String pickupDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestStatus requestStatus;

    @Embedded
    private LoadDetails load;

}
