package com.heavyroute.notification.dto;

import com.heavyroute.notification.enums.NotificationStatus;
import com.heavyroute.notification.enums.NotificationType;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * Data Transfer Object per la visualizzazione delle notifiche.
 */
@Data
public class NotificationDTO {
    private Long id;
    private String title;
    private String message;
    private NotificationType type;
    private NotificationStatus status;
    private LocalDateTime createdAt;
    private Long referenceId;
}