package com.heavyroute.notification.repository;

import com.heavyroute.notification.model.Notification;
import com.heavyroute.notification.enums.NotificationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);
    long countByRecipientIdAndStatus(Long recipientId, NotificationStatus status);
}