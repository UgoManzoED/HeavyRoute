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

    private LocalDateTime expiresAt; // Data e ora in cui l'evento cessa di essere valido.
    /** Verifica se l'evento è ancora in corso.
     * @return true se la data di scadenza è futura o nulla.
     */
    public boolean isActive() {
        return expiresAt == null || expiresAt.isAfter(LocalDateTime.now());
    }

    /** Verifica se l'evento richiede un ricalcolo immediato del percorso.
     * @return true se la gravità è CRITICAL.
     */
    public boolean isBlocking() {
        return this.severity.equals(EventSeverity.CRITICAL);
    }
}