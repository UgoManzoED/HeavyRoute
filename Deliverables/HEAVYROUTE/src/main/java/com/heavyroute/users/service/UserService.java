package com.heavyroute.users.service;

import com.heavyroute.users.dto.*;

/**
 * Logica di business per il ciclo di vita e la gestione degli utenti.
 * <p>
 * Definisce le operazioni per la registrazione dei clienti, il censimento dello staff
 * e la gestione della sicurezza (disattivazione account).
 * </p>
 */
public interface UserService {

    /**
     * Crea un nuovo committente (Customer) in attesa di approvazione.
     * <p>
     * <b>OCL Pre:</b> !userRepository.existsByUsername(dto.username)
     * </p>
     *
     * @param dto I dati di registrazione e fiscali del cliente.
     * @return Il DTO dell'utente creato (senza dati sensibili).
     * @throws com.heavyroute.common.exception.UserAlreadyExistsException se lo username è già in uso.
     */
    UserDTO registerNewClient(CustomerRegistrationDTO dto);

    /**
     * Crea un utente interno con password temporanea.
     * <p>
     * <b>OCL Pre:</b> !userRepository.existsByEmail(dto.email)
     * <b>OCL Post:</b> result.passwordHash <> null
     * </p>
     *
     * @param dto I dati anagrafici e il ruolo dello staff.
     * @return Il DTO dell'utente creato.
     * @throws com.heavyroute.common.exception.UserAlreadyExistsException se l'email o lo username sono già presenti.
     */
    UserDTO createInternalUser(InternalUserCreateDTO dto);

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
    UserDTO updateInternalUser(Long id, InternalUserUpdateDTO dto);

    /**
     * Aggiorna i dati di un cliente (Committente).
     */
    UserDTO updateCustomer(Long id, CustomerUpdateDTO dto);
}