package com.heavyroute.resources.dto;

import com.heavyroute.resources.enums.VehicleStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per la rappresentazione dei dati tecnici e operativi di un veicolo.
 * <p>
 * Include le validazioni necessarie per garantire l'integrità dei dati della flotta,
 * prevenendo l'inserimento di mezzi con parametri fisici non validi (es. pesi o dimensioni negative)
 *.
 * </p>
 * * @author Heavy Route Team
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VehicleDTO {

    /**
     * Targa del veicolo.
     * Utilizzata come riferimento principale nelle comunicazioni operative e nei documenti di viaggio.
     * Non può essere vuota o composta solo da spazi.
     */
    @NotBlank(message = "La targa del veicolo è obbligatoria")
    private String licensePlate;

    /**
     * Marca e modello del veicolo (es. "Iveco Stralis 500").
     * Utilizzato per l'identificazione rapida del mezzo da parte del personale.
     */
    @NotBlank(message = "Il modello del veicolo è obbligatorio")
    private String model;

    /**
     * Portata massima utile del mezzo espressa in chilogrammi.
     * Questo valore è fondamentale per il controllo di compatibilità:
     * il peso del carico deve essere inferiore o uguale a questo parametro.
     */
    @NotNull(message = "La portata massima è obbligatoria")
    @Positive(message = "La portata massima deve essere un valore positivo")
    private Double maxLoadCapacity;

    /**
     * Altezza massima del veicolo in metri (incluso il pianale di carico).
     * Parametro critico per la verifica della percorribilità sotto tunnel o ponti.
     */
    @NotNull(message = "L'altezza massima è obbligatoria")
    @Positive(message = "L'altezza massima deve essere un valore positivo")
    private Double maxHeight;

    /**
     * Larghezza massima del veicolo in metri.
     * Determina la necessità di scorte tecniche se supera i limiti stradali standard.
     */
    @NotNull(message = "La larghezza massima è obbligatoria")
    @Positive(message = "La larghezza massima deve essere un valore positivo")
    private Double maxWidth;

    /**
     * Lunghezza massima del veicolo in metri.
     * Parametro utilizzato per verificare la manovrabilità nelle curve strette.
     */
    @NotNull(message = "La lunghezza massima è obbligatoria")
    @Positive(message = "La lunghezza massima deve essere un valore positivo")
    private Double maxLength;

    /**
     * Stato operativo attuale del veicolo (es. AVAILABLE, BUSY, MAINTENANCE).
     * Determina se il mezzo può essere assegnato a un nuovo viaggio.
     */
    private VehicleStatus status;
}