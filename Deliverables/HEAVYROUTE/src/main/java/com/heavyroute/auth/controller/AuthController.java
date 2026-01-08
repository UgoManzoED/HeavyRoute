package com.heavyroute.auth.controller;

import com.heavyroute.auth.dto.JwtResponse;
import com.heavyroute.auth.dto.LoginRequest;
import com.heavyroute.auth.security.JwtUtils;
import com.heavyroute.users.model.User;
import com.heavyroute.users.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

/**
 * Controller per la gestione dell'autenticazione pubblica.
 * <p>
 * Espone gli endpoint accessibili senza token (definiti in SecurityConfig),
 * permettendo agli utenti di ottenere il loro primo JWT.
 * </p>
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final JwtUtils jwtUtils;

    /**
     * Effettua il Login dell'utente.
     *
     * @param loginRequest DTO contenente username e password.
     * @return 200 OK con il JWT se le credenziali sono valide.
     * 401 Unauthorized se le credenziali sono errate (gestito globalmente).
     */
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {

        // 1. Autenticazione Core
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        // 2. Security Context
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // 3. Generazione Token
        String jwt = jwtUtils.generateJwtToken(authentication);

        // 4. Recupero Dettagli Utente (Enrichment)
        User user = userRepository.findByUsername(loginRequest.getUsername()).orElseThrow();

        // 5. Risposta
        return ResponseEntity.ok(new JwtResponse(
                jwt,
                "Bearer",
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole().name()
        ));
    }
}