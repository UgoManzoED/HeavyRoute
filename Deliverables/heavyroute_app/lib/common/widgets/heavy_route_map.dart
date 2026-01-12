import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart'; // Il motore leggero per Web
import 'package:latlong2/latlong.dart';      // Per le coordinate

class HeavyRouteMap extends StatelessWidget {
  const HeavyRouteMap({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Recuperiamo la TUA chiave Mapbox dal file sicuro
    final String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');

    // 2. Definiamo lo stile Mapbox (Strade classiche)
    const String mapboxStyleId = 'mapbox/streets-v12';
    // Oppure satellite: 'mapbox/satellite-v9'

    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          // Centriamo sull'Italia
          initialCenter: LatLng(41.8719, 12.5674),
          initialZoom: 6.0,
        ),
        children: [
          // 3. Qui avviene la MAGIA:
          // Diciamo a flutter_map di prendere le immagini dai server di MAPBOX
          // usando la TUA CHIAVE per autenticarsi.
          TileLayer(
            // Questo è l'indirizzo ufficiale di Mapbox per le "Raster Tiles"
            urlTemplate: "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
            additionalOptions: {
              'accessToken': accessToken, // <--- ECCO LA TUA CHIAVE
              'id': mapboxStyleId,        // <--- ECCO LO STILE MAPBOX
            },
            // Importante per rispettare i termini di servizio Mapbox
            userAgentPackageName: 'com.heavyroute.app',
          ),

          // Esempio Marker su Roma
          const MarkerLayer(
            markers: [
              Marker(
                point: LatLng(41.9028, 12.4964),
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),

          // Copyright Mapbox (Obbligatorio per la legalità)
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'Mapbox',
                onTap: () {}, // Link ai termini se necessario
              ),
              TextSourceAttribution(
                'OpenStreetMap',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}