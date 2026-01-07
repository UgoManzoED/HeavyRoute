package com.heavyroute.resources.enums;

/**
 * Livello di gravità dell'evento stradale.
 * <p>
 * Determina l'impatto sul calcolo del percorso (es. CRITICAL richiede deviazione obbligatoria).
 * </p>
 */
public enum EventSeverity {
    LOW,
    MEDIUM,
    CRITICAL
}