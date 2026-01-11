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
public class TransportRequestResponseDTO {

    /**
     * ID univoco del cliente (Committente) che ha inserito la richiesta.
     * Utile per navigare al profilo del cliente o per operazioni di filtro.
     */
    private Long clientId;

    /**
     * Nome completo o Ragione Sociale del cliente.
     * Campo denormalizzato per visualizzare il mittente nelle liste senza query aggiuntive.
     */
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
    private RequestStatus requestStatus;

    /**
     * Raggruppamento dei dettagli fisici del carico (Dimensioni e Peso).
     */
    private LoadDetailsDTO load;

    @Data
    public static class LoadDetailsDTO {
        /**
         * Descrizione sintetica della natura della merce (es. "Travi in cemento").
         */
        private String type;
        /**
         * Peso totale del carico in chilogrammi (kg).
         */
        private Double weightKg;
        /**
         * Altezza massima del carico in metri (m).
         */
        private Double height;
        /**
         * Lunghezza totale del carico in metri (m).
         */
        private Double length;
        /**
         * Larghezza massima del carico in metri (m).
         */
        private Double width;
    }
}