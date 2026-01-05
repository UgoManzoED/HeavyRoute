package com.heavyroute.users.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@SuperBuilder
@Entity
@Table(name = "committenti")
public class Committente extends Utente {

    @Column(name = "ragione_sociale", nullable = false)
    private String ragioneSociale;

    @Column(name = "partita_iva", nullable = false, unique = true, length = 11)
    private String partitaIva;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false)
    private String cognome;

    @Column(nullable = false)
    private String pec;

    @Column(nullable = false)
    private String indirizzoSede;
}