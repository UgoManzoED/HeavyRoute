package com.heavyroute.core.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.core.enums.TripStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

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

    /**
     * Riferimento all'id dell'autista assegnato.
     * <p>
     * Questo campo memorizza solo l'identificativo.
     * </p>
     */
    @Column(name = "driver_id")
    private Long driverId;

    /**
     * Targa del veicolo utilizzato per il viaggio.
     * Per ricerche rapide.
     */
    @Column(name = "vehicle_plate")
    private String vehiclePlate;

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
            this.tripCode = "TRP-" + System.currentTimeMillis();
        }
    }
}