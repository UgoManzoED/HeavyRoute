package com.heavyroute.auth.controller;

import com.heavyroute.auth.dto.JwtResponseDTO;
import com.heavyroute.auth.dto.LoginRequestDTO;
import com.heavyroute.auth.service.AuthService;
import com.heavyroute.users.dto.CustomerRegistrationDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Endpoint pubblico per la gestione dell'Autenticazione e Registrazione.
 * <p>
 * Questa classe funge da "Porta d'Ingresso" (Facade) per gli utenti non ancora autenticati.
 * <b>Nota:</b> Tutti i metodi di questo controller devono essere esplicitamente
 * permessi (permitAll) nella {@code SecurityConfig}, altrimenti nessuno potrà mai loggarsi.
 * </p>
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Gestisce la richiesta di registrazione di un nuovo Committente.
     * <p>
     * <b>Flusso:</b>
     * <ol>
     * <li>Deserializza il JSON nel DTO {@link CustomerRegistrationDTO}.</li>
     * <li>Applica la validazione dei campi tramite {@code @Valid}. Se fallisce,
     * lancia eccezione gestita dal {@code GlobalExceptionHandler} (400 Bad Request).</li>
     * <li>Delega la creazione all'{@code AuthService}.</li>
     * </ol>
     * </p>
     *
     * @param registrationDTO Il payload JSON contenente dati anagrafici e fiscali.
     * @return 201 Created (senza corpo) per confermare l'avvenuta creazione della risorsa.
     */
    @PostMapping("/register/customer")
    public ResponseEntity<Void> registerCustomer(@RequestBody @Valid CustomerRegistrationDTO registrationDTO) {
        authService.registerCustomer(registrationDTO);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    /**
     * Punto di ingresso per il Login.
     * <p>
     * Riceve username e password in chiaro (via HTTPS), li valida sintatticamente
     * e richiede al Service di generare un JWT se le credenziali sono corrette.
     * </p>
     *
     * @param loginRequest DTO con username e password.
     * @return 200 OK contenente il Token JWT e i dettagli utente (Ruolo, Nome, ecc.).
     */
    @PostMapping("/login")
    public ResponseEntity<JwtResponseDTO> authenticateUser(@Valid @RequestBody LoginRequestDTO loginRequest) {
        JwtResponseDTO jwtResponse = authService.login(loginRequest);
        return ResponseEntity.ok(jwtResponse);
    }
}