package com.heavyroute.core.repository;

import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/**
 * Repository JPA per la gestione della persistenza delle entità {@link TransportRequest}.
 * <p>
 * Questa interfaccia estende {@link JpaRepository}, fornendo metodi standard per le operazioni CRUD
 * (Create, Read, Update, Delete) sulla tabella {@code transport_request} nel database relazionale
 * di Heavy Route.
 * </p>
 * <p>
 * Svolge un ruolo cruciale nel supporto ai requisiti funzionali di monitoraggio e valutazione,
 * permettendo al sistema di interrogare le richieste in base al loro stato nel ciclo di vita
 * (es. recupero di tutte le richieste in attesa per il PL).
 * </p>
 *
 * @author Heavy Route Team
 * @see TransportRequest
 * @see RequestStatus
 */
public interface TransportRequestRepository extends JpaRepository<TransportRequest, Long> {

    /**
     * Recupera un elenco di richieste di trasporto filtrate in base allo stato specificato.
     * <p>
     * Questo metodo viene utilizzato principalmente dalle dashboard operative:
     * <ul>
     * <li>Il <b>Pianificatore Logistico</b> lo utilizza per visualizzare le nuove richieste
     * con stato {@code PENDING} da valutare (FR14).</li>
     * <li>Il <b>Committente</b> può visualizzare lo storico filtrato delle proprie richieste
     * tramite il servizio che interroga questo repository (FR10).</li>
     * </ul>
     * </p>
     *
     * @param status Lo stato della richiesta da cercare (es. PENDING, APPROVED, REJECTED).
     * @return Una {@link List} di {@link TransportRequest} che corrispondono allo stato fornito.
     * Restituisce una lista vuota se non viene trovata alcuna corrispondenza.
     */
    List<TransportRequest> findByRequestStatus(RequestStatus status);

    /**
     * Recupera l'intero storico delle richieste associate a uno specifico cliente.
     * <p>
     * <b>Obiettivo di Business:</b> Supporta la funzionalità di dashboard personale (es. "I Miei Ordini").
     * È il metodo fondamentale per garantire la <b>Data Isolation</b> (Multi-tenancy logica):
     * permette di filtrare i dati in modo che ogni Committente veda esclusivamente le proprie spedizioni,
     * impedendo l'accesso non autorizzato ai dati di altri clienti (prevenzione IDOR).
     * </p>
     * <p>
     * <b>Nota sulle Performance:</b> Dato che un cliente fidelizzato potrebbe avere migliaia di richieste
     * nello storico, in un ambiente di produzione ad alto traffico si consiglia di evolvere
     * questo metodo supportando la paginazione (es. {@code Page<TransportRequest> ... Pageable pageable}).
     * </p>
     *
     * @param clientId L'ID univoco (Primary Key) dell'utente con ruolo {@code CUSTOMER}.
     * @return Una lista di richieste. Restituisce una lista vuota (e mai null) se il cliente
     * non ha ancora effettuato ordini.
     */
    List<TransportRequest> findAllByClientId(Long clientId);
}