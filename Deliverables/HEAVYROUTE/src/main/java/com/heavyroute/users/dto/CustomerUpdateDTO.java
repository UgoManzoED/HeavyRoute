package com.heavyroute.users.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) per l'aggiornamento del profilo di un Committente (Customer).
 * <p>
 * Permette la modifica sia dei dati anagrafici base (ereditati da User)
 * sia dei dati fiscali e di contatto specifici dell'azienda.
 * I campi lasciati a {@code null} non verranno modificati nel database.
 * </p>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerUpdateDTO {

    /**
     * Identificativo univoco del cliente da modificare.
     * <p>
     * Necessario per il cross-check di sicurezza con l'ID nell'URL.
     * </p>
     */
    @NotNull(message = "L'ID utente è obbligatorio")
    private Long id;

    /**
     * Nome del referente aziendale.
     */
    private String firstName;

    /**
     * Cognome del referente aziendale.
     */
    private String lastName;

    /**
     * Email aziendale per le notifiche.
     */
    @Email(message = "L'indirizzo email non è sintatticamente valido")
    @Pattern(
            regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$",
            message = "Il formato dell'email non è corretto"
    )
    private String email;

    /**
     * Ragione Sociale aggiornata.
     */
    private String companyName;

    /**
     * Partita IVA.
     * <p>
     * <b>Attenzione:</b> La modifica di questo campo potrebbe richiedere una nuova validazione
     * da parte del Pianificatore Logistico, in quanto cambia l'identità fiscale del cliente.
     * </p>
     */
    @Size(min = 11, max = 16, message = "La Partita IVA deve avere una lunghezza valida (11-16 caratteri)")
    private String vatNumber;

    /**
     * Indirizzo della sede legale/operativa.
     */
    private String address;

    /**
     * Recapito telefonico.
     */
    @Pattern(regexp = "^\\+?[0-9\\s-]{8,20}$", message = "Formato telefono non valido")
    private String phoneNumber;

    /**
     * Nuova password (Opzionale).
     * <p>
     * Se valorizzato, sovrascrive la password attuale.
     * Deve rispettare i criteri di complessità minimi.
     * </p>
     */
    @Size(min = 8, message = "La nuova password deve contenere almeno 8 caratteri")
    private String password;
}