package com.heavyroute.core.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per le operazioni di pianificazione o assegnazione risorse.
 * <p>
 * Questa classe trasporta i dati inviati dal client
 * quando un operatore decide di assegnare un autista e un veicolo a un viaggio specifico.
 * </p>
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TripAssignmentDTO {

    /**
     * L'ID univoco del viaggio da pianificare.
     * <p>
     * <b>Nota:</b> Anche se questo ID è spesso presente nel path dell'URL
     * (es. {@code /api/trips/{id}/plan}), è incluso nel body per consentire
     * una validazione di consistenza (Cross-Check) nel Controller, assicurando
     * che l'intento del body corrisponda alla risorsa invocata.
     * </p>
     */

    @Positive
    private Long tripId;

    /**
     * L'identificativo dell'autista selezionato per il viaggio.
     * Deve corrispondere a un autista esistente e attivo nel sistema.
     */
    @NotNull(message = "L'ID dell'autista è obbligatorio")
    @Positive
    private Long driverId;

    /**
     * La targa del veicolo assegnato.
     * <p>
     * Usa {@code @NotBlank} per rifiutare valori null, stringhe vuote o solo spazi.
     * </p>
     */
    @NotBlank(message = "La targa del veicolo è obbligatoria")
    private String vehiclePlate;
}