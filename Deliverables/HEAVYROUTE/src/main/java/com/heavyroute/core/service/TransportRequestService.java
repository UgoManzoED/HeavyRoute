package com.heavyroute.core.service;

import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.dto.TransportRequestResponseDTO;

import java.util.List;

/**
 * Interfaccia di servizio per la gestione del ciclo di vita delle richieste di trasporto.
 * <p>
 * Agisce come layer di business logic tra i controller REST e il repository di persistenza.
 * Coordina le operazioni di creazione, validazione e consultazione delle richieste,
 * assicurando la coerenza dei dati secondo le regole di business definite nel progetto Heavy Route.
 * </p>
 * * @author Heavy Route Team
 * @see com.heavyroute.core.model.TransportRequest
 */
public interface TransportRequestService {

    /**
     * Recupera lo storico delle richieste filtrate per uno specifico cliente.
     * <p>
     * <b>Obiettivo di Business:</b> Implementa la vista "I Miei Ordini".
     * Permette al cliente loggato di monitorare lo stato delle proprie spedizioni
     * senza accedere ai dati riservati di altri clienti (Data Isolation).
     * </p>
     * <p>
     * <b>Nota di Sicurezza:</b> Il parametro {@code username} deve essere estratto
     * dal contesto di sicurezza (JWT) nel Controller per garantire che l'utente
     * stia richiedendo legittimamente i propri dati.
     * </p>
     *
     * @param username L'identificativo univoco del cliente (dal SecurityContext).
     * @return Una lista di DTO contenente i dettagli delle richieste sottomesse da questo utente.
     */
    List<TransportRequestResponseDTO> getRequestsByClientUsername(String username);

    /**
     * Crea una nuova richiesta di trasporto nel sistema.
     * <p>
     * Questa operazione implementa il requisito <b>FR8 (Inserimento Richiesta di Trasporto)</b>.
     * </p>
     * <p>
     * <b>Logica Transazionale:</b>
     * <ul>
     * <li>Recupera l'entità {@code User} (Cliente) associata allo username.</li>
     * <li>Mappa il DTO di input nell'entità {@code TransportRequest}.</li>
     * <li>Imposta lo stato iniziale a {@code PENDING} (Pattern State Machine).</li>
     * <li>Persiste i dati garantendo l'integrità referenziale.</li>
     * </ul>
     * </p>
     *
     * @param dto Oggetto contenente i dati di input validati (origine, destinazione, carico).
     * @param username L'autore della richiesta (necessario per settare la relazione 'owner').
     * @return {@link TransportRequestResponseDTO} La richiesta appena creata, completa di ID e Timestamp.
     * @throws com.heavyroute.common.exception.BusinessRuleException se la data è nel passato.
     * @throws com.heavyroute.common.exception.ResourceNotFoundException se l'utente non esiste.
     */
    TransportRequestResponseDTO createRequest(RequestCreationDTO dto, String username);

    /**
     * Recupera l'elenco completo delle richieste di trasporto presenti nel sistema.
     * <p>
     * <b>Target Audience:</b> Funzionalità riservata al ruolo <b>PLANNER</b>.
     * Serve per alimentare la Dashboard Globale dove il pianificatore decide quali
     * richieste approvare e trasformare in Viaggi.
     * </p>
     * <p>
     * <b>Performance Warning:</b> In un sistema di produzione con migliaia di record,
     * questo metodo dovrebbe supportare la <b>Paginazione</b> (Pageable) per evitare
     * di caricare l'intera tabella in memoria.
     * </p>
     *
     * @return Una lista di {@link TransportRequestResponseDTO} rappresentante tutte le richieste.
     */
    List<TransportRequestResponseDTO> getAllRequests();
}