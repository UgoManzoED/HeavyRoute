package com.heavyroute.core.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

/**
 * Data Transfer Object (DTO) utilizzato per l'acquisizione dei dati durante la creazione
 * di una nuova richiesta di trasporto (FR8).
 * <p>
 * Questo oggetto incapsula le informazioni necessarie al Pianificatore Logistico per
 * valutare la fattibilità tecnica e classificare il trasporto come "eccezionale"
 * qualora superi i limiti del Codice della Strada.
 * </p>
 */
@Data
public class RequestCreationDTO {

    /**
     * Indirizzo completo del punto di origine per il ritiro del carico.
     * Corrisponde al campo 'Origine' del modulo di richiesta.
     */
    @NotBlank(message = "Indirizzo origine obbligatorio")
    private String originAddress;

    /**
     * Indirizzo completo della destinazione finale del trasporto.
     * Corrisponde al campo 'Destinazione' del modulo di richiesta.
     */
    @NotBlank(message = "Indirizzo destinazione obbligatorio")
    private String destinationAddress;

    /**
     * La data prevista per il ritiro della merce.
     * Deve essere una data futura rispetto al momento dell'inserimento.
     */
    @NotNull(message = "Data ritiro obbligatoria")
    @Future(message = "La data deve essere futura")
    private LocalDate pickupDate;

    /**
     * Descrizione sintetica della tipologia di merce (es. "Travi in cemento", "Macchinari").
     * Fondamentale per valutare la natura del trasporto e identificare il veicolo adatto.
     */
    @NotBlank(message = "Descrizione carico obbligatoria")
    private String loadType;

    /**
     * Peso totale del carico espresso in chilogrammi.
     * Utilizzato per verificare i limiti di carico assiale e strutturale.
     */
    @NotNull
    @Positive
    private Double weight;

    /**
     * Altezza massima del carico espressa in metri.
     * Parametro critico per la verifica del transito in gallerie e sottopassi.
     */
    @NotNull
    @Positive
    private Double height;

    /**
     * Lunghezza complessiva del carico espressa in metri.
     * (Corretto typo 'lenght' presente nel documento ODD 1.0).
     */
    @NotNull
    @Positive
    private Double length;

    /**
     * Larghezza massima del carico espressa in metri.
     * Determina la necessità di scorte tecniche obbligatorie.
     * (Corretto typo 'widht' presente nel documento ODD 1.0).
     */
    @NotNull
    @Positive
    private Double width;
}