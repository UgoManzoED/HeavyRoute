package com.heavyroute.core.service;

import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.dto.RequestDetailDTO;
import java.util.List;

public interface TransportRequestService {
    RequestDetailDTO createRequest(RequestCreationDTO dto);
    List<RequestDetailDTO> getAllRequests();
}