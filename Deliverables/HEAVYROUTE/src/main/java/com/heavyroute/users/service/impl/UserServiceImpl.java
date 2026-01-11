package com.heavyroute.users.service.impl;

import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.common.exception.UserAlreadyExistException;
import com.heavyroute.users.dto.*;
import com.heavyroute.users.model.*;
import com.heavyroute.users.repository.CustomerRepository;
import com.heavyroute.users.repository.UserRepository;
import com.heavyroute.users.mapper.UserMapper;
import com.heavyroute.users.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Implementazione della logica di business per la gestione del ciclo di vita degli Utenti.
 * <p>
 * <b>Responsabilità:</b>
 * <ul>
 * <li>Gestione dell'ereditarietà (Polimorfismo): Tratta Customer e Staff Interno in modo differenziato.</li>
 * <li>Sicurezza: Applica l'hashing delle password e la validazione dei dati sensibili.</li>
 * <li>Integrità: Garantisce l'unicità di username, email e P.IVA prima della persistenza.</li>
 * </ul>
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
     * Gestisce il processo di auto-registrazione (Onboarding) per nuovi clienti.
     * <p>
     * <b>Flusso di Business:</b>
     * <ol>
     * <li>Validazione unicità credenziali (Username/Email).</li>
     * <li>Validazione unicità fiscale (Partita IVA) per prevenire duplicati aziendali.</li>
     * <li>Creazione utente con stato <b>DISATTIVO</b> (active = false).</li>
     * </ol>
     * </p>
     * <b>Nota Sicurezza:</b> L'utente nasce disattivo per obbligare un processo di validazione manuale (KYC)
     * da parte di un operatore interno prima di abilitare l'accesso alla piattaforma.
     */
    @Override
    @Transactional
    public UserResponseDTO registerNewClient(CustomerRegistrationDTO dto) {
        // OCL Pre-condition check: Unicità Username
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new UserAlreadyExistException("Lo username '" + dto.getUsername() + "' è già utilizzato.");
        }

        // Business Check: Unicità Email e Dati Fiscali
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new UserAlreadyExistException("L'indirizzo email risulta già registrato.");
        }
        if (customerRepository.existsByVatNumber(dto.getVatNumber())) {
            throw new UserAlreadyExistException("La Partita IVA " + dto.getVatNumber() + " è già presente a sistema.");
        }

        // Creazione Entità Customer
        Customer customer = new Customer();
        customer.setUsername(dto.getUsername());
        customer.setEmail(dto.getEmail());
        customer.setFirstName(dto.getFirstName());
        customer.setLastName(dto.getLastName());

        customer.setPassword(passwordEncoder.encode(dto.getPassword()));

        customer.setActive(false); // Richiede approvazione manuale

        // Dati specifici Customer
        customer.setCompanyName(dto.getCompanyName());
        customer.setVatNumber(dto.getVatNumber());
        customer.setAddress(dto.getAddress());
        customer.setPhoneNumber(dto.getPhoneNumber());
        customer.setPec(dto.getPec());

        // Persistenza
        User savedUser = customerRepository.save(customer);
        return userMapper.toDTO(savedUser);
    }

    /**
     * Recupera un utente per username.
     * <p>
     * Usato principalmente da Spring Security durante il Login.
     * L'annotazione {@code readOnly = true} ottimizza le performance evitando
     * il "Dirty Checking" di Hibernate (non controlla se l'oggetto è stato modificato).
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /**
     * Crea un utente dello staff interno (Back-office).
     * <p>
     * <b>Differenza con la Registrazione Clienti:</b>
     * <ul>
     * <li>Viene eseguito da un Admin (non è self-service).</li>
     * <li>L'utente nasce <b>ATTIVO</b> (active = true) perché fidato.</li>
     * <li>Utilizza una logica <b>Factory</b> basata sullo switch per istanziare
     * la classe concreta corretta (Driver, Planner, ecc.).</li>
     * </ul>
     * </p>
     */
    @Override
    @Transactional
    public UserResponseDTO createInternalUser(InternalUserCreateDTO dto) {
        // OCL Pre-condition: Unicità Email/Username
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new UserAlreadyExistException("Email aziendale già assegnata.");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new UserAlreadyExistException("Username già in uso.");
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
        user.setPassword(passwordEncoder.encode(dto.getPassword()));

        // Lo staff interno creato da admin è attivo di default
        user.setActive(true);

        // 4. Persistenza
        User savedUser = userRepository.save(user);
        return userMapper.toDTO(savedUser);
    }

    /**
     * Esegue una cancellazione logica (Soft Delete).
     * <p>
     * Invece di rimuovere fisicamente il record (che romperebbe l'integrità referenziale
     * con i viaggi passati), imposta il flag {@code active = false}.
     * L'utente non potrà più loggarsi, ma lo storico rimane intatto.
     * </p>
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
    }

    /**
     * Aggiorna i dati di un utente interno.
     * <p>
     * Gestisce la logica condizionale per la password: la aggiorna (e la cifra)
     * solo se è stata effettivamente inviata nel DTO.
     * </p>
     */
    @Override
    @Transactional
    public UserResponseDTO updateInternalUser(Long id, InternalUserUpdateDTO dto) {
        // 1. Recupero l'entità (deve esistere)
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utente interno non trovato"));

        // 2. Il mapper aggiorna i campi comuni e lo stato active
        userMapper.updateInternalUserFromDTO(dto, user);

        // 3. Gestione sicura della password
        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        return userMapper.toDTO(userRepository.save(user));
    }

    /**
     * Aggiorna i dati specifici di un Cliente.
     * <p>
     * Recupera l'entità dal repository specifico {@code CustomerRepository} per avere accesso
     * ai campi fiscali (P.IVA, Ragione Sociale) che non esistono nell'utente generico.
     * </p>
     */
    @Override
    @Transactional
    public UserResponseDTO updateCustomer(Long id, CustomerUpdateDTO dto) {
        // 1. Recupero l'entità specifica Customer
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente non trovato"));

        // 2. Il mapper aggiorna i campi comuni + quelli fiscali (VAT, CompanyName, etc.)
        userMapper.updateCustomerFromDTO(dto, customer);

        // 3. Gestione sicura della password
        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            customer.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        return userMapper.toDTO(customerRepository.save(customer));
    }
}