package com.heavyroute.core.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.users.model.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

/**
 * Rappresenta una richiesta di trasporto inserita da un Committente nel sistema Heavy Route[cite: 4111, 7102].
 * Questa entità formalizza la richiesta di un servizio di trasporto eccezionale,
 * contenendo i dettagli logistici necessari alla valutazione della fattibilità[cite: 4111].
 * * Estende {@link BaseEntity} da cui eredita l'ID univoco e i campi di auditing (createdAt, updatedAt).
 * * @author Heavy Route Team
 */
@Entity
@Table(name = "transport_request")
@Getter
@Setter
public class TransportRequest extends BaseEntity {

    /**
     * Il Committente (Utente con ruolo CUSTOMER) che ha inserito la richiesta.
     * La relazione è Many-to-One: un utente può inviare molteplici richieste di trasporto.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private User client;

    /**
     * L'indirizzo completo del punto di partenza dove dovrà avvenire il ritiro del carico[cite: 4112, 7048].
     */
    @Column(nullable = false, name = "origin_address")
    private String originAddress;

    /**
     * L'indirizzo completo della destinazione finale della spedizione[cite: 4112, 7048].
     */
    @Column(nullable = false, name = "destination_address")
    private String destinationAddress;

    /**
     * La data pianificata per il ritiro della merce[cite: 4113, 7049].
     */
    @Column(nullable = false, name = "pickup_date")
    private LocalDate pickupDate;

    /**
     * Lo stato corrente del ciclo di vita della richiesta (es. PENDING, APPROVED, REJECTED)[cite: 4114, 7048].
     * Determina se la richiesta è in attesa di valutazione, già approvata o rifiutata dal PL[cite: 4114].
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "transport_requests")
    private RequestStatus requestStatus;

    /**
     * Dettagli tecnici e fisici del materiale da trasportare (tipologia, dimensioni e peso)[cite: 4115, 7048].
     * Si tratta di un oggetto embedded che incapsula le specifiche del carico eccezionale[cite: 4115].
     */
    @Embedded
    private LoadDetails load;

}