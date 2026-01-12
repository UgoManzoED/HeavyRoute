import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverNavigationScreen extends StatelessWidget {
  const DriverNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAPPA FULL SCREEN
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(45.4642, 9.1900), // Milano (Mockup)
              initialZoom: 16.0, // Zoom ravvicinato per navigazione
            ),
            children: [
              TileLayer(
                // Uso streets-v11 per compatibilità garantita con il tuo token
                urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: {
                  'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? '',
                },
                userAgentPackageName: 'com.heavyroute.app',
              ),

              const MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(45.4642, 9.1900),
                    width: 60,
                    height: 60,
                    // Icona Freccia Navigazione grande
                    child: Icon(Icons.navigation, color: Colors.blueAccent, size: 50),
                    alignment: Alignment.center,
                  ),
                ],
              ),

              // --- FIX FONDAMENTALE PER WEB (Evita errore 404 Logo) ---
              RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution('Mapbox', onTap: () {}),
                  TextSourceAttribution('OpenStreetMap', onTap: () {}),
                ],
              ),
            ],
          ),

          // 2. PANNELLO SUPERIORE (Istruzioni Svolta)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A), // Dark Navy
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.turn_right, color: Colors.white, size: 48),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tra 200m", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text("Svolta a destra in Via Tortona",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. PANNELLO INFERIORE (Info Viaggio e Stop)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("14 min (5.2 km)", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Arrivo previsto: 10:45", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text("TERMINA"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F), // Rosso Stop
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}