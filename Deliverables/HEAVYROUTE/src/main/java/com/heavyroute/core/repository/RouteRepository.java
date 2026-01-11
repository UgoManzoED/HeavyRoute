package com.heavyroute.core.repository;

import com.heavyroute.core.model.Route;
import com.heavyroute.core.enums.TripStatus; // <--- Importa il tuo Enum
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
    // Spring Data JPA filtrerà i Route in base allo stato del Trip associato
    List<Route> findAllByTripStatus(TripStatus status);
}