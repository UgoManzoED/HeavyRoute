package com.heavyroute.notification.dto;

import com.heavyroute.notification.model.Notification;
import org.springframework.stereotype.Component;

/**
 * Componente responsabile della mappatura tra l'entità {@link Notification} e il relativo DTO.
 * <p>
 * Centralizza la logica di conversione per garantire coerenza nella rappresentazione
 * dei messaggi verso il frontend.
 * </p>
 * * @author Heavy Route Team
 */
@Component
public class NotificationMapper {

    /**
     * Converte un'entità {@link Notification} in un {@link NotificationDTO}.
     * * @param entity L'entità persistente da convertire.
     * @return Il DTO popolato con i dati della notifica e la data di creazione.
     */
    public NotificationDTO toDTO(Notification entity) {
        if (entity == null) return null;

        NotificationDTO dto = new NotificationDTO();
        dto.setId(entity.getId());
        dto.setTitle(entity.getTitle());
        dto.setMessage(entity.getMessage());
        dto.setType(entity.getType());
        dto.setStatus(entity.getStatus());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setReferenceId(entity.getReferenceId());

        return dto;
    }
}