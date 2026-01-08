package com.heavyroute.notification.controller;

import com.heavyroute.notification.dto.NotificationDTO;
import com.heavyroute.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller REST per la gestione delle notifiche lato client.
 * <p>
 * Espone gli endpoint per la consultazione degli avvisi e l'aggiornamento dello stato di lettura.
 * </p>
 */
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * Recupera le notifiche dell'utente corrente.
     * <p>In una implementazione reale, l'ID verrebbe estratto dal Token JWT.</p>
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<NotificationDTO>> getMyNotifications(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getNotificationsForUser(userId));
    }

    /**
     * Endpoint per confermare la lettura di una notifica.
     */
    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.noContent().build();
    }
}