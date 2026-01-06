package com.heavyroute.core.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per la visualizzazione dei dettagli di un viaggio.
 * <p>
 * Questa classe rappresenta un "Read Model": è ottimizzata per la lettura da parte del client (Frontend/App).
 * A differenza dell'Entity, contiene dati "denormalizzati" o "appiattiti" (es. nomi autisti, modelli veicoli)
 * per evitare che il client debba effettuare chiamate aggiuntive ad altri microservizi o endpoint.
 * </p>
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TripDTO {

    /**
     * Identificativo tecnico del database.
     * Utile per operazioni di update/delete o per i link REST (HATEOAS).
     */
    private Long id;

    /**
     * Codice business leggibile.
     * È l'identificativo principale mostrato nelle interfacce utente.
     */
    private String tripCode;

    /**
     * Stato corrente del viaggio serializzato come stringa (es. "IN_PLANNING").
     * <p>
     * Viene esposto come String (e non come Enum) per disaccoppiare il contratto API:
     * se l'Enum interno cambia o viene rinominato, la stringa qui può essere mappata o mantenuta
     * per retrocompatibilità verso i client vecchi.
     * </p>
     */
    private String status;

    // --- DATI ARRICCHITI (ENRICHED DATA) ---

    /**
     * ID dell'autista (riferimento tecnico).
     * Corrisponde al campo 'driverId' dell'Entity.
     */
    private Long driverId;

    /**
     * Nome completo dell'autista (Dato arricchito).
     * <p>
     * <b>Nota:</b> Questo campo NON esiste nella tabella 'trips'.
     * Il Mapper deve recuperarlo interrogando il {@code DriverService} o la cache
     * usando il {@code driverId}.
     * </p>
     */
    private String driverName;

    /**
     * Targa del veicolo.
     */
    private String vehiclePlate;

    /**
     * Modello del veicolo (Dato arricchito).
     * <p>
     * Utile per la UI (es. "Iveco Stralis"), permette all'operatore di riconoscere
     * il mezzo senza dover decifrare la targa.
     * Da popolare tramite {@code VehicleService}.
     * </p>
     */
    private String vehicleModel;

    /**
     * Dettagli completi della Richiesta di Trasporto che ha originato questo viaggio.
     * <p>
     * <b>Struttura JSON:</b> Nel payload di risposta, questi dati saranno raggruppati
     * sotto la chiave {@code "request"}, permettendo al Frontend di passare questo oggetto
     * direttamente a componenti UI dedicati (es. {@code <RequestSummaryCard data={trip.request} />}).
     * </p>
     */
    private RequestDetailDTO request;
}