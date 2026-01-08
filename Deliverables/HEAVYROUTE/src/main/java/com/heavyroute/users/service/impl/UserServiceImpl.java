package com.heavyroute.users.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.common.exception.UserAlreadyExistsException;
import com.heavyroute.users.dto.*;
import com.heavyroute.users.model.*;
import com.heavyroute.users.repository.CustomerRepository;
import com.heavyroute.users.repository.UserRepository;
import com.heavyroute.users.dto.UserMapper;
import com.heavyroute.users.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementazione concreta della logica di gestione utenti.
 * <p>
 * Gestisce la persistenza polimorfica (User vs Customer) e garantisce
 * l'applicazione delle regole di unicità e sicurezza definite nell'ODD.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    /**
     * {@inheritDoc}
     * <p>
     * Implementa la registrazione "Self-Service" del cliente.
     * L'utente viene creato con stato {@code active = false} in attesa di validazione.
     * </p>
     */
    @Override
    @Transactional
    public UserDTO registerNewClient(CustomerRegistrationDTO dto) {
        // OCL Pre-condition check: Unicità Username
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new UserAlreadyExistsException("Lo username '" + dto.getUsername() + "' è già utilizzato.");
        }

        // Business Check: Unicità Email e Dati Fiscali
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new UserAlreadyExistsException("L'indirizzo email risulta già registrato.");
        }
        if (customerRepository.existsByVatNumber(dto.getVatNumber())) {
            throw new UserAlreadyExistsException("La Partita IVA è già presente a sistema.");
        }

        // Creazione Entità Customer
        Customer customer = new Customer();
        customer.setUsername(dto.getUsername());
        customer.setEmail(dto.getEmail());
        customer.setFirstName(dto.getFirstName());
        customer.setLastName(dto.getLastName());

        // Security: Hashing della password
        customer.setPasswordHash(passwordEncoder.encode(dto.getPassword()));

        customer.setActive(false); // Richiede approvazione manuale

        // Dati specifici Customer
        customer.setCompanyName(dto.getCompanyName());
        customer.setVatNumber(dto.getVatNumber());
        customer.setAddress(dto.getAddress());
        customer.setPhoneNumber(dto.getPhoneNumber());

        // Persistenza
        User savedUser = customerRepository.save(customer);
        return userMapper.toDTO(savedUser);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Implementa il censimento dello staff interno.
     * </p>
     */
    @Override
    @Transactional
    public UserDTO createInternalUser(InternalUserCreateDTO dto) {
        // OCL Pre-condition: Unicità Email/Username
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new UserAlreadyExistsException("Email aziendale già assegnata.");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new UserAlreadyExistsException("Username già in uso.");
        }

        User user = switch (dto.getRole()) {
            case DRIVER -> new Driver();
            case LOGISTIC_PLANNER -> new LogisticPlanner();
            case ACCOUNT_MANAGER -> new AccountManager();
            case TRAFFIC_COORDINATOR -> new TrafficCoordinator();
            default ->
                // Impedisce la creazione di ruoli non interni
                    throw new BusinessRuleException("Il ruolo " + dto.getRole() + " non è valido per la creazione di un utente interno.");
        };
        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());

        // OCL Post: result.passwordHash <> null
        user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));

        // Lo staff interno creato da admin è attivo di default
        user.setActive(true);

        // 4. Persistenza
        User savedUser = userRepository.save(user);
        return userMapper.toDTO(savedUser);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    @Transactional
    public void deactivateUser(Long id) {
        // Recupero Utente
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utente non trovato con ID: " + id));

        // Modifica stato (OCL Post: user.active == false)
        user.setActive(false);
        userRepository.save(user);

        //TODO Invalidazione Sessioni (OCL Post)
        // Nota: L'implementazione reale dipenderà dal meccanismo di token (JWT Blacklist o SessionRegistry)
        // tokenStore.invalidateAllSessions(id);
    }

    @Override
    @Transactional
    public UserDTO updateInternalUser(Long id, InternalUserUpdateDTO dto) {
        // 1. Recupero l'entità (deve esistere)
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utente interno non trovato"));

        // 2. Il mapper aggiorna i campi comuni e lo stato active
        userMapper.updateInternalUserFromDTO(dto, user);

        // 3. Gestione sicura della password
        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        }

        return userMapper.toDTO(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserDTO updateCustomer(Long id, CustomerUpdateDTO dto) {
        // 1. Recupero l'entità specifica Customer
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente non trovato"));

        // 2. Il mapper aggiorna i campi comuni + quelli fiscali (VAT, CompanyName, etc.)
        userMapper.updateCustomerFromDTO(dto, customer);

        // 3. Gestione sicura della password
        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            customer.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        }

        return userMapper.toDTO(customerRepository.save(customer));
    }
}