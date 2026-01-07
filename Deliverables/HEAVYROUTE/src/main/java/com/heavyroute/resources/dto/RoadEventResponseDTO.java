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
 * Viene utilizzato come oggeto di risposta quando andiamo a modificare le informazioni
 * relaztive ad un evento.
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
     * Data e ora di scadenza prevista per l'evento.
     * Oltre questa data, la segnalazione non viene più considerata attiva dal sistema.
     */
    private LocalDateTime expiresAt;

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