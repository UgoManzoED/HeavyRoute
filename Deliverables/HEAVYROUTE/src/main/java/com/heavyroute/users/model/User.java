package com.heavyroute.users.model;

import com.heavyroute.common.model.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Entità fondamentale che rappresenta un qualsiasi utente registrato nel sistema.
 * <p>
 * Gestisce le credenziali di accesso e i dati anagrafici di base.
 * Utilizza la strategia {@code JOINED} per permettere una specializzazione pulita
 * tra clienti esterni e personale interno nelle tabelle del database.
 * </p>
 */

@Getter
@Setter
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.JOINED) // Strategia ottimale per l'ODD
public abstract class User extends BaseEntity {

    @Column(nullable = false)
    protected String firstName;

    @Column(nullable = false)
    protected String lastName;

    @Column(nullable = false, unique = true)
    protected String username;

    @Column(nullable = false)
    protected String password;

    @Column(nullable = false, unique = true)
    protected String email;

    @Column(name = "phone_number", length = 20, nullable = false)
    protected String phoneNumber;

    @Column(nullable=false)
    protected boolean active=false;

    // Metodo di utilità per il login
    public boolean hasRole(UserRole r) {
        return this.getRole() == r;
    }

    /**
     * Metodo astratto per recuperare il ruolo specifico associato all'istanza dell'utente.
     * <p>
     * Questo metodo permette il polimorfismo tra le diverse tipologie di utenti
     * (Customer, Driver, etc.) senza dover ricorrere a controlli manuali sul tipo (instanceof).
     * </p>
     * @return l'oggetto {@link UserRole} che identifica i permessi dell'utente nel sistema.
     */
    public abstract UserRole getRole();
}