import 'package:json_annotation/json_annotation.dart';

/// 1. STATO DELLA RICHIESTA (Vista Cliente)
/// Definizione: Rappresenta il ciclo di vita della richiesta dal punto di vista del Committente.
/// Motivazione: Il cliente vuole sapere se la sua merce verrà spedita o no.
/// Implicazioni:
/// - PENDING: Il Pianificatore deve ancora guardarla.
/// - APPROVED: È diventata un "Trip" (Viaggio).
/// - REJECTED: Il Pianificatore l'ha rifiutata (es. merce non trasportabile).
enum RequestStatus {
  @JsonValue("PENDING")
  PENDING,
  @JsonValue("APPROVED")
  APPROVED,
  @JsonValue("PLANNED")
  PLANNED,
  @JsonValue("REJECTED")
  REJECTED,
  @JsonValue("CANCELLED")
  CANCELLED,
  @JsonValue("COMPLETED")
  COMPLETED
}

/// 2. STATO DEL VIAGGIO (Workflow Operativo Interno)
/// Definizione: La macchina a stati finiti (State Machine) più complessa del sistema.
/// Motivazione: Gestisce il flusso a 3 attori (Pianificatore -> Coordinatore -> Autista).
/// Dettagli Implementativi:
/// - FASE 1 (Pianificazione): IN_PLANNING -> WAITING_VALIDATION
/// - FASE 2 (Controllo): VALIDATED (ok) oppure MODIFICATION_REQUESTED (no, cambia percorso)
/// - FASE 3 (Assegnazione): CONFIRMED (Autista assegnato) -> ACCEPTED (Autista accetta)
/// - FASE 4 (Esecuzione): IN_TRANSIT -> DELIVERING -> COMPLETED
enum TripStatus {
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

/// 3. RUOLI UTENTE (RBAC)
/// Definizione: Mappatura esatta dei ruoli definiti in Spring Security.
/// Implicazioni: Usato nel Frontend per nascondere/mostrare menu (es. solo il PL vede "Gestione Flotta").
enum UserRole {
  CUSTOMER,
  LOGISTIC_PLANNER,
  TRAFFIC_COORDINATOR,
  DRIVER,
  ACCOUNT_MANAGER
}

/// 4. STATO RISORSA: VEICOLO
/// Motivazione: Il PL non deve poter assegnare un camion che è rotto o già in viaggio.
enum VehicleStatus {
  AVAILABLE,
  IN_USE,
  MAINTENANCE,
  DECOMMISSIONED
}

/// 5. STATO RISORSA: AUTISTA
/// Motivazione: Rispetto delle normative sui tempi di guida e riposo.
enum DriverStatus {
  FREE,
  ASSIGNED,
  ON_THE_ROAD,
  RESTING
}

/// 6. GESTIONE NOTIFICHE
/// Definizione: Stato di lettura per la campanellina delle notifiche.
enum NotificationStatus {
  UNREAD,
  READ
}

/// 7. TIPI DI NOTIFICA
/// Implicazioni: Determina l'icona e il colore della notifica nel centro messaggi.
enum NotificationType {
  INFO,
  ALERT,
  ASSIGNMENT,
  URGENT
}

/// 8. LIVELLO DI GRAVITÀ EVENTI
/// Implicazioni: Un evento CRITICAL potrebbe bloccare un viaggio o richiedere ricalcolo percorso.
enum EventSeverity {
  LOW,
  MEDIUM,
  CRITICAL
}

/// 9. TIPOLOGIA EVENTI STRADALI
/// Motivazione: Usato dal Driver o dal sistema esterno per segnalare problemi sulla mappa.
enum RoadEventType {
  ACCIDENT,
  CONSTRUCTION,
  TRAFFIC_JAM,
  WEATHER_CONDITION,
  POLICE_CHECKPOINT,
  OBSTACLE
}