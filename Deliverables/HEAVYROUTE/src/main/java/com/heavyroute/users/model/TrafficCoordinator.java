package com.heavyroute.users.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Membro dello staff addetto alla validazione dei percorsi e permessi.
 */

@Getter
@Setter
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "traffic_coordinators")
public class TrafficCoordinator extends InternalUser {

    @Override
    public UserRole getRole(){ return UserRole.TRAFFIC_COORDINATOR;}
}