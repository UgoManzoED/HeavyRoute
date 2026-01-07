package com.heavyroute.resources.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.users.model.Driver;
import jakarta.persistence.*;
import jakarta.validation.constraints.Positive;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Entità che rappresenta un mezzo di trasporto (trattore stradale, rimorchio, furgone).
 * <p>
 * Contiene le specifiche tecniche (dimensioni e portata) necessarie all'algoritmo
 * di pianificazione per verificare la compatibilità con le richieste di trasporto.
 * </p>
 */
@Entity
@Table(name = "vehicles")
@Getter @Setter
@NoArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Vehicle extends BaseEntity {

    @Column(nullable = false, unique = true)
    private String licensePlate;

    @Column(nullable = false)
    private String model;

    @Column(nullable = false)
    @Positive
    private Double maxLoadCapacity; //portata massima del veicolo in kg

    @Column(nullable = false)
    @Positive
    private Double maxHeight; //altezza massima del veicolo in metri

    @Column(nullable = false)
    @Positive
    private Double maxWidth; //larghezza massima del veicolo in metri

    @Column(nullable = false)
    @Positive
    private Double maxLength; //lunghezza massima del veicolo in metri

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private VehicleStatus status = VehicleStatus.AVAILABLE;

    /**
     * Riferimento inverso all'autista assegnato.
     * <p>
     * Nota: La relazione è gestita (owned) dall'entità {@link Driver}.
     * Usiamo 'mappedBy' per renderla bidirezionale senza creare chiavi duplicate.
     * </p>
     */
    @OneToOne(mappedBy = "vehicle")
    private Driver currentDriver;

    /**
     * Verifica se il veicolo è pronto per essere assegnato.
     * @return true se lo stato è AVAILABLE.
     */
    public boolean isAvailable() {
        return this.status.equals(VehicleStatus.AVAILABLE);
    }

    /**
     * Verifica se il veicolo è in manutenzione.
     * @return true se lo stato è MAINTENANCE.
     */
    public boolean isInMaintenance() {
        return this.status.equals(VehicleStatus.MAINTENANCE);
    }
}