package com.heavyroute.core.service.impl;

import com.heavyroute.core.dto.*;
import com.heavyroute.core.model.*;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.service.TransportRequestService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementazione concreta del servizio per la gestione delle richieste di trasporto.
 * <p>
 * Questa classe contiene la logica di business per il modulo Core, gestendo il passaggio
 * dei dati tra i DTO e le entità JPA. Coordina l'interazione con il repository
 * {@link TransportRequestRepository}.
 * </p>
 * * @author Heavy Route Team
 */
@Service
public class TransportRequestServiceImpl implements TransportRequestService {

    private final TransportRequestRepository repository;

    /**
     * Costruttore per l'iniezione del repository tramite Dependency Injection.
     * * @param repository Il repository per l'accesso ai dati delle richieste.
     */
    public TransportRequestServiceImpl(TransportRequestRepository repository) {
        this.repository = repository;
    }

    /**
     * Crea e persiste una nuova richiesta di trasporto nel sistema.
     * <p>
     * Implementa il flusso del requisito <b>FR8</b>:
     * <ol>
     * <li>Mappa i dati dal DTO di creazione all'entità {@link TransportRequest}.</li>
     * <li>Imposta lo stato iniziale della richiesta a {@link RequestStatus#PENDING}.</li>
     * <li>Salva l'entità sul database tramite il repository.</li>
     * <li>Restituisce il DTO di dettaglio per la conferma all'utente.</li>
     * </ol>
     * </p>
     *
     * @param dto DTO contenente i dati inseriti dal Committente.
     * @return {@link RequestDetailDTO} I dettagli della richiesta salvata.
     */
    @Override
    @Transactional
    public RequestDetailDTO createRequest(RequestCreationDTO dto) {
        TransportRequest request = new TransportRequest();

        // Allineamento con i campi 'origin' e 'destination' del RequestCreationDTO
        request.setOriginAddress(dto.getOriginAddress());
        request.setDestinationAddress(dto.getDestinationAddress());

        request.setPickupDate(dto.getPickupDate());
        request.setRequestStatus(RequestStatus.PENDING);

        LoadDetails load = new LoadDetails();
        load.setWeightKg(dto.getWeight());
        load.setHeight(dto.getHeight());
        load.setWidth(dto.getWidth());
        load.setLength(dto.getLength());
        request.setLoad(load);

        TransportRequest saved = repository.save(request);
        return mapToDetailDTO(saved);
    }

    /**
     * Recupera tutte le richieste di trasporto registrate.
     * <p>
     * Utilizzato per popolare le liste di monitoraggio nelle dashboard degli attori
     * di sistema (Committente e PL).
     * </p>
     *
     * @return Lista di {@link RequestDetailDTO} rappresentanti tutte le richieste.
     */
    @Override
    public List<RequestDetailDTO> getAllRequests() {
        return repository.findAll().stream()
                .map(this::mapToDetailDTO)
                .collect(Collectors.toList());
    }

    /**
     * Metodo helper privato per il mapping manuale da Entità a DTO.
     * <p>
     * Assicura che i dettagli tecnici del carico (Embedded {@link LoadDetails})
     * siano correttamente appiattiti nel DTO di risposta.
     * </p>
     *
     * @param entity L'entità JPA da mappare.
     * @return Il DTO popolato con i dati dell'entità.
     */
    private RequestDetailDTO mapToDetailDTO(TransportRequest entity) {
        RequestDetailDTO dto = new RequestDetailDTO();
        dto.setId(entity.getId());
        dto.setOriginAddress(entity.getOriginAddress());
        dto.setDestinationAddress(entity.getDestinationAddress());
        dto.setPickupDate(entity.getPickupDate());
        dto.setStatus(entity.getRequestStatus());

        // Mapping dei dettagli del carico dall'oggetto embedded
        if (entity.getLoad() != null) {
            dto.setWeight(entity.getLoad().getWeightKg());
            dto.setHeight(entity.getLoad().getHeight());
            dto.setWidth(entity.getLoad().getWidth());
            dto.setLength(entity.getLoad().getLength());
        }

        return dto;
    }
}