package com.heavyroute.notification.service.impl;

import com.heavyroute.common.exception.ResourceNotFoundException;
import com.heavyroute.notification.dto.NotificationDTO;
import com.heavyroute.notification.enums.NotificationStatus;
import com.heavyroute.notification.enums.NotificationType;
import com.heavyroute.notification.dto.NotificationMapper;
import com.heavyroute.notification.model.Notification;
import com.heavyroute.notification.repository.NotificationRepository;
import com.heavyroute.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementazione del servizio di gestione delle notifiche.
 * <p>
 * Gestisce il ciclo di vita delle comunicazioni verso gli utenti, permettendo
 * l'invio di avvisi relativi a viaggi, assegnazioni o criticità stradali.
 * </p>
 * * @author Heavy Route Team
 */
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;

    /**
     * {@inheritDoc}
     * <p>
     * Crea una nuova notifica in stato {@code UNREAD}. In una evoluzione futura,
     * questo metodo potrebbe attivare l'invio di una Push Notification tramite Firebase
     * o l'aggiornamento di un socket per la Dashboard.
     * </p>
     */
    @Override
    @Transactional
    public void send(Long userId, String title, String message, NotificationType type, Long refId) {
        Notification notification = Notification.builder()
                .recipientId(userId)
                .title(title)
                .message(message)
                .type(type)
                .status(NotificationStatus.UNREAD)
                .referenceId(refId)
                .build();

        notificationRepository.save(notification);
    }

    /**
     * {@inheritDoc}
     * <p>
     * Recupera lo storico delle notifiche per un utente specifico, ordinate
     * dalla più recente alla meno recente.
     * </p>
     */
    @Override
    @Transactional(readOnly = true)
    public List<NotificationDTO> getNotificationsForUser(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(notificationMapper::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * {@inheritDoc}
     * <p>
     * Aggiorna lo stato di una specifica notifica a {@code READ}.
     * </p>
     * * @throws ResourceNotFoundException se l'identificativo della notifica non esiste.
     */
    @Override
    @Transactional
    public void markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notifica non trovata con ID: " + notificationId));

        notification.setStatus(NotificationStatus.READ);
        notificationRepository.save(notification);
    }
}