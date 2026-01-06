package com.heavyroute.users.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 Operatore interno responsabile della gestione degli utenti interni.
 */

@Getter
@Setter
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "account_managers")
public class AccountManager extends InternalUser {

    @Override
    public UserRole getRole(){ return UserRole.ACCOUNT_MANAGER;}
}