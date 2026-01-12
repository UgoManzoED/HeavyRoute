package com.heavyroute.core.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.heavyroute.common.exception.BusinessRuleException;
import com.heavyroute.common.model.GeoLocation;
import com.heavyroute.core.model.Route;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ExternalMapService {

    @Value("${mapbox.api.key}")
    private String mapboxKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public Route calculateFullRoute(String originAddress, String destinationAddress) {
        GeoLocation start = getGeoLocation(originAddress);
        GeoLocation end = getGeoLocation(destinationAddress);

        String directionsUrl = UriComponentsBuilder
                .fromHttpUrl("https://api.mapbox.com/directions/v5/mapbox/driving/"
                        + start.getLongitude() + "," + start.getLatitude() + ";"
                        + end.getLongitude() + "," + end.getLatitude())
                .queryParam("geometries", "polyline6")
                .queryParam("overview", "full")
                .queryParam("radiuses", "unlimited;unlimited")
                .queryParam("access_token", mapboxKey)
                .toUriString();

        try {
            JsonNode response = restTemplate.getForObject(directionsUrl, JsonNode.class);

            // --- CONTROLLO DI SICUREZZA ---
            if (response == null || !response.has("routes") || response.get("routes").isEmpty()) {
                log.error("❌ Mapbox non ha trovato rotte tra {} e {}", originAddress, destinationAddress);
                throw new BusinessRuleException("Impossibile calcolare un percorso stradale tra questi due punti.");
            }

            JsonNode routeNode = response.get("routes").get(0);

            return Route.builder()
                    .description("Percorso da " + originAddress + " a " + destinationAddress)
                    .routeDistance(routeNode.get("distance").asDouble() / 1000.0)
                    .routeDuration(routeNode.get("duration").asDouble() / 60.0)
                    .polyline(routeNode.get("geometry").asText())
                    .startLocation(start)
                    .endLocation(end)
                    .build();
        } catch (BusinessRuleException e) {
            throw e;
        } catch (org.springframework.web.client.HttpClientErrorException.UnprocessableEntity e) {
            log.error("❌ Mapbox rifiuta la rotta (troppo lunga o impossibile): {}", e.getResponseBodyAsString());
            throw new BusinessRuleException("La rotta calcolata è troppo lunga o non percorribile via terra.");
        } catch (Exception e) {
            log.error("🔥 Errore imprevisto Directions: {}", e.getMessage());
            throw new RuntimeException("Errore tecnico nel calcolo della rotta.");
        }
    }

    private GeoLocation getGeoLocation(String address) {
        String geocodingUrl = UriComponentsBuilder
                .fromHttpUrl("https://api.mapbox.com/geocoding/v5/mapbox.places/" + address + ".json")
                .queryParam("limit", 1)
                .queryParam("country", "it")
                .queryParam("types", "address,place,poi")
                .queryParam("access_token", mapboxKey)
                .toUriString();

        try {
            JsonNode response = restTemplate.getForObject(geocodingUrl, JsonNode.class);
            if (response == null || response.get("features").isEmpty()) {
                throw new BusinessRuleException("Indirizzo non trovato in Italia: " + address);
            }
            JsonNode center = response.get("features").get(0).get("center");
            return new GeoLocation(center.get(1).asDouble(), center.get(0).asDouble());
        } catch (Exception e) {
            throw new BusinessRuleException("Errore nel trovare la posizione per: " + address);
        }
    }
}