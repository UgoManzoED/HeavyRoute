package com.heavyroute.users.model;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Rappresenta un conducente di mezzi pesanti all'interno del sistema.
 * <p>
 * Include il riferimento al veicolo assegnato e la posizione GPS corrente
 * per il monitoraggio dei viaggi in corso.
 * </p>
 */

@Getter
@Setter
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "drivers")
public class Driver extends InternalUser {

    @Column(nullable = false)
    private String license;

    @Embedded
    private GeoLocation geoLocation;

    @Column(nullable = false)
    private DriverStatus status;

    @OneToOne
    @JoinColumn(name = "id_vehicle")
    private Vehicle vehicle;

    public boolean isFree() {
        return this.status.equals(DriverStatus.FREE);
    }

    public boolean isOnTheRoad() {
        return this.status.equals(DriverStatus.ON_THE_ROAD);
    }

    @Override
    public UserRole getRole(){ return UserRole.DRIVER;}
}