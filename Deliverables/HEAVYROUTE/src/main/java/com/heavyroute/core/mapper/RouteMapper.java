package com.heavyroute.core.mapper;

import com.heavyroute.core.dto.RouteResponseDTO;
import com.heavyroute.core.model.Route;
import org.springframework.stereotype.Component;

/**
 * Mapper specifico per l'entità Route.
 * Segue il principio di responsabilità singola.
 */
@Component
public class RouteMapper {

    public RouteResponseDTO toDTO(Route route) {
        if (route == null) {
            return null;
        }

        return RouteResponseDTO.builder()
                .id(route.getId())
                .routeDescription(route.getDescription())
                .distance(route.getRouteDistance())
                .duration(route.getRouteDuration())
                .polyline(route.getPolyline())
                .build();
    }
}