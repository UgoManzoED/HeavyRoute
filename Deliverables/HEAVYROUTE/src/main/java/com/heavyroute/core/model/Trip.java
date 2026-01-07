package com.heavyroute.core.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.users.model.Driver;
// import com.heavyroute.core.model.Route;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Year;
import java.util.UUID;

/**
 * Rappresenta un Viaggio all'interno del sistema HeavyRoute.
 * <p>
 * Questa entità gestisce i dati essenziali di una spedizione o spostamento,
 * collegando logicamente un autista e un veicolo a un codice univoco di tracciamento.
 * Estende {@link BaseEntity} per la gestione automatica di ID e timestamp (audit).
 * </p>
 */

@Entity
@Table(name = "trips")
@Getter
@Setter
public class Trip extends BaseEntity {

    /**
     * Codice univoco di business che identifica il viaggio.
     * <p>
     * <b>Nota:</b> Se non valorizzato esplicitamente, viene generato automaticamente
     * in fase di pre-persistenza ({@link #generateCode()}).
     * </p>
     */
    @Column(nullable = false, unique = true)
    private String tripCode;

    /**
     * Lo stato corrente del ciclo di vita del viaggio.
     * Persistito come stringa per leggibilità nel DB e resilienza al refactoring.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TripStatus status;

    // --- RELAZIONI ---

    /**
     * Riferimento alla Richiesta di Trasporto originale che ha generato questo viaggio.
     * <p>
     * Stabilisce un legame forte (Hard Link) tra la fase commerciale (Request) e quella operativa (Trip).
     * Configurato come One-to-One rigoroso:
     * <ul>
     * <li><b>optional = false:</b> A livello JPA, impedisce di salvare un Trip senza una Request associata (non-null).</li>
     * <li><b>unique = true:</b> A livello DB, impedisce che due viaggi puntino alla stessa richiesta (relazione 1:1 pura).</li>
     * </ul>
     * </p>
     */
    @OneToOne(optional = false)
    @JoinColumn(name = "request_id", unique = true)
    private TransportRequest request;

    // TODO: Decommentare quando push Route
    // @OneToOne(cascade = CascadeType.ALL)
    // @JoinColumn(name = "route_id")
    // private Route route;

    // --- RISORSE ASSEGNATE ---

    /**
     * L'autista responsabile del viaggio.
     * <p>
     * <b>Configurazione JPA:</b>
     * <ul>
     * <li><b>@ManyToOne:</b> Definisce la cardinalità (Molti viaggi -> Un autista).</li>
     * <li><b>FetchType.LAZY:</b> Cruciale per le performance. I dati dell'autista NON vengono caricati
     * dal DB quando si carica il viaggio, ma solo alla prima chiamata di {@code getDriver()}.
     * Questo evita query inutili quando servono solo i dati generali del viaggio.</li>
     * </ul>
     * </p>
     * <p>
     * <b>Nota:</b> Può essere {@code null} se il viaggio è in stato {@code CREATED}
     * o {@code IN_PLANNING}, prima dell'assegnazione effettiva delle risorse.
     * </p>
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id")
    private Driver driver;

    /**
     * Il veicolo fisico utilizzato per il trasporto.
     * <p>
     * Mappato come relazione Lazy per evitare il caricamento a cascata di dati pesanti
     * (es. storico manutenzioni del veicolo) quando si consulta un semplice elenco di viaggi.
     * La colonna {@code vehicle_id} funge da Chiave Esterna (Foreign Key) sul database.
     * </p>
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id")
    private Vehicle vehicle;

    // --- METODI DI BUSINESS ---

    /**
     * Callback del ciclo di vita JPA eseguito prima dell'inserimento nel database.
     * <p>
     * Garantisce l'idem potenza del `tripCode`; se il chiamante non ha fornito un codice,
     * ne viene generato uno basato sul timestamp corrente per assicurare l'univocità
     * tecnica e prevenire errori di constraint violata.
     * </p>
     */
    @PrePersist
    public void generateCode() {
        if (this.tripCode == null) {
            String year = String.valueOf(Year.now().getValue());
            String sequence = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            this.tripCode = "TRP-" + year + "-" + sequence;
        }
    }
}