package com.heavyroute.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO (Data Transfer Object) per le credenziali di accesso.
 * <p>
 * Rappresenta il payload JSON inviato dal client durante la richiesta di Login.
 * Include annotazioni di validazione per garantire che username e password non siano vuoti
 * prima ancora di tentare l'autenticazione.
 * </p>
 */
@Data
public class LoginRequestDTO {

    /**
     * L'identificativo dell'utente.
     * @NotBlank impedisce null, stringhe vuote "" o stringhe di soli spazi " ".
     */
    @NotBlank
    private String username;

    /**
     * La password in chiaro.
     * Verrà hashata e confrontata con quella nel DB dall'AuthenticationManager.
     */
    @NotBlank
    private String password;
}