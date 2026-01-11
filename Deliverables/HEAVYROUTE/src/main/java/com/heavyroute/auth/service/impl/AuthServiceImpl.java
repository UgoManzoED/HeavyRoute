package com.heavyroute.auth.service.impl;

import com.heavyroute.auth.dto.JwtResponseDTO;
import com.heavyroute.auth.dto.LoginRequestDTO;
import com.heavyroute.auth.security.JwtUtils;
import com.heavyroute.auth.service.AuthService;
import com.heavyroute.common.exception.UserAlreadyExistException;
import com.heavyroute.users.dto.CustomerRegistrationDTO;
import com.heavyroute.users.model.Customer;
import com.heavyroute.users.model.User;
import com.heavyroute.users.repository.CustomerRepository;
import com.heavyroute.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementazione concreta del servizio di Autenticazione.
 * <p>
 * Questa classe agisce come coordinatore tra:
 * <ul>
 * <li><b>Spring Security:</b> Per verificare le password (AuthenticationManager).</li>
 * <li><b>Database:</b> Per leggere e scrivere utenti (Repositories).</li>
 * <li><b>Crittografia:</b> Per generare Token (JwtUtils) e hashare password (PasswordEncoder).</li>
 * </ul>
 * </p>
 */
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    /**
     * Esegue il processo di Login.
     * <p>
     * Non confrontiamo mai le password manualmente ("if a == b").
     * Deleghiamo questo compito delicato all'AuthenticationManager che usa BCrypt
     * per confrontare la password in chiaro con l'hash nel DB.
     * </p>
     */
    @Override
    public JwtResponseDTO login(LoginRequestDTO loginRequest) {
        // 1. Autenticazione (Verifica User e Password)
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getUsername(),
                        loginRequest.getPassword()
                )
        );

        // 2. Impostazione del Contesto di Sicurezza
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // 3. Generazione del Token
        String jwt = jwtUtils.generateJwtToken(authentication);

        // 4. Arricchimento della Risposta
        User user = userRepository.findByUsername(loginRequest.getUsername())
                .orElseThrow(() -> new RuntimeException("Errore: Utente non trovato post-autenticazione"));

        return new JwtResponseDTO(
                jwt,
                "Bearer",
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole().name()
        );
    }

    /**
     * Registra un nuovo Committente nel sistema.
     * <p>
     * Utilizza una transazione DB per garantire l'integrità dei dati:
     * dato che Customer estende User, Hibernate deve scrivere su due tabelle (users, customers).
     * Se una delle due insert fallisce, l'intero processo viene annullato (Rollback).
     * </p>
     */
    @Override
    @Transactional
    public void registerCustomer(CustomerRegistrationDTO dto) {

        // 1. Validazione Difensiva
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new UserAlreadyExistException("Username già in uso: " + dto.getUsername());
        }
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new UserAlreadyExistException("Email già presente: " + dto.getEmail());
        }

        // 2. Check Unicità (Customer)
        if (customerRepository.existsByVatNumber(dto.getVatNumber())) {
            throw new UserAlreadyExistException("Partita IVA già registrata: " + dto.getVatNumber());
        }

        // 3. Creazione Entità
        Customer customer = Customer.builder()
                // --- Campi Ereditati da User ---
                .username(dto.getUsername())
                .password(passwordEncoder.encode(dto.getPassword()))
                .email(dto.getEmail())
                .firstName(dto.getFirstName())
                .lastName(dto.getLastName())
                .phoneNumber(dto.getPhoneNumber())
                .active(false)

                // --- Campi Specifici di Customer ---
                .companyName(dto.getCompanyName())
                .vatNumber(dto.getVatNumber())
                .pec(dto.getPec())
                .address(dto.getAddress())
                .build();

        // 4. Persistenza
        customerRepository.save(customer);
    }
}