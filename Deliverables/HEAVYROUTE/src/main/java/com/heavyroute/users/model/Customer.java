package com.heavyroute.users.model;

import com.heavyroute.users.enums.UserRole;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Rappresenta un cliente esterno (Azienda) che richiede trasporti eccezionali.
 * <p>
 * Gestisce i dati fiscali necessari per la fatturazione e la gestione degli ordini.
 * </p>
 */

@Getter
@Setter
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "customers")
public class Customer extends User {

    @Column(name = "company_name", nullable = false)
    private String companyName;

    @Column(name = "vat_number", nullable = false, unique = true, length = 11)
    private String vatNumber;

    @Column(nullable = false)
    private String pec;

    @Column(nullable = false)
    private String address;

    @Override
    public UserRole getRole(){ return UserRole.CUSTOMER;}
}