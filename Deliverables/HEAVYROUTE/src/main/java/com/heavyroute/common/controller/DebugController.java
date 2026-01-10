package com.heavyroute.common.controller;

import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.resources.repository.RoadEventRepository;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Controller di diagnostica per l'ispezione rapida del database.
 * <p>
 * <b>UTILIZZO:</b> Fornisce endpoint per scaricare il contenuto grezzo delle tabelle
 * in formato JSON. Utile per verificare che il {@code DataSeeder} abbia funzionato
 * o per debugging durante lo sviluppo Frontend.
 * </p>
 * <p>
 * <b>SICUREZZA:</b> L'annotazione {@code @Profile("!prod")} impedisce a Spring
 * di caricare questa classe in ambiente di Produzione. Se questo controller fosse attivo
 * in prod, esporrebbe tutti i dati sensibili (GDPR Breach) pubblicamente.
 * </p>
 */
@RestController
@RequestMapping("/api/debug")
@RequiredArgsConstructor
@Profile("!prod")
public class DebugController {

    private final UserRepository userRepository;
    private final TransportRequestRepository requestRepository;
    private final TripRepository tripRepository;
    private final VehicleRepository vehicleRepository;

    /**
     * Scarica un'istantanea completa del database.
     * <p>
     * Aggrega i risultati di tutte le findAll() in un'unica mappa JSON.
     * </p>
     * * @return Un JSON enorme con conteggi e dati di Utenti, Richieste, Viaggi e Veicoli.
     */
    @GetMapping("/dump")
    public ResponseEntity<Map<String, Object>> dumpDatabase() {
        Map<String, Object> dbDump = new HashMap<>();

        // 1. Utenti
        dbDump.put("users_count", userRepository.count());
        dbDump.put("users_data", userRepository.findAll());

        // 2. Richieste
        dbDump.put("requests_count", requestRepository.count());
        dbDump.put("requests_data", requestRepository.findAll());

        // 3. Viaggi (Trips)
        dbDump.put("trips_count", tripRepository.count());
        dbDump.put("trips_data", tripRepository.findAll());

        // 4. Veicoli
        dbDump.put("vehicles_count", vehicleRepository.count());
        dbDump.put("vehicles_data", vehicleRepository.findAll());

        return ResponseEntity.ok(dbDump);
    }

    /**
     * Endpoint specifico per visualizzare solo i viaggi.
     * Utile se il dump completo è troppo grande o confuso.
     */
    @GetMapping("/trips")
    public ResponseEntity<?> getTripsOnly() {
        return ResponseEntity.ok(tripRepository.findAll());
    }

    /**
     * Endpoint specifico per visualizzare solo le richieste.
     */
    @GetMapping("/requests")
    public ResponseEntity<?> getRequestsOnly() {
        return ResponseEntity.ok(requestRepository.findAll());
    }
}