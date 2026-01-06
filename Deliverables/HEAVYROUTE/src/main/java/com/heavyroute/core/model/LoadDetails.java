package com.heavyroute.core.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Data;

/**
 * Rappresenta i dettagli fisici e tecnici del carico per una richiesta di trasporto.
 * Questa classe è un Value Object incorporato (@Embeddable) nell'entità {@link TransportRequest}.
 * * I dati contenuti sono utilizzati dal sistema per:
 * <ul>
 * <li>Determinare se il trasporto è classificato come "eccezionale".</li>
 * <li>Calcolare percorsi compatibili con i limiti di altezza e larghezza stradali.</li>
 * <li>Pianificare l'assegnazione di veicoli con portata e dimensioni idonee.</li>
 * </ul>
 * * @author Heavy Route Team
 */
@Embeddable
@Data
public class LoadDetails {

    /**
     * Descrizione qualitativa della merce trasportata (es. "Pala Eolica", "Trasformatore").
     * Corrisponde al campo 'tipologia' nel modello degli oggetti.
     */
    private String type;

    /**
     * Numero di unità che compongono il carico per la singola richiesta.
     */
    private Integer quantity;

    /**
     * Peso totale del carico espresso in chilogrammi.
     * Il sistema utilizza questo valore per verificare i limiti di carico assiale dei ponti.
     */
    @Column(name = "weight_kg")
    private Double weightKg;

    /**
     * Altezza massima del carico espressa in metri.
     * Fondamentale per la verifica del transito sotto tunnel e cavalcavia.
     */
    private Double height;

    /**
     * Larghezza massima del carico espressa in metri.
     * Determina la necessità di scorte tecniche se superiore ai limiti del Codice della Strada.
     */
    private Double width;

    /**
     * Lunghezza complessiva del carico espressa in metri.
     * Parametro critico per la manovrabilità nei tratti a raggio di curvatura stretto.
     */
    private Double length;
}