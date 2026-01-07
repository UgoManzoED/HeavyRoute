package com.heavyroute.resources.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.common.model.GeoLocation;
import com.heavyroute.resources.enums.EventSeverity;
import com.heavyroute.resources.enums.RoadEventType;
import com.heavyroute.users.model.Driver; // Per sapere chi ha segnalato
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import java.time.LocalDateTime;

/**
 * Entità che rappresenta un evento avverso o una segnalazione sulla rete stradale.
 * <p>
 * Gli eventi sono geolocalizzati e temporanei. Vengono utilizzati dal sistema di navigazione
 * per calcolare percorsi alternativi o stimare ritardi nelle consegne.
 * </p>
 */
@Entity
@Table(name = "road_events")
@Getter @Setter
@NoArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class RoadEvent extends BaseEntity {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoadEventType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EventSeverity severity;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "event_lat")),
            @AttributeOverride(name = "longitude", column = @Column(name = "event_lon"))
    })
    private GeoLocation location;

    /**
     * Data e ora di inizio validità dell'evento.
     * <p>
     * Per incidenti improvvisi, corrisponde al momento della creazione ({@code createdAt}).
     * Per lavori programmati (es. cantieri), indica quando la strada verrà effettivamente chiusa.
     * </p>
     */
    @Column(nullable = false)
    private LocalDateTime validFrom;

    /**
     * Data e ora in cui l'evento cessa di essere valido.
     * <p>
     * Se {@code null}, l'evento è considerato a tempo indeterminato (es. strada crollata)
     * finché non viene chiuso manualmente.
     * </p>
     */
    private LocalDateTime validTo;

    /**
     * Verifica se l'evento è attualmente in corso (finestra temporale attiva).
     * <p>
     * Un evento è attivo se:
     * 1. La data corrente è successiva o uguale alla data di inizio ({@code validFrom}).
     * 2. La data corrente è antecedente alla data di fine ({@code validTo}), oppure la data di fine è {@code null}.
     * </p>
     *
     * @return {@code true} se l'evento sta influenzando la viabilità in questo preciso istante.
     */
    public boolean isActive() {
        LocalDateTime now = LocalDateTime.now();

        boolean hasStarted = (validFrom == null) || !now.isBefore(validFrom);
        boolean hasNotEnded = (validTo == null) || now.isBefore(validTo);

        return hasStarted && hasNotEnded;
    }

    /** Verifica se l'evento richiede un ricalcolo immediato del percorso.
     * @return true se la gravità è CRITICAL.
     */
    public boolean isBlocking() {
        return this.severity.equals(EventSeverity.CRITICAL);
    }
}