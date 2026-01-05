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
@Table(name = "autisti")
public class Autista extends Utente {

    @Column(nullable = false)
    private String numeroPatente;

    // Coordinate GPS per Geofencing
    private Double latitudine; //DA CAMBIARE
    private Double longitudine;

    @Column(nullable = false)
    private StatoAutista statoOperativo;

    @Column(name = "id_veicolo")
    private Long idVeicolo;

    public boolean isLibero() {
        return this.statoOperativo.equals(StatoAutista.LIBERO);
    }

    public boolean isInViaggio() {
        return this.statoOperativo.equals(StatoAutista.IN_VIAGGIO);
    }
}