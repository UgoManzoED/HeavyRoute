package com.heavyroute.core.controller;

import com.heavyroute.core.dto.RequestCreationDTO;
import com.heavyroute.core.dto.RequestDetailDTO;
import com.heavyroute.core.service.TransportRequestService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/requests")
public class TransportRequestController {

    private final TransportRequestService requestService;

    // Dipende dall'interfaccia, non dall'implementazione [cite: 73]
    public TransportRequestController(TransportRequestService requestService) {
        this.requestService = requestService;
    }

    @PostMapping
    public ResponseEntity<RequestDetailDTO> create(@Valid @RequestBody RequestCreationDTO dto) {
        return ResponseEntity.ok(requestService.createRequest(dto));
    }

    @GetMapping
    public ResponseEntity<List<RequestDetailDTO>> getAll() {
        return ResponseEntity.ok(requestService.getAllRequests());
    }
}