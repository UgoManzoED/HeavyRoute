package com.heavyroute.resources.repository;

import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.enums.VehicleStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository JPA per l'entità {@link Vehicle}.
 * <p>
 * Gestisce l'accesso ai dati per la flotta aziendale di Logistica Mediterranea.
 * Fornisce metodi per la verifica dell'unicità delle targhe e per il recupero dei mezzi
 * in base allo stato operativo e alle capacità di carico.
 * </p>
 * * @author Heavy Route Team
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    /**
     * Ricerca un veicolo tramite la sua targa univoca.
     * * @param licensePlate La targa del veicolo da ricercare.
     * @return Un {@link Optional} contenente il veicolo se trovato, altrimenti vuoto.
     */
    Optional<Vehicle> findByLicensePlate(String licensePlate);

    /**
     * Verifica l'esistenza di un veicolo con la targa specificata.
     * <p>
     * Utilizzato nel Service Layer durante la creazione di nuovi mezzi per garantire
     * il vincolo di unicità definito nell'ODD.
     * </p>
     * * @param licensePlate La targa da controllare.
     * @return {@code true} se la targa è già presente nel database, {@code false} altrimenti.
     */
    boolean existsByLicensePlate(String licensePlate);

    /**
     * Recupera tutti i veicoli che si trovano in un determinato stato.
     * <p>
     * Tipicamente utilizzato per listare i mezzi con stato {@code AVAILABLE}
     * durante la fase di pianificazione di un viaggio.
     * </p>
     * * @param status Lo stato operativo desiderato (es. AVAILABLE, BUSY).
     * @return Una lista di veicoli corrispondenti allo stato fornito.
     */
    List<Vehicle> findByStatus(VehicleStatus status);

    /**
     * Ricerca veicoli disponibili che soddisfano i requisiti minimi di portata e dimensioni.
     * <p>
     * Questo metodo supporta l'algoritmo di pianificazione filtrando i mezzi che possono
     * effettivamente trasportare il carico eccezionale richiesto.
     * </p>
     * * @param weight Peso del carico in kg.
     * @param height Altezza del carico in metri.
     * @param width Larghezza del carico in metri.
     * @param length Lunghezza del carico in metri.
     * @return Lista di veicoli disponibili e tecnicamente compatibili.
     */
    @Query("SELECT v FROM Vehicle v WHERE v.status = 'AVAILABLE' " +
            "AND v.maxLoadCapacity >= :weight " +
            "AND v.maxHeight >= :height " +
            "AND v.maxWidth >= :width " +
            "AND v.maxLength >= :length")
    List<Vehicle> findCompatibleVehicles(
            @Param("weight") Double weight,
            @Param("height") Double height,
            @Param("width") Double width,
            @Param("length") Double length
    );
}