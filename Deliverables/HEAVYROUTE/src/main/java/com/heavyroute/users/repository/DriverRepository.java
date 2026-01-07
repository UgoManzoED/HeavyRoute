package com.heavyroute.users.repository;

import com.heavyroute.users.model.Driver;
import com.heavyroute.users.enums.DriverStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Interfaccia di persistenza per la gestione dell'entità {@link Driver}.
 * <p>
 * Estende {@link JpaRepository} per fornire le operazioni CRUD standard e definisce
 * query personalizzate per la gestione operativa della flotta e il tracciamento GPS.
 * </p>
 */
@Repository
public interface DriverRepository extends JpaRepository<Driver, Long> {

    /**
     * Recupera la lista di tutti gli autisti che si trovano in uno specifico stato operativo.
     * <p>
     * Metodo generato automaticamente da Spring Data JPA basandosi sul nome del campo 'status'.
     * </p>
     *
     * @param status Lo stato operativo da ricercare (es. FREE, ON_THE_ROAD).
     * @return Una lista di autisti che corrispondono allo stato richiesto.
     */
    List<Driver> findAllByStatus(DriverStatus status);

    /**
     * Recupera rapidamente tutti gli autisti attualmente disponibili per un incarico.
     * <p>
     * Questo metodo è un wrapper di comodo (helper) che invoca {@link #findAllByStatus(DriverStatus)}
     * con il parametro {@code DriverStatus.FREE}.
     * </p>
     *
     * @return Lista degli autisti liberi.
     */
    default List<Driver> findAvailableDrivers() {
        return findAllByStatus(DriverStatus.FREE);
    }

    /**
     * Recupera tutti gli autisti che sono attualmente impegnati in un viaggio.
     * <p>
     * Wrapper di comodo per monitorare la flotta attiva.
     * </p>
     *
     * @return Lista degli autisti in viaggio (ON_THE_ROAD).
     */
    default List<Driver> findDriversOnTheRoad() {
        return findAllByStatus(DriverStatus.ON_THE_ROAD);
    }

    /**
     * Esegue una ricerca geospaziale per trovare autisti liberi in una specifica area.
     * <p>
     * Utilizza una logica "Bounding Box" per filtrare le coordinate GPS.
     * Accede all'oggetto embedded {@code geoLocation} definito nell'entità {@link Driver}.
     * </p>
     *
     * @param minLat Latitudine minima (confine sud).
     * @param maxLat Latitudine massima (confine nord).
     * @param minLon Longitudine minima (confine ovest).
     * @param maxLon Longitudine massima (confine est).
     * @return Una lista di {@link Driver} che sono {@code FREE} e si trovano nell'area.
     */
    @Query("SELECT d FROM Driver d WHERE d.status = com.heavyroute.users.enums.DriverStatus.FREE " +
            "AND d.geoLocation.latitude BETWEEN :minLat AND :maxLat " +
            "AND d.geoLocation.longitude BETWEEN :minLon AND :maxLon")
    List<Driver> findAvailableDriversInArea(
            @Param("minLat") Double minLat,
            @Param("maxLat") Double maxLat,
            @Param("minLon") Double minLon,
            @Param("maxLon") Double maxLon);
}