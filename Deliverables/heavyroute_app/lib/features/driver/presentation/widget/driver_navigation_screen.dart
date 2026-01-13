import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverNavigationScreen extends StatelessWidget {
  final Map<String, dynamic> trip; // Dati reali del viaggio

  const DriverNavigationScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // 1. Estrazione Dati Rotta
    final routeData = trip['route'];

    // Default: Roma (se manca la rotta)
    LatLng start = const LatLng(41.9028, 12.4964);
    LatLng end = const LatLng(45.4642, 9.1900);
    List<LatLng> polylinePoints = [start, end];

    if (routeData != null) {
      if (routeData['startLat'] != null) {
        start = LatLng(routeData['startLat'], routeData['startLon']);
      }
      if (routeData['endLat'] != null) {
        end = LatLng(routeData['endLat'], routeData['endLon']);
      }

      // Decodifica Polyline (Se il backend manda una stringa codificata o una lista di punti)
      // Per semplicità qui assumiamo una linea retta o usiamo i punti start/end
      // Se nel JSON 'polyline' è una stringa codificata, servirebbe un decoder.
      // Se 'polyline' non è gestita, disegniamo una retta Start -> End.
      polylinePoints = [start, end];
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAPPA FULL SCREEN
          FlutterMap(
            options: MapOptions(
              initialCenter: start, // Centra sul punto di partenza
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: {
                  'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? '',
                },
              ),

              // Disegna il percorso
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 5.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),

              MarkerLayer(
                markers: [
                  // Marker START (Freccia Navigazione)
                  Marker(
                    point: start,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.navigation, color: Colors.blueAccent, size: 50),
                    alignment: Alignment.center,
                  ),
                  // Marker END (Bandiera Arrivo)
                  Marker(
                    point: end,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.flag, color: Colors.red, size: 40),
                    alignment: Alignment.topCenter,
                  ),
                ],
              ),

              // Attribution Widget (Anti-Crash)
              RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution('Mapbox', onTap: () {}),
                ],
              ),
            ],
          ),

          // 2. PANNELLO SUPERIORE (Info Destinazione)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.straight, color: Colors.white, size: 40),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Destinazione", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          trip['request']?['destinationAddress'] ?? "Destinazione Sconosciuta",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

          // 3. PANNELLO INFERIORE (Termina Navigazione)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${routeData?['distance'] ?? '-'} km", // Mostra distanza reale se c'è
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                      const Text("In navigazione...", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text("ESCI"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
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