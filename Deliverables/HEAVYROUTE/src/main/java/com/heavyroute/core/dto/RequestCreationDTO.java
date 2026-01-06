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
 * * @author Heavy Route Team
 */
@Data
public class RequestCreationDTO {

    /**
     * Indirizzo completo del punto di origine per il ritiro del carico.
     * Corrisponde al campo 'Origine' del modulo di richiesta.
     */
    @NotBlank
    private String originAddress;

    /**
     * Indirizzo completo della destinazione finale del trasporto.
     * Corrisponde al campo 'Destinazione' del modulo di richiesta.
     */
    @NotBlank
    private String destinationAddress;

    /**
     * La data prevista per il ritiro della merce.
     * Deve essere una data futura rispetto al momento dell'inserimento.
     */
    @NotNull
    @Future
    private LocalDate pickupDate;

    /**
     * Peso totale del carico espresso in chilogrammi.
     * Utilizzato per verificare i limiti di carico assiale e strutturale.
     */
    @Positive
    private Double weight;

    /**
     * Altezza massima del carico espressa in metri.
     * Parametro critico per la verifica del transito in gallerie e sottopassi.
     */
    @Positive
    private Double height;

    /**
     * Lunghezza complessiva del carico espressa in metri.
     * (Corretto typo 'lenght' presente nel documento ODD 1.0).
     */
    @Positive
    private Double length;

    /**
     * Larghezza massima del carico espressa in metri.
     * Determina la necessità di scorte tecniche obbligatorie.
     * (Corretto typo 'widht' presente nel documento ODD 1.0).
     */
    @Positive
    private Double width;
}