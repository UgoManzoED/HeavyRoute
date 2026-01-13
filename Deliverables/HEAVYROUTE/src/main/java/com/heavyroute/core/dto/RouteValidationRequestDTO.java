package com.heavyroute.core.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO utilizzato dal Traffic Coordinator per approvare o rifiutare
 * una proposta di rotta generata dal Planner.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RouteValidationRequestDTO {

    /**
     * True se la rotta è approvata, False se deve essere rigenerata.
     */
    @NotNull(message = "La decisione di approvazione è obbligatoria")
    private Boolean approved;

    /**
     * Messaggio di feedback (obbligatorio in caso di rifiuto).
     * Spiega al Planner perché la rotta non è valida.
     */
    private String feedback;
}