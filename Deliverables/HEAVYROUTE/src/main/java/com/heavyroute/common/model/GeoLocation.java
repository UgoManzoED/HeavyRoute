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
@AllArgsConstructor
public class GeoLocation {

    /**
     * Latitudine in gradi decimali.
     * <p>
     * Si utilizza la classe Wrapper {@code Double} invece della primitiva {@code double}
     * per poter gestire il valore {@code null}. Questo è fondamentale se la posizione
     * non è ancora nota (es. un viaggio pianificato ma senza coordinate di start).
     * </p>
     */
    private Double latitude;

    /**
     * Longitudine in gradi decimali.
     */
    private Double longitude;

    /**
     * Restituisce una rappresentazione testuale in formato "lat, lon".
     * Utile per i log o per integrazioni rapide con API di mappe.
     */
    @Override
    public String toString() {
        return latitude + ", " + longitude;
    }
}