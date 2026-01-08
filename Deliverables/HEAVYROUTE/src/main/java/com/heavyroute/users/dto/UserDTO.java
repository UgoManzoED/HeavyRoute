package com.heavyroute.users.dto;

import com.heavyroute.users.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per la rappresentazione pubblica generica di un utente.
 * <p>
 * Questo oggetto viene utilizzato quando è necessario restituire liste di utenti
 * (es. nella dashboard di amministrazione) o per visualizzare il profilo base
 * senza esporre dati sensibili come la password o dettagli specifici delle sottoclassi
 * (come la patente per i Driver o la P.IVA per i Customer).
 * </p>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {

    /**
     * Identificativo univoco dell'utente nel sistema.
     */
    private Long id;

    /**
     * Username utilizzato per il login.
     */
    private String username;

    /**
     * Indirizzo email di contatto aziendale.
     */
    private String email;

    /**
     * Ruolo assegnato all'utente (es. ADMIN, PLANNER, DRIVER, CUSTOMER).
     * Determina i permessi di accesso alle varie aree della piattaforma.
     */
    private UserRole role;

    /**
     * Indica se l'account è attivo.
     * <p>
     * Se {@code false}, l'utente non può effettuare il login (es. account bannato,
     * sospeso o in attesa di approvazione iniziale).
     * </p>
     */
    private boolean active;
}