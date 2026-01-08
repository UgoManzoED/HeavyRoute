package com.heavyroute.notication.model;

import com.heavyroute.common.model.BaseEntity;
import com.heavyroute.notication.enums.NotificationStatus;
import com.heavyroute.notication.enums.NotificationType;
import jakarta.persistence.*;
import lombok.*;

/**
 * Entità persistente che rappresenta una notifica inviata a un utente.
 * <p>
 * Estende {@link BaseEntity} per ereditare l'ID e i campi di auditing (createdAt).
 * Ogni notifica è legata a un destinatario specifico identificato dal suo userId.
 * </p>
 */
@Entity
@Table(name = "notifications")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification extends BaseEntity {

    /**
     * ID dell'utente destinatario della notifica.
     */
    @Column(nullable = false)
    private Long recipientId;

    /**
     * Titolo sintetico della notifica.
     */
    @Column(nullable = false)
    private String title;

    /**
     * Testo esteso del messaggio.
     */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationStatus status;

    /**
     * Riferimento opzionale all'entità che ha scatenato la notifica (es. Trip ID).
     */
    private Long referenceId;
}