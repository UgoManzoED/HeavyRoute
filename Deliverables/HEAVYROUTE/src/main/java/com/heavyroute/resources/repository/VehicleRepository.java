package com.heavyroute.resources.repository;

import com.heavyroute.resources.model.Vehicle;
import com.heavyroute.resources.enums.VehicleStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    boolean existsByLicensePlate(String licensePlate);

    /**
     * Ricerca veicoli che soddisfano i requisiti di carico e si trovano in uno stato specifico.
     * * @param weight Peso richiesto.
     * @param height Altezza richiesta.
     * @param width Larghezza richiesta.
     * @param length Lunghezza richiesta.
     * @param status Stato operativo del mezzo (parametro dinamico).
     * @return Lista di veicoli compatibili.
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