package com.heavyroute.resources.dto;

import com.heavyroute.resources.enums.EventSeverity;
import com.heavyroute.resources.enums.RoadEventType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Data Transfer Object (DTO) per la rappresentazione di un evento o segnalazione stradale.
 * <p>
 * Viene utilizzato per comunicare la presenza di ostacoli, pericoli o interruzioni
 * sulla rete viaria. Questi dati sono processati dal motore di navigazione per
 * garantire la sicurezza dei trasporti eccezionali.
 * </p>
 * * @author Heavy Route Team
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoadEventCreateDTO {

    /**
     * Tipologia dell'evento stradale (es. OBSTACLE,  ACCIDENT, CONSTRUCTION).
     * Definisce la natura dell'impedimento riscontrato.
     */
    @NotNull(message = "L'evento non puó essere nullo")
    private RoadEventType type;

    /**
     * Livello di gravità dell'evento (LOW, MEDIUM, CRITICAL).
     * Se la gravità è {@code CRITICAL}, l'evento è considerato bloccante e richiede
     * un ricalcolo immediato del percorso.
     */
    @NotNull(message = "Il livello di gravitá non puó essere nullo")
    private EventSeverity severity;

    /**
     * Descrizione testuale opzionale con dettagli aggiuntivi sulla segnalazione.
     */
    private String description;

    /**
     * Latitudine della posizione GPS in cui si è verificato l'evento.
     * Deve rispettare il vincolo OCL: [-90.0, 90.0].
     */
    @NotNull(message = "La latitudine è obbligatoria")
    @DecimalMin(value = "-90.0", message = "La latitudine deve essere compresa tra -90 e 90")
    @DecimalMax(value = "90.0", message = "La latitudine deve essere compresa tra -90 e 90")
    private Double latitude;

    /**
     * Longitudine della posizione GPS in cui si è verificato l'evento.
     * Deve rispettare il vincolo OCL: [-180.0, 180.0].
     */
    @NotNull(message = "La longitudine è obbligatoria")
    @DecimalMin(value = "-180.0", message = "La longitudine deve essere compresa tra -180 e 180")
    @DecimalMax(value = "180.0", message = "La longitudine deve essere compresa tra -180 e 180")
    private Double longitude;

    /**
     * Data e ora di inizio validità dell'evento.
     * <p>
     * Per incidenti improvvisi, corrisponde al momento della creazione ({@code createdAt}).
     * Per lavori programmati (es. cantieri), indica quando la strada verrà effettivamente chiusa.
     * </p>
     */
    @NotBlank(message = "la data di inizio validitá non deve essere nulla")
    private LocalDateTime validFrom;

    /**
     * Data e ora in cui l'evento cessa di essere valido.
     * <p>
     * Se {@code null}, l'evento è considerato a tempo indeterminato (es. strada crollata)
     * finché non viene chiuso manualmente.
     * </p>
     */
    private LocalDateTime validTo;


}