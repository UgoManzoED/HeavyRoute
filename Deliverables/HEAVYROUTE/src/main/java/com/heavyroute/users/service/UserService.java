package com.heavyroute.users.service;

import com.heavyroute.users.dto.*;
import com.heavyroute.users.model.User;

import java.util.List;
import java.util.Optional;

/**
 * Logica di business per il ciclo di vita e la gestione degli utenti.
 * <p>
 * Definisce le operazioni per la registrazione dei clienti, il censimento dello staff
 * e la gestione della sicurezza (disattivazione account).
 * </p>
 */
public interface UserService {

    /**
     * Cerca un utente tramite il suo username.
     * Usato per l'autenticazione e per recuperare il profilo corrente.
     */
    Optional<User> findByUsername(String username);

    /**
     * Crea un nuovo committente (Customer) in attesa di approvazione.
     * <p>
     * <b>OCL Pre:</b> !userRepository.existsByUsername(dto.username)
     * </p>
     *
     * @param dto I dati di registrazione e fiscali del cliente.
     * @return Il DTO dell'utente creato (senza dati sensibili).
     * @throws com.heavyroute.common.exception.UserAlreadyExistException se lo username è già in uso.
     */
    UserResponseDTO registerNewClient(CustomerRegistrationDTO dto);

    /**
     * Crea un utente interno con password temporanea.
     * <p>
     * <b>OCL Pre:</b> !userRepository.existsByEmail(dto.email)
     * <b>OCL Post:</b> result.passwordHash <> null
     * </p>
     *
     * @param dto I dati anagrafici e il ruolo dello staff.
     * @return Il DTO dell'utente creato.
     * @throws com.heavyroute.common.exception.UserAlreadyExistException se l'email o lo username sono già presenti.
     */
    UserResponseDTO createInternalUser(InternalUserCreateDTO dto);

    /**
     * Disabilita l'accesso al sistema per un utente specifico.
     * <p>
     * <b>OCL Post:</b> user.active == false
     * <b>OCL Post:</b> tokenStore.invalidateAllSessions(id)
     * </p>
     *
     * @param id L'identificativo dell'utente da disattivare.
     * @throws com.heavyroute.common.exception.ResourceNotFoundException se l'utente non esiste.
     */
    void deactivateUser(Long id);

    /**
     * Aggiorna un utente dello staff interno.
     */
    UserResponseDTO updateInternalUser(Long id, InternalUserUpdateDTO dto);

    /**
     * Aggiorna i dati di un cliente (Committente).
     */
    UserResponseDTO updateCustomer(Long id, CustomerUpdateDTO dto);

    /**
     * Recupera tutti gli utenti che si sono registrati ma non sono ancora attivi.
     * @return Lista di DTO degli utenti in attesa.
     */
    List<UserResponseDTO> findInactiveUsers();

    /**
     * Attiva un utente impostando il flag active a true.
     * <p>
     * <b>OCL Post:</b> user.active == true
     * </p>
     * @param id Identificativo dell'utente da approvare.
     * @return Il DTO dell'utente aggiornato.
     */
    UserResponseDTO activateUser(Long id);

    /**
     * Elimina definitivamente un utente dal sistema (rifiuto registrazione).
     * @param id L'identificativo dell'utente da rimuovere.
     */
    void deleteUser(Long id);

}

