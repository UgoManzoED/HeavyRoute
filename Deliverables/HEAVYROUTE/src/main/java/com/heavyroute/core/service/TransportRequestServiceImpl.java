package com.heavyroute.core.service;

import com.heavyroute.core.dto.*;
import com.heavyroute.core.model.*;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.repository.TransportRequestRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TransportRequestServiceImpl implements TransportRequestService {

    private final TransportRequestRepository repository;

    public TransportRequestServiceImpl(TransportRequestRepository repository) {
        this.repository = repository;
    }

    @Override
    public RequestDetailDTO createRequest(RequestCreationDTO dto) {
        TransportRequest request = new TransportRequest();
        request.setOriginAddress(dto.getOrigin());
        request.setDestinationAddress(dto.getDestination());
        request.setPickupDate(dto.getPickupDate());
        request.setRequestStatus(RequestStatus.PENDING); // [cite: 1001]

        LoadDetails load = new LoadDetails();
        load.setWeightKg(dto.getWeight());
        load.setHeight(dto.getHeight());
        load.setWidth(dto.getWidth());
        load.setLength(dto.getLength());
        request.setLoad(load);

        TransportRequest saved = repository.save(request);
        return mapToDetailDTO(saved);
    }

    @Override
    public List<RequestDetailDTO> getAllRequests() {
        return repository.findAll().stream()
                .map(this::mapToDetailDTO)
                .collect(Collectors.toList());
    }

    private RequestDetailDTO mapToDetailDTO(TransportRequest entity) {
        RequestDetailDTO dto = new RequestDetailDTO();
        dto.setId(entity.getId());
        dto.setOriginAddress(entity.getOriginAddress());
        dto.setDestinationAddress(entity.getDestinationAddress());
        dto.setPickupDate(entity.getPickupDate());
        dto.setStatus(entity.getRequestStatus());
        dto.setWeight(entity.getLoad().getWeightKg());
        return dto;
    }
}