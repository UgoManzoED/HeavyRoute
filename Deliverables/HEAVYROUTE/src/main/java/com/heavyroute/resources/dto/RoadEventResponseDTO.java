package com.heavyroute.resources.dto;

import com.heavyroute.resources.enums.EventSeverity;
import com.heavyroute.resources.enums.RoadEventType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Data Transfer Object (DTO) per la rappresentazione di un evento o segnalazione stradale.
 * <p>
 * Viene utilizzato come oggetto di risposta quando andiamo a modificare le informazioni
 * relative ad un evento.
 * </p>
 * * @author Heavy Route Team
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoadEventResponseDTO {

    /**
     * Identificatore univoco dell'evento.
     */
    private Long id;

    /**
     * Tipologia dell'evento stradale (es. OBSTACLE,  ACCIDENT, CONSTRUCTION).
     * Definisce la natura dell'impedimento riscontrato.
     */
    private RoadEventType type;

    /**
     * Livello di gravità dell'evento (LOW, MEDIUM, CRITICAL).
     * Se la gravità è {@code CRITICAL}, l'evento è considerato bloccante e richiede
     * un ricalcolo immediato del percorso.
     */
    private EventSeverity severity;

    /**
     * Descrizione testuale opzionale con dettagli aggiuntivi sulla segnalazione.
     */
    private String description;

    /**
     * Latitudine della posizione GPS in cui si è verificato l'evento.
     * Deve rispettare il vincolo OCL: [-90.0, 90.0].
     */
    private Double latitude;

    /**
     * Longitudine della posizione GPS in cui si è verificato l'evento.
     * Deve rispettare il vincolo OCL: [-180.0, 180.0].
     */
    private Double longitude;

    /**
     * Data e ora di inizio validità dell'evento.
     * <p>
     * Per incidenti improvvisi, corrisponde al momento della creazione ({@code createdAt}).
     * Per lavori programmati (es. cantieri), indica quando la strada verrà effettivamente chiusa.
     * </p>
     */
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
     * Indica se l'evento è attualmente attivo in base alla data di scadenza.
     * Campo calcolato utile per il filtraggio rapido lato frontend.
     */
    private boolean active;

    /**
     * Indica se l'evento blocca completamente il transito per la categoria del mezzo.
     * Derivato dalla severità {@code CRITICAL}.
     */
    private boolean blocking;
}