package com.heavyroute.core.service.impl;

import com.heavyroute.users.model.User;
import com.heavyroute.core.dto.ProposedRouteDTO;
import com.heavyroute.core.enums.TripStatus;
import com.heavyroute.core.model.Route;
import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.model.Trip;
import com.heavyroute.core.repository.RouteRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.core.service.RouteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class RouteServiceImpl implements RouteService {

    private final RouteRepository routeRepository;
    private final TripRepository tripRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ProposedRouteDTO> getProposedRoutes() {
        // 1. Recupera solo i percorsi collegati a viaggi in attesa di validazione
        List<Route> routes = routeRepository.findAllByTripStatus(TripStatus.WAITING_VALIDATION);

        log.info("Trovati {} percorsi da validare.", routes.size());

        // 2. Converte le entità in DTO
        return routes.stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void validateRoute(Long routeId, boolean isApproved) {
        // 1. Recupera la Route
        Route route = routeRepository.findById(routeId)
                .orElseThrow(() -> new RuntimeException("Route non trovata con ID: " + routeId));

        // 2. Recupera il Trip collegato
        Trip trip = route.getTrip();
        if (trip == null) {
            throw new RuntimeException("Incoerenza dati: La Route " + routeId + " non è associata a nessun Trip.");
        }

        // 3. Determina il nuovo stato
        TripStatus newStatus = isApproved ? TripStatus.VALIDATED : TripStatus.MODIFICATION_REQUESTED;

        // 4. Aggiorna e salva
        trip.setStatus(newStatus);
        tripRepository.save(trip);

        log.info("Validazione Route {}: Trip {} passato allo stato {}", routeId, trip.getTripCode(), newStatus);
    }

    /**
     * Mappa l'entità complessa (Route -> Trip -> Request) nel DTO piatto per il frontend.
     */
    private ProposedRouteDTO mapToDTO(Route route) {
        Trip trip = route.getTrip();

        // Valori di default per evitare NullPointerException
        String tripCode = "N/D";
        String origin = "Indirizzo non disponibile";
        String destination = "Indirizzo non disponibile";
        String loadType = "Standard";
        String plannerName = "Ufficio Logistico"; // Default se non tracciamo il planner specifico
        String status = TripStatus.IN_PLANNING.name();

        if (trip != null) {
            tripCode = trip.getTripCode();
            status = trip.getStatus().name();

            // Navigazione verso la TransportRequest per i dettagli logistici
            TransportRequest request = trip.getRequest();

            if (request != null) {
                if (request.getOriginAddress() != null) {
                    origin = request.getOriginAddress();
                }
                if (request.getDestinationAddress() != null) {
                    destination = request.getDestinationAddress();
                }

                // Recupero info dal Cliente (se presente) o Planner (se aggiunto in futuro)
                if (request.getClient() != null) {
                    User client = request.getClient();
                    // Usiamo il cliente come riferimento se manca il campo 'planner' nel Trip
                    plannerName = "Cliente: " + client.getFirstName() + " " + client.getLastName();
                }

                // Recupero info dal LoadDetails (Embedded)
                // Nota: Assumo che LoadDetails abbia un metodo toString() o getter specifici
                if (request.getLoad() != null) {
                    // Qui dovresti usare i getter reali di LoadDetails (es. getLoadType(), getDescription())
                    // Per ora uso un placeholder generico basato sul fatto che l'oggetto esiste
                    loadType = "Carico Eccezionale";
                }
            }
        }

        return ProposedRouteDTO.builder()
                .id(route.getId())
                .orderId(tripCode) // Usiamo il TripCode come identificativo ordine per il TC
                .plannerName(plannerName)
                .origin(origin)
                .destination(destination)
                .routeDescription("Percorso ID: " + route.getId())
                .loadType(loadType)
                .status(status)
                .distance(route.getRouteDistance())
                .duration(route.getRouteDuration())
                .build();
    }
}