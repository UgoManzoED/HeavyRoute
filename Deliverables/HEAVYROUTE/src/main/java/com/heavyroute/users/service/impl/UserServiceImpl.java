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

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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
     */
    @Override
    @Transactional
    public UserResponseDTO registerNewClient(CustomerRegistrationDTO dto) {
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new UserAlreadyExistException("Lo username '" + dto.getUsername() + "' è già utilizzato.");
        }

        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new UserAlreadyExistException("L'indirizzo email risulta già registrato.");
        }
        if (customerRepository.existsByVatNumber(dto.getVatNumber())) {
            throw new UserAlreadyExistException("La Partita IVA " + dto.getVatNumber() + " è già presente a sistema.");
        }

        Customer customer = new Customer();
        customer.setUsername(dto.getUsername());
        customer.setEmail(dto.getEmail());
        customer.setFirstName(dto.getFirstName());
        customer.setLastName(dto.getLastName());
        customer.setPassword(passwordEncoder.encode(dto.getPassword()));
        customer.setActive(false); // Richiede approvazione manuale

        customer.setCompanyName(dto.getCompanyName());
        customer.setVatNumber(dto.getVatNumber());
        customer.setAddress(dto.getAddress());
        customer.setPhoneNumber(dto.getPhoneNumber());
        customer.setPec(dto.getPec());

        User savedUser = customerRepository.save(customer);
        return userMapper.toDTO(savedUser);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /**
     * Crea un utente dello staff interno (Back-office).
     */
    @Override
    @Transactional
    public UserResponseDTO createInternalUser(InternalUserCreateDTO dto) {
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
            default -> throw new BusinessRuleException("Il ruolo " + dto.getRole() + " non è valido per la creazione di un utente interno.");
        };

        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setActive(true);

        User savedUser = userRepository.save(user);
        return userMapper.toDTO(savedUser);
    }

    /**
     * Esegue una cancellazione logica (Soft Delete).
     */
    @Override
    @Transactional
    public void deactivateUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utente non trovato con ID: " + id));

        user.setActive(false);
        userRepository.save(user);
    }

    @Override
    @Transactional
    public UserResponseDTO updateInternalUser(Long id, InternalUserUpdateDTO dto) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utente interno non trovato"));

        userMapper.updateInternalUserFromDTO(dto, user);

        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        return userMapper.toDTO(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserResponseDTO updateCustomer(Long id, CustomerUpdateDTO dto) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente non trovato"));

        userMapper.updateCustomerFromDTO(dto, customer);

        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            customer.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        return userMapper.toDTO(customerRepository.save(customer));
    }

    /**
     * Recupera la lista di tutti gli utenti in attesa di approvazione manuale.
     * <p>
     * Filtra gli utenti che hanno il flag {@code active} impostato a false.
     * </p>
     *
     * @return Lista di {@link UserResponseDTO} degli utenti non attivi.
     */
    @Override
    @Transactional(readOnly = true)
    public List<UserResponseDTO> findInactiveUsers() {
        // Recuperiamo gli utenti con active = false
        List<User> inactiveUsers = userRepository.findByActiveFalse();

        // Li mappiamo in DTO per inviarli al frontend
        return inactiveUsers.stream()
                .map(userMapper::toDTO)
                .collect(Collectors.toList());
    }
    /**
     * Attiva un utente specifico nel sistema.
     * <p>
     * Operazione invocata dal Planner o Account Manager dopo aver validato
     * i dati fiscali o anagrafici dell'utente.
     * </p>
     *
     * @param id L'identificativo dell'utente da attivare.
     * @return Il DTO dell'utente ora attivo.
     * @throws ResourceNotFoundException se l'ID fornito non corrisponde ad alcun utente.
     */
    @Override
    @Transactional
    public UserResponseDTO activateUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utente non trovato"));

        user.setActive(true); // Qui avviene il cambio di stato
        return userMapper.toDTO(userRepository.save(user));
    }

    /**
     * Elimina fisicamente un utente dal database.
     * <p>
     * Utilizzato principalmente per rifiutare registrazioni pendenti
     * o cancellare account creati per errore.
     * </p>
     *
     * @param id L'identificativo dell'utente da eliminare.
     * @throws ResourceNotFoundException se l'utente non esiste.
     */
    @Override
    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("Impossibile eliminare: Utente non trovato con ID: " + id);
        }
        userRepository.deleteById(id);
    }
}