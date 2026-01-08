package com.heavyroute.notification.enums;

/**
 * Definisce la tipologia di notifica in base alla sua natura e priorità.
 * <ul>
 * <li>{@code INFO}: Aggiornamenti standard sul viaggio.</li>
 * <li>{@code ALERT}: Segnalazioni stradali o variazioni di percorso.</li>
 * <li>{@code ASSIGNMENT}: Nuovi viaggi assegnati agli autisti.</li>
 * <li>{@code URGENT}: Messaggi critici che richiedono attenzione immediata.</li>
 * </ul>
 */
public enum NotificationType {
    INFO, ALERT, ASSIGNMENT, URGENT
}

