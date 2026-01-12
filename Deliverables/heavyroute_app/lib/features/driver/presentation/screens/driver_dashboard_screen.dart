import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../common/widgets/heavy_route_app_bar.dart';
import '../widget/driver_trip_detail_screen.dart';
import '../widget/driver_status_sheet.dart';
import '../widget/driver_report_sheet.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  // Mock dati
  final List<Map<String, dynamic>> _mockTrips = [
    {
      "code": "TRIP-A-001",
      "company": "Acciaierie Lombardia SPA",
      "origin": "Milano - Via Tortona 15",
      "destination": "Roma - Via Appia Nuova 234",
      "status": "In Corso",
      "progress": 0.4,
      "date": "2025-10-23 06:00",
      "distance": "575 km",
      "coords": [const LatLng(45.4642, 9.1900), const LatLng(41.9028, 12.4964)],
    },
    {
      "code": "TRIP-A-002",
      "company": "Costruzioni Europa SRL",
      "origin": "Torino - Corso Francia 88",
      "destination": "Genova - Porto Commerciale",
      "status": "Assegnato",
      "progress": 0.0,
      "date": "2025-10-24 08:00",
      "distance": "180 km",
      "coords": [const LatLng(45.0703, 7.6869), const LatLng(44.4056, 8.9463)],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: HeavyRouteAppBar(
        subtitle: "Portale Autista",
        isLanding: false,
        onProfileTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo Autista: Marco Rossi")));
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("I tuoi viaggi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._mockTrips.map((trip) => _buildTripCard(trip)).toList(),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final bool isInProgress = trip['status'] == "In Corso";
    final Color statusColor = isInProgress ? Colors.green.shade50 : Colors.grey.shade100;
    final Color statusText = isInProgress ? Colors.green.shade800 : Colors.grey.shade800;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(trip['status'].toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusText)),
                ),
                Text(trip['code'], style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(trip['company'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 16),

          // Indirizzi
          _buildAddressRow(Icons.circle, Colors.black, "Ritiro", trip['origin']),
          Padding(
            padding: const EdgeInsets.only(left: 23),
            child: Container(height: 20, width: 2, color: Colors.grey.shade300),
          ),
          _buildAddressRow(Icons.location_on, Colors.red, "Consegna", trip['destination']),

          const SizedBox(height: 16),

          // --- MAPPA MINIATURA ---
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: trip['coords'][0],
                  initialZoom: 6.0,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    // Uso la v11 che è più permissiva per evitare il 403
                    urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                    additionalOptions: {
                      'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? '',
                    },
                    userAgentPackageName: 'com.heavyroute.app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(points: trip['coords'], color: Colors.blue, strokeWidth: 4),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(point: trip['coords'][0], width: 20, height: 20, child: const Icon(Icons.circle, size: 15, color: Colors.black)),
                      Marker(point: trip['coords'][1], width: 40, height: 40, child: const Icon(Icons.location_on, size: 30, color: Colors.red)),
                    ],
                  ),
                  // --- FIX ERRORE 404 (LOGO) ---
                  RichAttributionWidget(
                    showFlutterMapAttribution: false, // QUESTO RISOLVE IL CRASH DELL'ASSET
                    attributions: [
                      TextSourceAttribution('Mapbox', onTap: () {}),
                      TextSourceAttribution('OpenStreetMap', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Pulsantiera
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverTripDetailScreen(trip: trip))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("DETTAGLI", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showUpdateStatusSheet(context, trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("AGGIORNA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
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
                    child: const Icon(Icons.warning_amber_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, Color color, String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showUpdateStatusSheet(BuildContext context, Map<String, dynamic> trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverStatusSheet(
        currentStatus: trip['status'],
        onStatusChanged: (newStatus) {
          setState(() {
            trip['status'] = newStatus;
          });
        },
      ),
    );
  }
}