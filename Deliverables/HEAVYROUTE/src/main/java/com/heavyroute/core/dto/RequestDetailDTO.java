package com.heavyroute.core.dto;

import com.heavyroute.core.enums.RequestStatus;
import lombok.Data;
import java.time.LocalDate;

/**
 * Data Transfer Object (DTO) per la visualizzazione dei dettagli di una richiesta di trasporto.
 * <p>
 * Viene utilizzato per trasportare i dati dal backend verso il frontend nelle operazioni di
 * consultazione (es. "Visualizza stato richieste" per il Committente o "Dettaglio richiesta"
 * per il Pianificatore Logistico).
 * </p>
 * * @author Heavy Route Team
 */
@Data
public class RequestDetailDTO {

    private Long clientId;
    private String clientFullName;

    /**
     * Identificatore univoco della richiesta di trasporto nel sistema.
     * Corrisponde alla chiave primaria dell'entità di persistenza.
     */
    private Long id;

    /**
     * Indirizzo del punto di partenza del trasporto eccezionale.
     */
    private String originAddress;

    /**
     * Indirizzo della destinazione finale della merce.
     */
    private String destinationAddress;

    /**
     * Data programmata per il ritiro del carico.
     */
    private LocalDate pickupDate;

    /**
     * Stato attuale della richiesta nel flusso di lavoro (es. PENDING, APPROVED, REJECTED).
     * Essenziale per il feedback all'utente sullo stato di avanzamento della pratica.
     */
    private RequestStatus status;

    /**
     * Peso del carico espresso in chilogrammi.
     */
    private Double weight;

    /**
     * Altezza del carico in metri, comprensiva dell'eventuale ingombro del pianale.
     */
    private Double height;

    /**
     * Lunghezza complessiva del carico espressa in metri.
     */
    private Double length;

    /**
     * Larghezza complessiva del carico espressa in metri.
     */
    private Double width;
}