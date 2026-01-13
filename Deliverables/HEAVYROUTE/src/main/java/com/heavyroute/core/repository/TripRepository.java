package com.heavyroute.core.repository;

import com.heavyroute.core.model.Trip;
import com.heavyroute.core.enums.TripStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository per la gestione della persistenza dell'entità {@link Trip}.
 * <p>
 * Fornisce le operazioni CRUD standard e query personalizzate basate
 * sui campi di business e sulle relazioni logiche.
 * </p>
 */
@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {

    /**
     * Recupera un viaggio tramite il suo codice identificativo di business.
     * <p>
     * Utile per operazioni di tracking pubblico o per API client dove l'id
     * numerico interno non deve essere esposto.
     * </p>
     *
     * @param tripCode Il codice univoco del viaggio (es. "TRP-12345").
     * @return Un {@link Optional} contenente il viaggio se trovato, altrimenti vuoto.
     */
    Optional<Trip> findByTripCode(String tripCode);

    /**
     * Recupera la lista dei viaggi assegnati a un autista specifico che si trovano
     * in un determinato stato.
     *
     * @param driverId L'identificativo dell'autista.
     * @param status Lo stato del viaggio richiesto (es. {@code TripStatus.ACCEPTED}).
     * @return Una lista di viaggi (può essere vuota, mai null).
     */
    List<Trip> findByDriverIdAndStatus(Long driverId, TripStatus status);

    /**
     * Recupera tutti i viaggi assegnati a uno specifico autista, ordinati per data di creazione.
     * <p>
     * <b>UTILIZZO:</b> Dashboard Autista (Mobile App).
     * </p>
     *
     * @param driverId ID dell'autista loggato.
     * @return Lista cronologica dei viaggi.
     */
    List<Trip> findByDriverIdOrderByCreatedAtDesc(Long driverId);

    /**
     * Recupera tutti i viaggi che si trovano in uno specifico stato operativo.
     */
    List<Trip> findByStatus(TripStatus status);

    /**
     * Trova il viaggio associato a una specifica richiesta di trasporto.
     */
    Optional<Trip> findByRequestId(Long requestId);
}