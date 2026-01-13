package com.heavyroute.core.enums;

public enum RequestStatus {
    /** La richiesta è stata creata ma non ancora processata. */
    PENDING,

    /** La richiesta è stata convalidata e accettata. */
    APPROVED,

    /** La richiesta è stata declinata (spesso richiede una motivazione). */
    REJECTED,

    PLANNED,

    /** Il trasporto è fisicamente in corso (TripStatus = IN_TRANSIT). */
    IN_PROGRESS,

    /** La richiesta è stata annullata dall'utente prima dell'approvazione. */
    CANCELLED,

    /** La richiesta è stata completata (es. dopo l'approvazione, l'azione è stata eseguita). */
    COMPLETED,

}