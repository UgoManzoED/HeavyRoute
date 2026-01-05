package com.heavyroute.core.enums;

public enum TripStatus {
    IN_PLANNING,            // Appena creato dal PL
    WAITING_VALIDATION,     // Inviato al TC
    VALIDATED,              // Approvato dal TC
    MODIFICATION_REQUESTED, // Rifiutato dal TC
    CONFIRMED,              // Confermato dal PL (pronto per autista)
    ACCEPTED,               // Accettato dall'autista
    IN_TRANSIT,             // In viaggio
    PAUSED,                 // Guasto o problema
    DELIVERING,             // In prossimità del luogo di consegna
    COMPLETED,              // Consegna effettuata
    CANCELLED               // Annullato
}
