package com.heavyroute.core.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.model.GeoLocation;
import com.heavyroute.core.model.Route;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ExternalMapService {

    @Value("${mapbox.api.key}")
    private String mapboxKey;

    private final RestTemplate restTemplate = new RestTemplate();

    // --- 1. DIZIONARIO LUOGHI NOTI ---
    // Questo garantisce che i dati di test siano sempre precisi al metro.
    private static final Map<String, GeoLocation> KNOWN_HUBS = new HashMap<>();

    static {
        // CAMPANIA
        KNOWN_HUBS.put("Via Argine 425, Napoli", new GeoLocation(40.8576, 14.3056)); // Hitachi Napoli
        KNOWN_HUBS.put("Napoli Port", new GeoLocation(40.8433, 14.2625)); // Porto Varco Pisacane
        KNOWN_HUBS.put("Napoli", new GeoLocation(40.8518, 14.2681));
        KNOWN_HUBS.put("Universita' di Fisciano", new GeoLocation(40.7750, 14.7890)); // Campus UNISA
        KNOWN_HUBS.put("Campus Fisciano", new GeoLocation(40.7750, 14.7890));

        // LIGURIA
        KNOWN_HUBS.put("Piazzale Traghetti, Genova", new GeoLocation(44.4141, 8.9137)); // Terminal Traghetti
        KNOWN_HUBS.put("Genova", new GeoLocation(44.4056, 8.9463));

        // LOMBARDIA
        KNOWN_HUBS.put("Via Torino, Milano", new GeoLocation(45.4626, 9.1866));
        KNOWN_HUBS.put("Milano", new GeoLocation(45.4642, 9.1900));

        // EMILIA ROMAGNA
        KNOWN_HUBS.put("Interporto Bologna", new GeoLocation(44.6567, 11.4285)); // Bentivoglio
        KNOWN_HUBS.put("Bologna", new GeoLocation(44.4949, 11.3426));

        // TOSCANA
        KNOWN_HUBS.put("Hitachi Pistoia", new GeoLocation(43.9231, 10.9272)); // Hitachi Rail
        KNOWN_HUBS.put("Pistoia", new GeoLocation(43.9308, 10.9180));
        KNOWN_HUBS.put("Piazza della Stazione, Firenze", new GeoLocation(43.7765, 11.2479));
        KNOWN_HUBS.put("Firenze", new GeoLocation(43.7696, 11.2558));

        // LAZIO
        KNOWN_HUBS.put("Roma Smistamento", new GeoLocation(41.9542, 12.5367));
        KNOWN_HUBS.put("Roma", new GeoLocation(41.9028, 12.4964));

        // PIEMONTE
        KNOWN_HUBS.put("Torino", new GeoLocation(45.0703, 7.6869));
    }

    /**
     * Calcola la rotta completa tra due indirizzi.
     */
    public Route calculateFullRoute(String originAddress, String destinationAddress) {
        System.out.println("🛣️ [MapService] Inizio calcolo rotta: '" + originAddress + "' -> '" + destinationAddress + "'");

        // 1. Risoluzione Geocoding (Dizionario -> API)
        GeoLocation start = resolveLocation(originAddress);
        GeoLocation end = resolveLocation(destinationAddress);

        System.out.println("📍 [MapService] Coordinate definitive:");
        System.out.println("   Start: " + start.getLatitude() + ", " + start.getLongitude());
        System.out.println("   End:   " + end.getLatitude() + ", " + end.getLongitude());

        // 2. Chiamata Directions API
        String directionsUrl = UriComponentsBuilder
                .fromHttpUrl("https://api.mapbox.com/directions/v5/mapbox/driving/"
                        + start.getLongitude() + "," + start.getLatitude() + ";"
                        + end.getLongitude() + "," + end.getLatitude())
                .queryParam("geometries", "polyline") // Precisione 5
                .queryParam("overview", "full")
                .queryParam("steps", "false")
                .queryParam("access_token", mapboxKey)
                .toUriString();

        try {
            System.out.println("📡 [MapService] API Call: " + directionsUrl);

            JsonNode response = restTemplate.getForObject(directionsUrl, JsonNode.class);

            if (response == null || !response.has("routes") || response.get("routes").isEmpty()) {
                System.err.println("❌ [MapService] Nessuna rotta stradale trovata.");
                throw new BusinessRuleException("Impossibile calcolare un percorso stradale tra questi due punti.");
            }

            JsonNode routeNode = response.get("routes").get(0);

            double distanceKm = routeNode.get("distance").asDouble() / 1000.0;
            double durationMin = routeNode.get("duration").asDouble() / 60.0;
            String polyline = routeNode.get("geometry").asText();

            System.out.println("✅ [MapService] Rotta OK: " + String.format("%.2f", distanceKm) + " km, " + String.format("%.0f", durationMin) + " min.");

            return Route.builder()
                    .description(originAddress + " -> " + destinationAddress)
                    .routeDistance(distanceKm)
                    .routeDuration(durationMin)
                    .polyline(polyline)
                    .startLocation(start)
                    .endLocation(end)
                    .build();

        } catch (BusinessRuleException e) {
            throw e;
        } catch (Exception e) {
            System.err.println("🔥 [MapService] Errore Directions API: " + e.getMessage());
            throw new RuntimeException("Errore calcolo rotta: " + e.getMessage());
        }
    }

    /**
     * Logica Ibrida: Controlla prima i luoghi noti, poi chiama l'API.
     */
    private GeoLocation resolveLocation(String address) {
        String cleanAddr = address.trim();

        // STEP 1: Controllo Luoghi Noti (Database statico)
        if (KNOWN_HUBS.containsKey(cleanAddr)) {
            System.out.println("💎 [MapService] Trovato HUB noto: " + cleanAddr);
            return KNOWN_HUBS.get(cleanAddr);
        }

        // STEP 2: Fallback su API Mapbox (con logica Retry)
        return getGeoLocationFromApi(cleanAddr);
    }

    /**
     * Chiama l'API Mapbox con logica di fallback sulla città.
     */
    private GeoLocation getGeoLocationFromApi(String address) {
        // Tentativo 1: Indirizzo completo
        try {
            return executeMapboxGeocoding(address);
        } catch (BusinessRuleException e) {
            System.out.println("⚠️ [MapService] Tentativo 1 fallito per: '" + address + "'. Provo solo con la città...");

            // Tentativo 2: Estrazione e ricerca solo Città (es. "Via xyz, Milano" -> "Milano")
            if (address.contains(",")) {
                String[] parts = address.split(",");
                // Prende l'ultima parte significativa (es. Città)
                String cityFallback = parts.length > 1 ? parts[1].trim() : parts[0].trim();

                try {
                    return executeMapboxGeocoding(cityFallback);
                } catch (Exception ex) {
                    System.err.println("❌ [MapService] Fallito anche il fallback città: " + cityFallback);
                }
            }
            throw e;
        }
    }

    private GeoLocation executeMapboxGeocoding(String queryAddress) {
        try {
            String cleanAddress = queryAddress.trim();
            if (!cleanAddress.toLowerCase().contains("italia")) {
                cleanAddress += ", Italia";
            }

            String encodedAddress = UriUtils.encode(cleanAddress, StandardCharsets.UTF_8);

            String geocodingUrl = UriComponentsBuilder
                    .fromHttpUrl("https://api.mapbox.com/geocoding/v5/mapbox.places/" + encodedAddress + ".json")
                    .queryParam("limit", "1")
                    .queryParam("country", "it")
                    .queryParam("types", "address,place,poi,locality")
                    .queryParam("access_token", mapboxKey)
                    .build(true)
                    .toUriString();

            System.out.println("🔍 [MapService] API Query: " + cleanAddress);

            JsonNode response = restTemplate.getForObject(geocodingUrl, JsonNode.class);

            if (response == null || !response.has("features") || response.get("features").isEmpty()) {
                throw new BusinessRuleException("Nessun risultato per: " + cleanAddress);
            }

            JsonNode bestMatch = response.get("features").get(0);
            JsonNode center = bestMatch.get("center");

            System.out.println("✅ [MapService] Trovato: " + bestMatch.get("place_name").asText());

            return new GeoLocation(center.get(1).asDouble(), center.get(0).asDouble());

        } catch (Exception e) {
            throw new BusinessRuleException("Errore geocoding: " + e.getMessage());
        }
    }
}