package com.heavyroute.users.controller;

import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.users.dto.*;
import com.heavyroute.users.mapper.UserMapper;
import com.heavyroute.users.model.User;
import com.heavyroute.users.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;

    /**
     * Endpoint per ottenere il profilo dell'utente loggato.
     * Utilizzato dal Frontend per popolare la Dashboard e il form profilo.
     */
    @GetMapping("/me")
    public ResponseEntity<UserResponseDTO> getCurrentUser() {
        // 1. Recupera lo username dal contesto di sicurezza (dal Token JWT)
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUsername = authentication.getName();

        // 2. Cerca l'utente tramite il Service
        User user = userService.findByUsername(currentUsername)
                .orElseThrow(() -> new ResourceNotFoundException("Utente non trovato: " + currentUsername));

        // 3. Converte in DTO e restituisce
        return ResponseEntity.ok(userMapper.toDTO(user));
    }

    @GetMapping("/pending")
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'ACCOUNT_MANAGER')")
    public ResponseEntity<List<UserResponseDTO>> getPending() {
        return ResponseEntity.ok(userService.findInactiveUsers());
    }
    @PatchMapping("/{id}/approve")
    @PreAuthorize("hasAnyRole('LOGISTIC_PLANNER', 'ACCOUNT_MANAGER')")
    public ResponseEntity<UserResponseDTO> approve(@PathVariable Long id) {
        return ResponseEntity.ok(userService.activateUser(id));
    }


    /**
     * Registrazione pubblica per un nuovo Committente.
     */
    @PostMapping("/register/client")
    public ResponseEntity<UserResponseDTO> registerClient(@Valid @RequestBody CustomerRegistrationDTO dto) {
        return ResponseEntity.ok(userService.registerNewClient(dto));
    }

    /**
     * Creazione utente interno (Solo per Gestore Account).
     */
    @PostMapping("/internal")
    @PreAuthorize("hasRole('ACCOUNT_MANAGER')")
    public ResponseEntity<UserResponseDTO> createInternalUser(@Valid @RequestBody InternalUserCreateDTO dto) {
        return ResponseEntity.ok(userService.createInternalUser(dto));
    }

    /**
     * Endpoint per ottenere la lista di tutti gli utenti interni.
     * Richiesto dalla Dashboard dell'Account Manager.
     */
    @GetMapping("/internal")
    @PreAuthorize("hasRole('ACCOUNT_MANAGER')")
    public ResponseEntity<List<UserResponseDTO>> getInternalUsers() {
        List<User> internalUsers = userService.findAllInternalUsers();

        return ResponseEntity.ok(userMapper.toDTOList(internalUsers));
    }

}