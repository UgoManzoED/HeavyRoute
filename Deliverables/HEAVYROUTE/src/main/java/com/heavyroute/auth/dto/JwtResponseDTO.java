package com.heavyroute.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * DTO di risposta per un login avvenuto con successo.
 * <p>
 * Contiene il Token JWT (la chiave di accesso) e i dettagli essenziali dell'utente
 * necessari al Frontend per configurare la sessione e l'interfaccia utente (UI).
 * </p>
 */
@Data
@AllArgsConstructor
public class JwtResponseDTO {

    /**
     * Il Token JWT firmato.
     * Il client dovrà salvarlo (SecureStorage) e inviarlo nell'header di ogni richiesta successiva.
     */
    private String token;

    /**
     * Il tipo di token. "Bearer" è lo standard de facto per OAuth2 e JWT.
     * Indica che "chiunque porti (bear) questo token ha diritto di accesso".
     */
    private String type = "Bearer";

    private Long id;
    private String username;
    private String email;

    /**
     * Il ruolo dell'utente (es. "PLANNER", "DRIVER").
     * Per il Frontend per abilitare/disabilitare funzionalità.
     */
    private String role;
}