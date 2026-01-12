package com.heavyroute.core.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.common.model.GeoLocation;
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
     * Descrizione testuale del percorso.
     * Utile per la UI.
     */
    @Column(name = "description")
    private String description;

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

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "start_lat")),
            @AttributeOverride(name = "longitude", column = @Column(name = "start_lon"))
    })
    private GeoLocation startLocation;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "end_lat")),
            @AttributeOverride(name = "longitude", column = @Column(name = "end_lon"))
    })
    private GeoLocation endLocation;

    /**
     * Riferimento inverso al viaggio che utilizza questo percorso.
     */
    @OneToOne(mappedBy = "route")
    private Trip trip;
}