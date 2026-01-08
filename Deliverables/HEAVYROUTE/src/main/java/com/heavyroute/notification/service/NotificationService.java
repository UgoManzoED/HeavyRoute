package com.heavyroute.notification.service;

import com.heavyroute.notification.dto.NotificationDTO;
import com.heavyroute.notification.enums.NotificationType;
import java.util.List;

/**
 * Servizio per la gestione delle notifiche di sistema.
 * <p>
 * Implementa la logica per l'invio di avvisi multicanale agli utenti di Heavy Route.
 * </p>
 */
public interface NotificationService {

    /**
     * Crea e invia una notifica a un utente.
     * @param userId ID del destinatario.
     * @param title Titolo dell'avviso.
     * @param message Corpo del messaggio.
     * @param type Tipologia di notifica.
     * @param refId ID dell'entità correlata.
     */
    void send(Long userId, String title, String message, NotificationType type, Long refId);

    /**
     * Recupera tutte le notifiche di un utente.
     * @param userId ID dell'utente.
     * @return Lista di notifiche in ordine cronologico inverso.
     */
    List<NotificationDTO> getNotificationsForUser(Long userId);

    /**
     * Segna una notifica come letta.
     * @param notificationId ID della notifica.
     */
    void markAsRead(Long notificationId);
}