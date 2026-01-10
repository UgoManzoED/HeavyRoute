package com.heavyroute.users.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per la registrazione di un nuovo Committente (Customer).
 * <p>
 * Questo oggetto raccoglie tutti i dati necessari per il processo di "Onboarding"
 * di una nuova azienda cliente. Include sia le credenziali di accesso (User)
 * sia i dati fiscali (Customer) necessari per la validazione contrattuale.
 * </p>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerRegistrationDTO {

    /**
     * Lo username desiderato per l'accesso alla piattaforma.
     * Deve essere univoco nel sistema.
     */
    @NotBlank(message = "L'username è obbligatorio")
    @Size(min = 4, message = "L'username deve avere più di 4 caratteri")
    private String username;

    /**
     * Password di accesso.
     * <p>
     * <b>Nota di Sicurezza:</b> La password viaggia in chiaro solo su HTTPS all'interno di questo DTO
     * e deve essere hashata immediatamente dal Service prima della persistenza.
     * </p>
     */
    @NotBlank(message = "La password è obbligatoria")
    @Size(min = 8, message = "La password deve contenere almeno 8 caratteri")
    private String password;

    /**
     * Email aziendale per le notifiche e il recupero credenziali.
     */
    @NotBlank(message = "L'email è obbligatoria")
    @Email(message = "L'indirizzo email non è sintatticamente valido")
    @Pattern(
            regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$",
            message = "Il formato dell'email non è corretto (es. nome@dominio.com)"
    )
    private String email;

    /**
     * Ragione Sociale completa dell'azienda.
     * Utilizzata per la fatturazione e l'identificazione nei report.
     */
    @NotBlank(message = "La Ragione Sociale è obbligatoria")
    private String companyName;

    /**
     * Partita IVA (o codice fiscale aziendale).
     * <p>
     * Campo critico per l'unicità del cliente. Il sistema verifica che non esistano
     * già altri account collegati a questa P.IVA.
     * </p>
     */
    @NotBlank(message = "La Partita IVA è obbligatoria")
    @Size(min = 11, max = 16, message = "La Partita IVA deve avere una lunghezza valida (tra 11 e 16 caratteri)")
    private String vatNumber;

    /**
     * Indirizzo della sede legale o operativa principale.
     */
    @NotBlank(message = "L'indirizzo della sede è obbligatorio")
    private String address;

    /**
     * Canale sicuro per comunicazioni con valore legale equiparato alla
     * raccomandata A/R, garanzia di integrità del contenuto e opponibilità a terzi.
     */
    @NotBlank(message = "La PEC è obbligatoria")
    @Email(message = "Formato PEC non valido")
    private String pec;

    /**
     * Recapito telefonico di riferimento per comunicazioni urgenti relative ai trasporti.
     * <p>
     * Accetta formati internazionali con il segno '+'.
     * </p>
     */
    @NotBlank(message = "Il numero di telefono è obbligatorio")
    @Pattern(regexp = "^\\+?[0-9\\s-]{8,20}$", message = "Formato telefono non valido")
    private String phoneNumber;

    /**
     * Nome proprio del committente.
     */
    @NotBlank(message = "Il nome è obbligatorio")
    private String firstName;

    /**
     * Cognome del committente.
     */
    @NotBlank(message = "Il cognome è obbligatorio")
    private String lastName;
}