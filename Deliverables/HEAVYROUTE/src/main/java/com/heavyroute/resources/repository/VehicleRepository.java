package com.heavyroute.resources.repository;

import com.heavyroute.resources.enums.VehicleStatus;
import com.heavyroute.resources.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Interfaccia di persistenza per la gestione della flotta aziendale (Entità {@link Vehicle}).
 * <p>
 * L'entità utilizza un ID numerico surrogato (ereditato da BaseEntity) come Primary Key,
 * mantenendo la targa come chiave di business univoca.
 * </p>
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    /**
     * Recupera un veicolo specifico tramite la sua targa.
     * <p>
     * Poiché la Primary Key è un ID numerico ({@code Long}), questo metodo è necessario
     * per le operazioni di business che identificano il mezzo tramite la targa
     * </p>
     *
     * @param licensePlate La targa univoca da cercare.
     * @return Un {@link Optional} contenente il veicolo se trovato.
     */
    Optional<Vehicle> findByLicensePlate(String licensePlate);

    /**
     * Recupera tutti i veicoli che si trovano in un determinato stato operativo.
     * <p>
     * Utile per le dashboard di monitoraggio (es. vedere tutti i mezzi in manutenzione).
     * </p>
     *
     * @param status Lo stato del veicolo da ricercare (es. AVAILABLE, MAINTENANCE).
     * @return Lista dei veicoli nello stato richiesto.
     */
    List<Vehicle> findByStatus(VehicleStatus status);

    /**
     * Query Core per l'algoritmo di pianificazione.
     * <p>
     * Trova tutti i veicoli che sono:
     * 1. Attualmente DISPONIBILI (Stato = AVAILABLE).
     * 2. Fisicamente capaci di trasportare il carico specificato (Portata >= Peso Richiesto).
     * 3. Dimensionalmente compatibili (Misure Veicolo >= Misure Carico).
     * </p>
     *
     * @param weight Peso del carico in KG.
     * @param height Altezza del carico in Metri.
     * @param width Larghezza del carico in Metri.
     * @param length Lunghezza del carico in Metri.
     * @return Una lista di veicoli idonei per il trasporto.
     */
    @Query("SELECT v FROM Vehicle v WHERE v.status = com.heavyroute.resources.enums.VehicleStatus.AVAILABLE " +
            "AND v.maxLoadCapacity >= :weight " +
            "AND v.maxHeight >= :height " +
            "AND v.maxWidth >= :width " +
            "AND v.maxLength >= :length")
    List<Vehicle> findCompatibleVehicles(
            @Param("weight") Double weight,
            @Param("height") Double height,
            @Param("width") Double width,
            @Param("length") Double length);
}