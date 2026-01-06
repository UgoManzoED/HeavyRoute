package com.heavyroute.core.repository;

import com.heavyroute.core.model.TransportRequest;
import com.heavyroute.core.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TransportRequestRepository extends JpaRepository<TransportRequest, Long> {
    List<TransportRequest> findByStatus(RequestStatus status);
}

