package com.heavyroute.users.repository;

import com.heavyroute.users.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Interfaccia di persistenza specifica per l'entità {@link Customer} (Committente).
 * <p>
 * Oltre alle operazioni ereditate da {@link JpaRepository}, fornisce metodi mirati
 * per la validazione dei dati aziendali e la gestione del flusso di approvazione.
 * </p>
 */
@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    /**
     * Recupera la lista dei committenti che sono ancora in stato "NON ATTIVO".
     * <p>
     * Fondamentale per la dashboard del Pianificatore Logistico per validare le nuove iscrizioni.
     * </p>
     *
     * @return Lista di clienti in attesa di approvazione (`active = false`).
     */
    List<Customer> findByActiveFalse();

    /**
     * Verifica se una Partita IVA è già presente nel sistema.
     * <p>
     * Utilizzato per garantire l'unicità fiscale dei clienti (campo {@code vatNumber}).
     * </p>
     *
     * @param vatNumber La Partita IVA da verificare.
     * @return {@code true} se esiste già un cliente con questa P.IVA.
     */
    boolean existsByVatNumber(String vatNumber);

    /**
     * Verifica se una Ragione Sociale è già registrata.
     * <p>
     * Controllo su {@code companyName} per evitare omonimie.
     * </p>
     *
     * @param companyName La ragione sociale da verificare.
     * @return {@code true} se la ragione sociale è già in uso.
     */
    boolean existsByCompanyName(String companyName);
}