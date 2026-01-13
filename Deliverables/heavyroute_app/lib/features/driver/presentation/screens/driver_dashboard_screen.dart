import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../common/widgets/heavy_route_app_bar.dart';
import '../../../../common/models/enums.dart';
import '../../../trips/models/trip_model.dart';
import '../../service/drive_trip_service.dart';
import '../widget/driver_trip_detail_screen.dart'; // Assicurati di avere questo widget
import '../widget/driver_status_sheet.dart';      // Assicurati di avere questo widget
import '../widget/driver_report_sheet.dart';      // Assicurati di avere questo widget

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final DriverTripService _driverService = DriverTripService();
  late Future<List<TripModel>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = _driverService.getMyTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: HeavyRouteAppBar(
        subtitle: "Le tue Consegne",
        isLanding: false,
        onProfileTap: () {},
      ),
      body: FutureBuilder<List<TripModel>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          // 1. Caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Errore
          else if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          }
          // 3. Nessun Viaggio Trovato
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // 4. Lista Viaggi Reale
          final trips = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadTrips(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Prossime Destinazioni", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Mappa la lista dei dati reali nelle Card
                ...trips.map((trip) => _buildTripCard(trip)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("Nessuna consegna assegnata", style: TextStyle(fontSize: 18, color: Colors.grey)),
          TextButton(onPressed: _loadTrips, child: const Text("Aggiorna"))
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    // Logica colori stato
    bool isActive = trip.status == TripStatus.IN_TRANSIT;

    // Coordinate Mock per la mappa (usare quelle reali se presenti nel DTO)
    // Se trip.route è null, mettiamo coordinate di default per evitare crash
    final start = LatLng(41.9028, 12.4964); // Roma (Fallback)
    final end = LatLng(45.4642, 9.1900);   // Milano (Fallback)

    // TODO: Se il DTO ha le coordinate reali, usale qui:
    // final start = LatLng(trip.route!.startLat, trip.route!.startLon);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isActive ? Colors.green.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                      trip.status.name.replaceAll('_', ' '), // Fix per visualizzazione Enum
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green.shade800 : Colors.blue.shade800
                      )
                  ),
                ),
                Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),

          // Dettagli Cliente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(trip.request.customerName ?? "Cliente Privato", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 16),

          // Timeline Indirizzi
          _buildAddressRow(Icons.circle, Colors.black, "Ritiro", trip.request.originAddress),
          Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Container(height: 20, width: 2, color: Colors.grey.shade300)
          ),
          _buildAddressRow(Icons.location_on, Colors.red, "Consegna", trip.request.destinationAddress),

          const SizedBox(height: 16),

          // Mappa (Miniatura)
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: start,
                initialZoom: 5,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Mappa statica
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                  additionalOptions: { 'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? '' },
                ),
                PolylineLayer(polylines: [Polyline(points: [start, end], color: Colors.blue, strokeWidth: 3)]),
                MarkerLayer(markers: [
                  Marker(point: start, child: const Icon(Icons.circle, size: 15)),
                  Marker(point: end, child: const Icon(Icons.location_on, color: Colors.red, size: 30)),
                ]),
              ],
            ),
          ),

          // Pulsantiera
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverTripDetailScreen(trip: trip.toJson()))),
                        child: const Text("DETTAGLI")
                    )
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white),
                        // Apre il foglio per cambiare stato
                        onPressed: () => _showStatusSheet(trip),
                        child: const Text("AGGIORNA")
                    )
                )
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
                Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showStatusSheet(TripModel trip) {
    showModalBottomSheet(
        context: context,
        builder: (_) => DriverStatusSheet(
            currentStatus: trip.status.name,
            onStatusChanged: (val) async {
              // Chiama il service per aggiornare
              bool ok = await _driverService.updateTripStatus(trip.id, val);
              if(ok) _loadTrips(); // Ricarica la lista se successo
            }
        )
    );
  }
}