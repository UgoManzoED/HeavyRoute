package com.heavyroute.users.dto;

import com.heavyroute.users.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per l'aggiornamento del profilo di un membro dello staff.
 * <p>
 * Permette di modificare ruolo, email o reset della password.
 * La password qui è opzionale: se lasciata vuota o nulla, le credenziali attuali
 * rimarranno invariate.
 * </p>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class InternalUserUpdateDTO {

    /**
     * Identificativo dell'utente da modificare.
     * <p>
     * Incluso nel body per garantire un controllo di consistenza (Cross-Check)
     * con l'ID passato nell'URL della richiesta PUT/PATCH.
     * </p>
     */
    @NotNull(message = "L'ID utente è obbligatorio")
    private Long id;

    /**
     * Username aziendale.
     */
    @NotBlank(message = "Lo username è obbligatorio")
    private String username;

    /**
     * Indirizzo email aziendale aggiornato.
     */
    @NotBlank(message = "L'email è obbligatoria")
    @Email(message = "L'indirizzo email non è sintatticamente valido")
    @Pattern(
            regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$",
            message = "Il formato dell'email non è corretto"
    )
    private String email;

    /**
     * Ruolo aggiornato del dipendente.
     */
    @NotNull(message = "È necessario specificare un ruolo")
    private UserRole role;

    /**
     * Nuova password (Opzionale).
     * <p>
     * Se valorizzato, il sistema provvederà a sovrascrivere la password attuale
     * (utile per reset amministrativi).
     * Se {@code null} o stringa vuota, la password non verrà modificata.
     * </p>
     */
    private String password;

    /**
     * Nome proprio dell'utente.
     */
    @NotBlank(message = "Il nome è obbligatorio")
    private String firstName;

    /**
     * Cognome dell'utente.
     */
    @NotBlank(message = "Il cognome è obbligatorio")
    private String lastName;

    /**
     * Stato di attivazione dell'account.
     * Permette di disabilitare temporaneamente un dipendente.
     */
    private Boolean active;
}