package com.heavyroute.common.model;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Value Object che rappresenta una coordinata geografica (GPS).
 * <p>
 * È annotato come {@link Embeddable}, il che significa che non possiede una propria tabella nel DB.
 * I suoi campi (latitude, longitude) diventeranno colonne nella tabella dell'entità che lo ospita
 * (es. Trip, Stop, Vehicle).
 * </p>
 */

@Embeddable
@Data
@NoArgsConstructor
public class GeoLocation {

    /**
     * Latitudine e Longitudine in gradi decimali.
     * <p>
     * Si utilizza la classe Wrapper {@code Double} invece della primitiva {@code double}
     * per poter gestire il valore {@code null}. Questo è fondamentale se la posizione
     * non è ancora nota (es. un viaggio pianificato ma senza coordinate di start).
     * </p>
     */
    private Double latitude;
    private Double longitude;

    /**
     * Costruttore che applica le invarianti di dominio (Regole OCL).
     * <p>
     * Questo metodo implementa il pattern della "Programmazione Difensiva":
     * impedisce la creazione di istanze di {@code GeoLocation} che non abbiano senso
     * nel mondo reale (es. coordinate nulle o fuori dai limiti geografici terrestri).
     * </p>
     *
     * @param latitude  Latitudine in gradi decimali. Deve essere compresa tra -90.0 (Sud) e +90.0 (Nord).
     * @param longitude Longitudine in gradi decimali. Deve essere compresa tra -180.0 (Ovest) e +180.0 (Est).
     * @throws IllegalArgumentException se uno dei parametri è null o viola i limiti geografici.
     */
    public GeoLocation(Double latitude, Double longitude) {
        // Check di esistenza (Null Safety)
        if (latitude == null || longitude == null) {
            throw new IllegalArgumentException("Le coordinate non possono essere nulle");
        }

        // Check di validità del dominio (Range Check)
        if (latitude < -90.0 || latitude > 90.0) {
            throw new IllegalArgumentException("Latitudine non valida: deve essere tra -90 e 90");
        }
        if (longitude < -180.0 || longitude > 180.0) {
            throw new IllegalArgumentException("Longitudine non valida: deve essere tra -180 e 180");
        }
        this.latitude = latitude;
        this.longitude = longitude;
    }

    /**
     * Restituisce una rappresentazione testuale in formato "lat, lon".
     * Utile per i log o per integrazioni rapide con API di mappe.
     */
    @Override
    public String toString() {
        return latitude + ", " + longitude;
    }
}