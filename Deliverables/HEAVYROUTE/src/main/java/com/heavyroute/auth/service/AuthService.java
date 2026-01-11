package com.heavyroute.auth.service;

import com.heavyroute.auth.dto.JwtResponseDTO;
import com.heavyroute.auth.dto.LoginRequestDTO;
import com.heavyroute.users.dto.CustomerRegistrationDTO;

/**
 * Contratto per i servizi di Autenticazione e Autorizzazione.
 * <p>
 * Questa interfaccia applica il <b>Pattern Facade</b>: nasconde la complessità
 * di Spring Security (AuthenticationManager, SecurityContext, JwtUtils) dietro
 * metodi semplici e orientati al business, utilizzati dai Controller.
 * </p>
 */
public interface AuthService {

    /**
     * Esegue la procedura di Login completa.
     * <p>
     * <b>Responsabilità:</b>
     * <ol>
     * <li>Verifica le credenziali (username/password) tramite {@code AuthenticationManager}.</li>
     * <li>Se valide, genera un Token JWT firmato tramite {@code JwtUtils}.</li>
     * <li>Recupera i dettagli dell'utente (Ruolo, ID) per il frontend.</li>
     * </ol>
     * </p>
     *
     * @param loginRequest DTO contenente le credenziali in chiaro inviate dall'utente.
     * @return Un DTO contenente il Token (Bearer) e le info utente necessarie alla UI.
     * @throws org.springframework.security.authentication.BadCredentialsException se la password è errata.
     */
    JwtResponseDTO login(LoginRequestDTO loginRequest);

    /**
     * Gestisce l'onboarding (registrazione) di un nuovo Committente.
     * <p>
     * Questo metodo agisce come <b>Orchestratore</b>:
     * <ul>
     * <li>Delega la validazione dei dati.</li>
     * <li>Chiama il {@code UserService} per la persistenza fisica su DB (User + Customer).</li>
     * <li>Potrebbe in futuro inviare email di benvenuto o notifiche agli admin.</li>
     * </ul>
     * </p>
     *
     * @param registrationDTO Dati anagrafici e fiscali del nuovo cliente.
     * @throws com.heavyroute.common.exception.UserAlreadyExistException se username/email/P.IVA esistono già.
     */
    void registerCustomer(CustomerRegistrationDTO registrationDTO);
}