package com.heavyroute.core.dto;

import com.heavyroute.core.enums.TripStatus;
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
public class RouteResponseDTO {

    // --- Identificativi ---
    private Long id;              // ID della Route (o del Trip, a seconda della logica)
    private String tripCode;       // Codice Ordine (es. "ORD-045")

    // --- Contesto ---
    private String plannerName;   // Nome del pianificatore (es. "Mario Bianchi")
    private String origin;        // Indirizzo partenza
    private String destination;   // Indirizzo arrivo
    private String loadType;      // Tipologia carico (es. "Carico Eccezionale")
    private TripStatus status;        // Stato approvazione (PENDING, APPROVED, REJECTED)

    // --- Dati Tecnici ---
    private String routeDescription; // Descrizione (es. "A1 Milano-Roma")
    private Double distance;         // Distanza in km
    private Double duration;         // Durata in minuti
    private String polyline;

    // Coordinate Partenza
    private Double startLat;
    private Double startLon;

    // Coordinate Arrivo
    private Double endLat;
    private Double endLon;
}