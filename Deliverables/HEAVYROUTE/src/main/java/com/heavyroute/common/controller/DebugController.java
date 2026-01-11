package com.heavyroute.common.controller;

import com.heavyroute.common.config.DataSeeder;
import com.heavyroute.core.enums.RequestStatus;
import com.heavyroute.core.repository.TransportRequestRepository;
import com.heavyroute.core.repository.TripRepository;
import com.heavyroute.resources.repository.VehicleRepository;
import com.heavyroute.users.enums.UserRole;
import com.heavyroute.users.model.User;
import com.heavyroute.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller di diagnostica avanzato per lo sviluppo e il testing.
 * <p>
 * Offre endpoint per ispezionare lo stato del sistema e, soprattutto,
 * per <b>resettare l'ambiente</b> senza riavviare il server.
 * </p>
 * <p>
 * <b>SICUREZZA:</b> Attivo SOLO con profilo "!prod".
 * </p>
 */
@RestController
@RequestMapping("/api/debug")
@RequiredArgsConstructor
@Profile("!prod") // Mai in produzione
@Slf4j
public class DebugController {

    private final UserRepository userRepository;
    private final TransportRequestRepository requestRepository;
    private final TripRepository tripRepository;
    private final VehicleRepository vehicleRepository;

    // Iniezione del DataSeeder
    private final DataSeeder dataSeeder;

    /**
     * Esegue un RESET COMPLETO del database
     * <p>
     * <b>Flusso Operativo:</b>
     * <ol>
     * <li>Elimina tutti i dati esistenti rispettando i vincoli di integrità referenziale.</li>
     * <li>Invoca il {@code DataSeeder} per ricreare i dati di default (Admin, Driver, Veicoli).</li>
     * </ol>
     * </p>
     * * @return 200 OK quando il sistema è pronto per un nuovo test.
     */
    @PostMapping("/reset")
    @Transactional // Esegue tutto in una transazione atomica
    public ResponseEntity<String> resetDatabase() {
        log.warn("RICHIESTO RESET DATABASE DA DEBUGGER");

        try {
            // 1. Pulizia tabelle
            tripRepository.deleteAll();     // Elimina viaggi
            requestRepository.deleteAll();  // Elimina richieste
            vehicleRepository.deleteAll();  // Elimina veicoli

            // Cancellazione Utenti
            userRepository.deleteAll();

            // 2. Riesecuzione Seeder
            dataSeeder.run();

            log.info("Database ripristinato allo stato iniziale.");
            return ResponseEntity.ok("Database resettato e ripopolato.");
        } catch (Exception e) {
            log.error("Errore durante il reset del DB", e);
            return ResponseEntity.internalServerError().body("Errore reset: " + e.getMessage());
        }
    }

    /**
     * Scarica lo stato attuale del DB in formato JSON.
     * <p>
     * Include una logica di <b>Sanitizzazione</b>: le password hashate vengono
     * oscurate per evitare confusione o leakage accidentale nei log.
     * </p>
     */
    @GetMapping("/dump")
    public ResponseEntity<Map<String, Object>> dumpDatabase() {
        Map<String, Object> dbDump = new HashMap<>();

        // Recuperiamo gli utenti
        List<User> users = userRepository.findAll();
        users.forEach(u -> u.setPassword("[HIDDEN]"));

        dbDump.put("summary", String.format("DB contiene: %d Utenti, %d Richieste, %d Veicoli",
                users.size(), requestRepository.count(), vehicleRepository.count()));

        dbDump.put("users", users);
        dbDump.put("requests", requestRepository.findAll());
        dbDump.put("vehicles", vehicleRepository.findAll());
        dbDump.put("trips", tripRepository.findAll());

        return ResponseEntity.ok(dbDump);
    }

    /**
     * Endpoint di utilità per filtrare utenti per ruolo.
     * Esempio: GET /api/debug/users?role=DRIVER
     * Utile per verificare se il backend ha creato correttamente i ruoli.
     */
    @GetMapping("/users")
    public ResponseEntity<?> getUsersByRole(@RequestParam(required = false) UserRole role) {
        if (role == null) {
            return ResponseEntity.ok(userRepository.findAll());
        }

        List<User> filtered = userRepository.findAll().stream()
                .filter(u -> u.getRole() == role)
                .peek(u -> u.setPassword("[HIDDEN]"))
                .toList();
        return ResponseEntity.ok(filtered);
    }

    /**
     * Endpoint di utilità per filtrare richieste per stato.
     * Esempio: GET /api/debug/requests?status=PENDING
     */
    @GetMapping("/requests")
    public ResponseEntity<?> getRequestsByStatus(@RequestParam(required = false) RequestStatus status) {
        if (status == null) {
            return ResponseEntity.ok(requestRepository.findAll());
        }
        return ResponseEntity.ok(requestRepository.findByRequestStatus(status));
    }
}