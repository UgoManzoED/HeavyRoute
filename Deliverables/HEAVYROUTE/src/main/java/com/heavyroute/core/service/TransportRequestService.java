package com.heavyroute.core.service;

import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.dto.RequestDetailDTO;
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
     * Crea una nuova richiesta di trasporto nel sistema.
     * <p>
     * Questa operazione implementa il requisito <b>FR8 (Inserimento Richiesta di Trasporto)</b>.
     * Il servizio si occupa di mappare il DTO nell'entità di persistenza, impostare lo stato
     * iniziale a {@code PENDING} e persistere i dati tramite il repository.
     * </p>
     *
     * @param dto Oggetto contenente i dati di input validati (origine, destinazione, data e specifiche del carico).
     * @return {@link RequestDetailDTO} La richiesta appena creata, completa di ID generato e stato corrente.
     * @throws com.heavyroute.common.exception.BusinessRuleException se la data di ritiro non è valida o i dati sono inconsistenti.
     */
    RequestDetailDTO createRequest(RequestCreationDTO dto);

    /**
     * Recupera l'elenco completo delle richieste di trasporto presenti nel sistema.
     * <p>
     * Supporta le funzionalità di monitoraggio per il <b>Committente</b> (visualizzazione proprie richieste)
     * e per il <b>Pianificatore Logistico</b> (dashboard globale per la valutazione).
     * </p>
     *
     * @return Una lista di {@link RequestDetailDTO} rappresentante tutte le richieste registrate.
     * Restituisce una lista vuota se non sono presenti record.
     */
    List<RequestDetailDTO> getAllRequests();
}