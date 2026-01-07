package com.heavyroute.resources.dto;

import jakarta.persistence.Column;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VehicleDTO {


    /**
     * Identificatore univoco della segnalazione.
     */
    private Long id;

    /**
     * Targa del veicolo.
     * Utilizzata come riferimento principale nelle comunicazioni operative e
     * nei documenti di viaggio.
     */
    private String licensePlate;

    /**
     * Marca e modello del veicolo (es. "Iveco Stralis 500").
     */
    private String model;

    /**
     * Portata massima utile del mezzo espressa in chilogrammi.
     * Questo valore è fondamentale per il controllo di compatibilità:
     * il peso del carico deve essere inferiore o uguale a questo parametro.
     */
    private Double maxLoadCapacity;

    private Double maxHeight; //altezza massima del veicolo in metri

    private Double maxWidth; //larghezza massima del veicolo in metri

    private Double maxLength; //lunghezza massima del veicolo in metri

    /**
     * Stato operativo attuale del veicolo (es. AVAILABLE, BUSY, MAINTENANCE).
     * Determina se il mezzo può essere assegnato a un nuovo viaggio.
     */
    private String status;

}
