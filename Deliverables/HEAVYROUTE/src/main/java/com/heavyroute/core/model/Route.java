package com.heavyroute.core.model;

import com.heavyroute.common.model.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Entità che rappresenta i dettagli tecnici di un percorso calcolato.
 * <p>
 * Responsabilità: Memorizzazione dei dati metrici (distanza, durata) e
 * della geometria del percorso (polyline) per la visualizzazione e l'analisi.
 * </p>
 */
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Table(name = "routes")
public class Route extends BaseEntity {

    /**
     * La distanza totale del percorso calcolato, espressa in Chilometri.
     */
    @Column(name = "distance", nullable = false)
    private Double routeDistance;

    /**
     * La durata stimata del percorso, espressa in Minuti.
     */
    @Column(name = "duration", nullable = false)
    private Double routeDuration;

    /**
     * La stringa codificata che rappresenta la geometria del percorso.
     * <p>
     * Solitamente in formato Google Encoded Polyline Algorithm Format.
     * Viene mappata come TEXT per accomodare stringhe molto lunghe.
     * </p>
     */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String polyline;

}