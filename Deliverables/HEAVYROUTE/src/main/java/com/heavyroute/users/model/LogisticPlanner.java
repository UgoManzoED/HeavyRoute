package com.heavyroute.users.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Operatore interno addetto alla pianificazione logistica dei viaggi.
 * <p>
 * Si occupa anche dell'assegnazione di autisti e veicoli alle richieste di trasporto.
 * </p>
 */

@Getter
@Setter
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "logistic_planners")
public class LogisticPlanner extends InternalUser {

    @Override
    public UserRole getRole(){ return UserRole.LOGISTIC_PLANNER;}
}