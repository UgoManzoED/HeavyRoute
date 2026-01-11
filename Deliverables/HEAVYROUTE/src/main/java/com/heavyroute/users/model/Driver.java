package com.heavyroute.users.model;

import com.heavyroute.common.model.GeoLocation;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.users.enums.DriverStatus;
import com.heavyroute.users.enums.UserRole;
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
    private String licenseNumber;

    @Embedded
    private GeoLocation geoLocation;

    @Column(nullable = false)
    private DriverStatus driverStatus;

    @OneToOne
    @JoinColumn(name = "id_vehicle")
    private Vehicle vehicle;

    public boolean isFree() {
        return this.driverStatus.equals(DriverStatus.FREE);
    }

    public boolean isOnTheRoad() {
        return this.driverStatus.equals(DriverStatus.ON_THE_ROAD);
    }

    @Override
    public UserRole getRole(){ return UserRole.DRIVER;}
}