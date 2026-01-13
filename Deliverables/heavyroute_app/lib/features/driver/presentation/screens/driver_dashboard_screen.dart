import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../common/widgets/heavy_route_app_bar.dart';
import '../../../../common/models/enums.dart';
import '../../../trips/models/trip_model.dart';
import '../../service/drive_trip_service.dart';
import '../widget/driver_trip_detail_screen.dart';
import '../widget/driver_status_sheet.dart';
// Se hai messo DriverReportSheet in un altro file, decommente l'import qui sotto:
// import '../widget/driver_report_sheet.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final trips = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadTrips(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Prossime Destinazioni", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
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
    bool isActive = trip.status == TripStatus.IN_TRANSIT;

    LatLng start = const LatLng(41.9028, 12.4964);
    LatLng end = const LatLng(45.4642, 9.1900);

    if (trip.route != null) {
      start = LatLng(
          trip.route!.startLat ?? 41.9028,
          trip.route!.startLon ?? 12.4964
      );
      end = LatLng(
          trip.route!.endLat ?? 45.4642,
          trip.route!.endLon ?? 9.1900
      );
    }

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
                      trip.status.name.replaceAll('_', ' '),
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

          // Cliente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(trip.request.customerName ?? "Cliente Privato", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 16),

          // Indirizzi
          _buildAddressRow(Icons.circle, Colors.black, "Ritiro", trip.request.originAddress),
          Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Container(height: 20, width: 2, color: Colors.grey.shade300)
          ),
          _buildAddressRow(Icons.location_on, Colors.red, "Consegna", trip.request.destinationAddress),

          const SizedBox(height: 16),

          // Mappa
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: start,
                initialZoom: 5,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
                  additionalOptions: { 'accessToken': dotenv.maybeGet('MAPBOX_ACCESS_TOKEN') ?? '' },
                ),
                PolylineLayer(
                    polylines: [
                      Polyline(points: [start, end], color: Colors.blue, strokeWidth: 3)
                    ]
                ),
                MarkerLayer(markers: [
                  Marker(point: start, child: const Icon(Icons.circle, size: 15)),
                  Marker(point: end, child: const Icon(Icons.location_on, color: Colors.red, size: 30)),
                ]),
              ],
            ),
          ),

          // --- PULSANTIERA AGGIORNATA ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Tasto DETTAGLI
                Expanded(
                    flex: 2,
                    child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DriverTripDetailScreen(trip: trip.toJson()))
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("DETTAGLI")
                    )
                ),
                const SizedBox(width: 8),

                // Tasto AGGIORNA
                Expanded(
                    flex: 2,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D0D1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showStatusSheet(trip),
                        child: const Text("AGGIORNA")
                    )
                ),

                const SizedBox(width: 8),

                // Tasto REPORT (NUOVO)
                Expanded(
                  flex: 1, // Più piccolo
                  child: ElevatedButton(
                    onPressed: () {
                      // Apre il foglio di segnalazione
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Importante per la tastiera
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

              bool ok = await _driverService.updateTripStatus(
                  trip.id,
                  trip.status.name, // Passiamo lo stato attuale per il controllo
                  val
              );
                if(ok) _loadTrips();
              }
        )
    );
  }
}

// ---------------------------------------------------------
// CLASSE DRIVER REPORT SHEET (Mockup UI per Segnalazioni)
// ---------------------------------------------------------

class DriverReportSheet extends StatefulWidget {
  const DriverReportSheet({super.key});

  @override
  State<DriverReportSheet> createState() => _DriverReportSheetState();
}

class _DriverReportSheetState extends State<DriverReportSheet> {
  String? _selectedIssue;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _issues = [
    "Traffico Intenso / Coda",
    "Incidente Stradale",
    "Guasto al Mezzo",
    "Problemi con il Carico",
    "Ritardo Cliente",
    "Meteo Avverso",
    "Altro"
  ];

  @override
  Widget build(BuildContext context) {
    // Padding dinamico per evitare che la tastiera copra i campi
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                ),
                const SizedBox(width: 16),
                const Text("Segnala Problema", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),

            // Dropdown
            const Text("Tipologia *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIssue,
                  hint: const Text("Seleziona il tipo di problema"),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _issues.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _selectedIssue = val),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note
            const Text("Descrizione / Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Scrivi qui maggiori dettagli...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 24),

            // Bottone Invia
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // MOCK: Chiude e mostra conferma
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Segnalazione inviata al coordinatore"),
                        backgroundColor: Colors.red
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text("INVIA SEGNALAZIONE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}