package com.heavyroute.users.repository;

import com.heavyroute.users.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Interfaccia di persistenza principale per l'entità radice {@link User}.
 * <p>
 * Agisce come gateway polimorfico per l'intera gerarchia degli utenti.
 * Grazie alla strategia {@code JOINED}, le query eseguite qui interrogano la tabella base,
 * ma Hibernate esegue automaticamente i join necessari per istanziare la sottoclasse corretta
 * (es. restituendo un oggetto {@code Driver} o {@code Customer} completo).
 * </p>
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Recupera un utente dal database ricercandolo per username univoco.
     * <p>
     * <strong>Attenzione:</strong> Questo metodo ignora il flag {@code active}.
     * Restituisce l'utente anche se è bannato o non ancora approvato.
     * Deve essere utilizzato solo per operazioni amministrative o di sistema interne.
     * </p>
     *
     * @param username Il nome utente da ricercare.
     * @return Un {@link Optional} contenente l'utente trovato, oppure vuoto se inesistente.
     */
    Optional<User> findByUsername(String username);

    /**
     * Esegue un controllo rapido (Fail-Fast) sull'esistenza di uno username.
     * <p>
     * Questa query è ottimizzata (spesso usa solo l'indice) e dovrebbe essere chiamata
     * durante la fase di validazione di un DTO di registrazione, prima ancora di
     * tentare la creazione dell'entità.
     * </p>
     *
     * @param username Lo username da verificare.
     * @return {@code true} se lo username è già occupato, impedendo la registrazione.
     */
    boolean existsByUsername(String username);

    /**
     * Esegue un controllo rapido sull'esistenza di un indirizzo email.
     * <p>
     * Fondamentale per garantire che non esistano account duplicati o multipli
     * associati allo stesso contatto aziendale.
     * </p>
     *
     * @param email L'indirizzo email da verificare.
     * @return {@code true} se l'email è già presente nel sistema.
     */
    boolean existsByEmail(String email);

    /**
     * Metodo primario per la procedura di autenticazione sicura (Login).
     * <p>
     * Filtra a livello di database gli utenti che non hanno il flag {@code active = true}.
     * Questo garantisce che un utente bannato o non ancora approvato non possa mai
     * ricevere un token JWT, anche se la password fornita fosse corretta.
     * </p>
     *
     * @param username Il nome utente da autenticare.
     * @return Un {@link Optional} contenente l'utente solo se le credenziali esistono E l'account è attivo.
     */
    Optional<User> findByUsernameAndActiveTrue(String username);

    /**
     * Recupera un utente specifico che si trova in stato disabilitato o in attesa di approvazione.
     * <p>
     * <strong>Caso d'uso:</strong> Dashboard di gestione account.
     * Permette agli amministratori di recuperare i dettagli di un utente "disattivato"
     * per valutarne la riattivazione.
     * </p>
     *
     * @param username Il nome utente da cercare.
     * @return Un {@link Optional} contenente l'utente solo se esiste ED è disattivato (`active = false`).
     */
    Optional<User> findByUsernameAndActiveFalse(String username);
}