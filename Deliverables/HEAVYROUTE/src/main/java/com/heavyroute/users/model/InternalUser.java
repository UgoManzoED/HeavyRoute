package com.heavyroute.users.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import java.time.LocalDate;

/**
 * Classe intermedia per il personale dipendente di Heavy Route.
 * <p>
 * Estende i dati dell'utente con informazioni professionali necessarie
 * alla gestione del personale interno (Staff).
 * </p>
 */

@Entity
@Table(name = "internal_users")
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public abstract class InternalUser extends User {

    protected String serialNumber;
    protected LocalDate hireDate;
}
