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
 * Repository JPA per la gestione della persistenza dell'entità {@link Vehicle}.
 * <p>
 * Fornisce i metodi necessari per l'accesso ai dati della flotta di Logistica Mediterranea.
 * Include logiche per la verifica dell'unicità delle targhe e per la selezione dei mezzi
 * idonei al trasporto in base ai vincoli fisici.
 * </p>
 *
 * @author Heavy Route Team
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    /**
     * Ricerca un veicolo tramite la sua targa.
     *
     * @param licensePlate La targa del veicolo da ricercare.
     * @return Un {@link Optional} contenente il veicolo se presente.
     */
    Optional<Vehicle> findByLicensePlate(String licensePlate);

    /**
     * Verifica se esiste già un veicolo registrato con la targa fornita.
     * <p>
     * Utilizzato nel Service Layer per garantire il vincolo di unicità prima del salvataggio
     * di un nuovo mezzo.
     * </p>
     *
     * @param licensePlate La targa da controllare.
     * @return {@code true} se la targa è già presente nel database.
     */
    boolean existsByLicensePlate(String licensePlate);

    /**
     * Recupera l'elenco dei veicoli filtrati per stato operativo.
     *
     * @param status Lo stato del veicolo (es. AVAILABLE, BUSY, MAINTENANCE).
     * @return Una lista di {@link Vehicle} corrispondenti allo stato.
     */
    List<Vehicle> findByStatus(VehicleStatus status);

    /**
     * Ricerca i veicoli che soddisfano i requisiti minimi di carico e si trovano in uno stato specifico.
     * <p>
     * Questo metodo implementa la logica di filtraggio per la pianificazione delle risorse (FR17),
     * permettendo di trovare i mezzi compatibili con le specifiche del carico eccezionale.
     * </p>
     *
     * @param weight Peso del carico in kg.
     * @param height Altezza del carico in metri.
     * @param width  Larghezza del carico in metri.
     * @param length Lunghezza del carico in metri.
     * @param status Stato operativo richiesto (es. {@link VehicleStatus#AVAILABLE}).
     * @return Lista di veicoli che possono trasportare il carico indicato e si trovano nello stato fornito.
     */
    @Query("SELECT v FROM Vehicle v WHERE v.status = :status " +
            "AND v.maxLoadCapacity >= :weight " +
            "AND v.maxHeight >= :height " +
            "AND v.maxWidth >= :width " +
            "AND v.maxLength >= :length")
    List<Vehicle> findCompatibleVehicles(
            @Param("weight") Double weight,
            @Param("height") Double height,
            @Param("width") Double width,
            @Param("length") Double length,
            @Param("status") VehicleStatus status
    );
}