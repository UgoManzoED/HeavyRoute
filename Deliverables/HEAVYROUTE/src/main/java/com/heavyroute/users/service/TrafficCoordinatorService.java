package com.heavyroute.users.service;

import com.heavyroute.core.dto.RouteResponseDTO;
import java.util.List;

public interface TrafficCoordinatorService {
    List<RouteResponseDTO> getRoutesToValidate();
    void validateRoute(Long routeId, boolean approved);
}