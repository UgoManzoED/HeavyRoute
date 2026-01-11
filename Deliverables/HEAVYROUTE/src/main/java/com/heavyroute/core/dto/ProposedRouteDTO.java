package com.heavyroute.core.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO per la visualizzazione delle proposte di percorso nella dashboard del Traffic Coordinator.
 * <p>
 * Aggrega i dati tecnici dell'entità {@link com.heavyroute.core.model.Route}
 * con i dati contestuali del {@link com.heavyroute.core.model.Trip}.
 * </p>
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProposedRouteDTO {

    // --- Identificativi ---
    private Long id;              // ID della Route (o del Trip, a seconda della logica)
    private String orderId;       // Codice Ordine (es. "ORD-045")

    // --- Contesto ---
    private String plannerName;   // Nome del pianificatore (es. "Mario Bianchi")
    private String origin;        // Indirizzo partenza
    private String destination;   // Indirizzo arrivo
    private String loadType;      // Tipologia carico (es. "Carico Eccezionale")
    private String status;        // Stato approvazione (PENDING, APPROVED, REJECTED)

    // --- Dati Tecnici (Dalla Entity Route) ---
    private String routeDescription; // Descrizione umana (es. "A1 Milano-Roma")
    private Double distance;         // Distanza in km
    private Double duration;         // Durata in minuti

    // Nota: La polyline di solito non si manda nella lista per risparmiare banda,
    // si recupera solo nel dettaglio se serve disegnare la mappa.
}