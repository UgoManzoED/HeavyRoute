package com.heavyroute.users.dto;

import com.heavyroute.users.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per la creazione di un nuovo membro dello staff interno.
 * <p>
 * Utilizzato dai Gestori degli Account per aggiungere al sistema nuovi utenti interni.
 * Tutti i campi sono obbligatori, inclusa la password temporanea iniziale.
 * </p>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class InternalUserCreateDTO {

    /**
     * Username aziendale univoco (es. nome.cognome).
     */
    @NotBlank(message = "Lo username è obbligatorio")
    @Size(min = 4, message = "Lo username deve avere almeno 4 caratteri")
    private String username;

    /**
     * Indirizzo email aziendale.
     * <p>
     * Deve rispettare il formato standard e il pattern aziendale.
     * </p>
     */
    @NotBlank(message = "L'email è obbligatoria")
    @Email(message = "L'indirizzo email non è sintatticamente valido")
    @Pattern(
            regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$",
            message = "Il formato dell'email non è corretto (es. nome.cognome@heavyroute.com)"
    )
    private String email;

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
     * Ruolo da assegnare al dipendente.
     */
    @NotNull(message = "È necessario specificare un ruolo")
    private UserRole role;

    /**
     * Password temporanea di primo accesso.
     * <p>
     * <b>Obbligatoria in fase di creazione.</b>
     * L'utente sarà forzato a cambiarla al primo login.
     * </p>
     */
    @NotBlank(message = "La password iniziale è obbligatoria")
    @Size(min = 8, message = "La password deve contenere almeno 8 caratteri")
    private String password;
}