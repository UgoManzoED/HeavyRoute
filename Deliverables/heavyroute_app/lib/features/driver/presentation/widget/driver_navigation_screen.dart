import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DriverNavigationScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const DriverNavigationScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // 1. Estrazione Dati Rotta e Coordinate Base
    final routeData = trip['route'];
    final requestData = trip['request'];

    LatLng start = const LatLng(41.9028, 12.4964);
    LatLng end = const LatLng(45.4642, 9.1900);

    if (routeData != null) {
      if (routeData['startLat'] != null) start = LatLng(routeData['startLat'], routeData['startLon']);
      if (routeData['endLat'] != null) end = LatLng(routeData['endLat'], routeData['endLon']);
    } else if (requestData != null) {
    }

    // 2. LOGICA DI DECODIFICA PERCORSO (Cuore della modifica)
    List<LatLng> polylinePoints = [];

    // Cerchiamo la stringa polyline nel JSON (può chiamarsi 'polyline', 'geometry', etc.)
    String? encodedPolyline = routeData?['polyline'] ?? routeData?['geometry'];

    if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
      try {
        PolylinePoints polylineDecoder = PolylinePoints();
        List<PointLatLng> result = polylineDecoder.decodePolyline(encodedPolyline);

        if (result.isNotEmpty) {
          // Conversione da PointLatLng a LatLng (latlong2)
          polylinePoints = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }
      } catch (e) {
        debugPrint("⚠️ Errore decodifica polyline navigazione: $e");
      }
    }

    // Fallback: Se la decodifica fallisce o non c'è stringa, usiamo la retta Start->End
    if (polylinePoints.isEmpty) {
      polylinePoints = [start, end];
    }

    // 3. Calcolo Distanza per UI (Opzionale, formatta bene i km)
    String distanceDisplay = "- km";
    if (routeData != null && routeData['distance'] != null) {
      double dist = (routeData['distance'] is int)
          ? (routeData['distance'] as int).toDouble()
          : routeData['distance'];
      // Se è in metri converti, se è km lascia così (assumo km dal tuo model precedente)
      distanceDisplay = "${dist.toStringAsFixed(1)} km";
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAPPA FULL SCREEN
          FlutterMap(
            options: MapOptions(
              initialCenter: start, // Centra sul punto di partenza
              initialZoom: 15.0,    // Zoom più alto per la navigazione
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // Permetti pinch/pan
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/navigation-day-v1/tiles/{z}/{x}/{y}?access_token={accessToken}",
                // Nota: ho cambiato lo stile in 'navigation-day-v1' che è più bello per guidare
                additionalOptions: {
                  'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? '',
                },
              ),

              // Disegna il percorso REALE
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 6.0, // Linea più spessa per navigazione
                    color: Colors.blueAccent,
                    borderStrokeWidth: 2.0, // Bordo per visibilità
                    borderColor: Colors.blue.shade900,
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
                color: const Color(0xFF0D0D1A), // Colore scuro HeavyRoute
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
                        const Text("Destinazione", style: TextStyle(color: Colors.grey, fontSize: 12)),
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

          // 3. PANNELLO INFERIORE (Dati e Uscita)
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
                          distanceDisplay,
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)
                      ),
                      const Text("Restanti all'arrivo", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text("ESCI"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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