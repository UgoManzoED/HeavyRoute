package com.heavyroute.resources.repository;

import com.heavyroute.resources.enums.EventSeverity;
import com.heavyroute.resources.model.RoadEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Interfaccia di persistenza per la gestione degli eventi stradali (Incendi, Lavori, Traffico).
 * <p>
 * Fondamentale per il modulo di navigazione e sicurezza. Permette di interrogare
 * la validità temporale e la posizione geografica degli ostacoli.
 * </p>
 */
@Repository
public interface RoadEventRepository extends JpaRepository<RoadEvent, Long> {

    /**
     * Recupera tutti gli eventi attualmente attivi nel sistema.
     * <p>
     * Un evento è considerato attivo se l'istante di riferimento ({@code referenceTime})
     * cade all'interno della finestra temporale [validFrom, validTo].
     * Gestisce correttamente anche gli eventi a tempo indeterminato (validTo = null).
     * </p>
     *
     * @param referenceTime L'istante temporale da verificare (solitamente {@code LocalDateTime.now()}).
     * @return Lista degli eventi validi in quel momento.
     */
    @Query("SELECT r FROM RoadEvent r WHERE r.validFrom <= :referenceTime " +
            "AND (r.validTo IS NULL OR r.validTo >= :referenceTime)")
    List<RoadEvent> findAllActiveEvents(@Param("referenceTime") LocalDateTime referenceTime);

    /**
     * Recupera solo gli eventi con un livello di gravità specifico.
     * <p>
     * Utilizzato per identificare blocchi critici (CRITICAL) che richiedono
     * obbligatoriamente un ricalcolo del percorso.
     * </p>
     *
     * @param severity Il livello di gravità da filtrare.
     * @return Lista degli eventi con quella gravità.
     */
    List<RoadEvent> findBySeverity(EventSeverity severity);

    /**
     * Esegue una ricerca geospaziale per trovare eventi in una specifica area rettangolare (Bounding Box).
     * <p>
     * Questa query è essenziale per il Routing Engine: prima di calcolare un percorso,
     * il sistema verifica se nell'area di transito ci sono eventi attivi da evitare.
     * </p>
     *
     * @param minLat Latitudine minima (confine sud).
     * @param maxLat Latitudine massima (confine nord).
     * @param minLon Longitudine minima (confine ovest).
     * @param maxLon Longitudine massima (confine est).
     * @return Lista di eventi geolocalizzati nell'area richiesta.
     */
    @Query("SELECT r FROM RoadEvent r WHERE r.location.latitude BETWEEN :minLat AND :maxLat " +
            "AND r.location.longitude BETWEEN :minLon AND :maxLon")
    List<RoadEvent> findEventsInArea(
            @Param("minLat") Double minLat,
            @Param("maxLat") Double maxLat,
            @Param("minLon") Double minLon,
            @Param("maxLon") Double maxLon);
}