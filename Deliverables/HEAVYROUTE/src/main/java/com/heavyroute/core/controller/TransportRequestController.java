package com.heavyroute.core.controller;

import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.dto.TransportRequestResponseDTO;
import com.heavyroute.core.service.TransportRequestService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controller REST responsabile della gestione delle richieste di trasporto nel sistema Heavy Route.
 * <p>
 * Questa classe espone gli endpoint necessari ai <b>Committenti</b> per l'inserimento di nuovi ordini
 * e ai <b>Pianificatori Logistici</b> per la consultazione delle richieste in attesa.
 * </p>
 * <p>
 * Segue rigorosamente il pattern DTO per garantire il disaccoppiamento tra il layer di persistenza
 * e l'interfaccia API.
 * </p>
 * * @author Heavy Route Team
 */
@RestController
@RequestMapping("/api/requests")
public class TransportRequestController {

    private final TransportRequestService requestService;

    /**
     * Costruttore per l'iniezione della dipendenza del servizio.
     * <p>
     * Secondo le linee guida di progetto, il controller dipende dall'interfaccia {@link TransportRequestService}
     * e non dalla sua implementazione concreta, favorendo il testing e la manutenibilità.
     * </p>
     *
     * @param requestService Il servizio di gestione delle richieste di trasporto.
     */
    public TransportRequestController(TransportRequestService requestService) {
        this.requestService = requestService;
    }

    /**
     * Endpoint per la creazione di una nuova richiesta di trasporto.
     * <p>
     * Implementa il requisito funzionale <b>FR8 (Creazione Richiesta di Trasporto)</b>.
     * Il payload viene validato tramite l'annotazione {@link Valid} per assicurare che i dati
     * tecnici del carico siano coerenti prima della persistenza.
     * </p>
     *
     * @param dto Oggetto contenente i dati della richiesta (origine, destinazione, specifiche carico).
     * @return {@link ResponseEntity} contenente il {@link TransportRequestResponseDTO} della richiesta creata e stato HTTP 200 OK.
     */
    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<TransportRequestResponseDTO> createRequest(@Valid @RequestBody RequestCreationDTO dto) {
        String username = getCurrentUsername();
        return ResponseEntity.ok(requestService.createRequest(dto, username));
    }

    /**
     * Endpoint per il recupero dell'elenco delle richieste di trasporto.
     * <p>
     * Fornisce i dati per il monitoraggio della dashboard lato Committente (<b>FR10</b>)
     * e per la valutazione della fattibilità lato Pianificatore Logistico (<b>FR14</b>).
     * </p>
     *
     * @return {@link ResponseEntity} contenente la lista di {@link TransportRequestResponseDTO} e stato HTTP 200 OK.
     */
    @GetMapping("/my-requests")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<List<TransportRequestResponseDTO>> getMyRequest() {
        String username = getCurrentUsername();
        return ResponseEntity.ok(requestService.getRequestsByClientUsername(username));
    }

    /**
     * Endpoint amministrativo per la visualizzazione globale delle richieste.
     * <p>
     * <b>Access Control:</b> Riservato esclusivamente al ruolo <b>LOGISTIC_PLANNER</b>.
     * <br>
     * Permette al pianificatore di avere una visione d'insieme su tutti gli ordini inseriti
     * dai vari clienti, step fondamentale per l'aggregazione dei carichi e la
     * creazione dei Viaggi (Trips).
     * </p>
     *
     * @return Lista completa di {@link TransportRequestResponseDTO} presenti nel sistema.
     */
    @GetMapping
    @PreAuthorize("hasRole('LOGISTIC_PLANNER')")
    public ResponseEntity<List<TransportRequestResponseDTO>> getAllRequests() {
        return ResponseEntity.ok(requestService.getAllRequests());
    }

    /**
     * Metodo di utilità per recuperare l'identità dell'utente corrente.
     * <p>
     * Accede al {@link SecurityContextHolder} (Thread-Local) dove il {@code JwtAuthenticationFilter}
     * ha precedentemente salvato i dettagli dell'utente dopo aver validato il Token.
     * </p>
     * <p>
     * <b>Utilizzo:</b> Fondamentale per implementare la logica di sicurezza (es. "chi sta chiamando questo metodo?")
     * senza dover passare esplicitamente lo username come parametro del metodo.
     * </p>
     *
     * @return Lo username (Subject del JWT) dell'utente autenticato.
     */
    private String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }
}