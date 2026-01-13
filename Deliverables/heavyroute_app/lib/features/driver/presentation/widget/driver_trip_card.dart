import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Mappa OpenSource
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Decodifica stringa
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../common/models/enums.dart';
import '../../../trips/models/trip_model.dart';
import '../../service/drive_trip_service.dart';
import 'driver_trip_detail_screen.dart';
import 'driver_status_sheet.dart';
import 'driver_report_sheet.dart'; // <--- USIAMO IL TUO FILE ESISTENTE

class DriverTripCard extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onTripUpdated; // Callback per dire alla Dashboard di ricaricare

  const DriverTripCard({
    super.key,
    required this.trip,
    required this.onTripUpdated,
  });

  @override
  State<DriverTripCard> createState() => _DriverTripCardState();
}

class _DriverTripCardState extends State<DriverTripCard> {
  final DriverTripService _driverService = DriverTripService();

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.trip.status == TripStatus.IN_TRANSIT;

    // Coordinate di default (fallback)
    LatLng start = const LatLng(41.9028, 12.4964);
    LatLng end = const LatLng(45.4642, 9.1900);

    // Gestione coordinate Start/End dai dati
    if (widget.trip.route != null) {
      start = LatLng(
        widget.trip.route!.startLat ?? 41.9028,
        widget.trip.route!.startLon ?? 12.4964,
      );
      end = LatLng(
        widget.trip.route!.endLat ?? 45.4642,
        widget.trip.route!.endLon ?? 9.1900,
      );
    }

    // --- LOGICA PERCORSO (Polyline Decoding) ---
    List<LatLng> routePoints = [];

    // 1. Proviamo a decodificare la Polyline vera
    if (widget.trip.route?.polyline != null && widget.trip.route!.polyline!.isNotEmpty) {
      try {
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> result = polylinePoints.decodePolyline(widget.trip.route!.polyline!);

        // Conversione da PointLatLng a LatLng (per flutter_map)
        routePoints = result
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } catch (e) {
        debugPrint("Errore decodifica polyline: $e");
      }
    }

    // 2. Fallback: Linea retta se manca il percorso
    if (routePoints.isEmpty) {
      routePoints = [start, end];
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isActive ? Colors.green.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.trip.status.name.replaceAll('_', ' '),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green.shade800 : Colors.blue.shade800)),
                ),
                Text(widget.trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),

          // Nome Cliente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.trip.request.customerName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 16),

          // Indirizzi
          _buildAddressRow(Icons.circle, Colors.black, "Ritiro", widget.trip.request.originAddress),
          Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Container(height: 20, width: 2, color: Colors.grey.shade300)),
          _buildAddressRow(Icons.location_on, Colors.red, "Consegna", widget.trip.request.destinationAddress),

          const SizedBox(height: 16),

          // --- MAPPA FLUTTER_MAP ---
          SizedBox(
            height: 180,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: start,
                initialZoom: 8,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                  additionalOptions: {'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? ''},
                ),
                PolylineLayer(polylines: [
                  Polyline(
                    points: routePoints, // USIAMO I PUNTI DECODIFICATI
                    color: Colors.blueAccent,
                    strokeWidth: 4.0,
                  )
                ]),
                MarkerLayer(markers: [
                  Marker(point: start, child: const Icon(Icons.circle, size: 14, color: Colors.black)),
                  Marker(point: end, child: const Icon(Icons.location_on, color: Colors.red, size: 32)),
                ]),
              ],
            ),
          ),

          // --- PULSANTIERA ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DriverTripDetailScreen(trip: widget.trip.toJson())));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("DETTAGLI"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showStatusSheet(),
                    child: const Text("AGGIORNA"),
                  ),
                ),
                const SizedBox(width: 8),

                // --- BOTTONE SEGNALA ---
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        // Apre il TUO widget esistente
                        builder: (context) => const DriverReportSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, size: 24),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, Color color, String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(text,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => DriverStatusSheet(
        currentStatus: widget.trip.status.name,
        onStatusChanged: (val) async {
          bool ok = await _driverService.updateTripStatus(
            widget.trip.id,
            widget.trip.status.name,
            val,
          );
          if (ok) {
            widget.onTripUpdated();
          }
        },
      ),
    );
  }
}