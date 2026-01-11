package com.heavyroute.users.service.impl;

import com.heavyroute.core.dto.RouteResponseDTO; // <--- DTO Nuovo
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.repository.RouteRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.users.service.TrafficCoordinatorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class TrafficCoordinatorServiceImpl implements TrafficCoordinatorService {

    private final RouteRepository routeRepository;
    private final TripRepository tripRepository;

    @Override
    @Transactional(readOnly = true)
    public List<RouteResponseDTO> getRoutesToValidate() {
        // Recupera i percorsi dei viaggi in attesa
        List<Route> routes = routeRepository.findAllByTripStatus(TripStatus.WAITING_VALIDATION);

        return routes.stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void validateRoute(Long routeId, boolean approved) {
        Route route = routeRepository.findById(routeId)
                .orElseThrow(() -> new RuntimeException("Route non trovata: " + routeId));

        Trip trip = route.getTrip();
        if (trip == null) throw new RuntimeException("Trip non trovato");

        // Logica cambio stato
        TripStatus newStatus = approved ? TripStatus.VALIDATED : TripStatus.MODIFICATION_REQUESTED;

        trip.setStatus(newStatus);
        tripRepository.save(trip);

        log.info("Trip {} validato. Nuovo stato: {}", trip.getTripCode(), newStatus);
    }

    // --- MAPPING AGGIORNATO PER RouteResponseDTO ---
    private RouteResponseDTO mapToDTO(Route route) {
        Trip trip = route.getTrip();
        TransportRequest req = trip.getRequest();

        // Valori di default
        String plannerName = "Sistema";
        String origin = "N/D";
        String destination = "N/D";
        String loadType = "Standard";

        if (req != null) {
            if (req.getOriginAddress() != null) origin = req.getOriginAddress();
            if (req.getDestinationAddress() != null) destination = req.getDestinationAddress();

            // Recupero LoadType (assumendo che LoadDetails abbia un campo type o description)
            if (req.getLoad() != null && req.getLoad().getType() != null) {
                loadType = req.getLoad().getType();
            }

            // Recupero Planner/Cliente
            if (req.getClient() != null) {
                plannerName = req.getClient().getFirstName() + " " + req.getClient().getLastName();
            }
        }

        // Costruzione del DTO usando il Builder di Lombok come definito nel tuo file
        return RouteResponseDTO.builder()
                .id(route.getId())
                .tripCode(trip.getTripCode()) // Usa tripCode invece di orderId
                .plannerName(plannerName)
                .origin(origin)
                .destination(destination)
                .loadType(loadType)
                .status(trip.getStatus()) // Passa direttamente l'Enum TripStatus
                .routeDescription("Viaggio " + trip.getTripCode())
                .distance(route.getRouteDistance())
                .duration(route.getRouteDuration())
                .build();
    }
}