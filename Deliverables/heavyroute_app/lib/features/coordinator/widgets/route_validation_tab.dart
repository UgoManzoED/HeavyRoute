import 'package:flutter/material.dart';
import '../services/coordinator_service.dart';
import '../../trips/models/trip_model.dart';
import '../../../../common/models/enums.dart';

class RouteValidationTab extends StatefulWidget {
  const RouteValidationTab({super.key});

  @override
  State<RouteValidationTab> createState() => _RouteValidationTabState();
}

class _RouteValidationTabState extends State<RouteValidationTab> {
  final TrafficCoordinatorService _service = TrafficCoordinatorService();

  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getProposedRoutes();
      if (mounted) {
        setState(() {
          _trips = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleValidation(int tripId, bool approved) async {
    final success = await _service.validateRoute(tripId, approved);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? "Percorso validato con successo!" : "Richiesta respinta."),
          backgroundColor: approved ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'operazione"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Arrotondamento più moderno
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Validazione Percorsi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Esamina e approva i percorsi pianificati per i trasporti eccezionali.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),

          const SizedBox(height: 32),
          _buildTableHeader(),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _trips.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildRouteRow(_trips[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Nessun percorso in attesa di validazione",
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 1, child: Text("VIAGGIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 3, child: Text("ITINERARIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("DATI TECNICI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("STATO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("AZIONI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildRouteRow(TripModel trip) {
    final bool isPending = trip.status == TripStatus.WAITING_VALIDATION;

    final String distance = trip.route != null
        ? "${trip.route!.distanceKm.toStringAsFixed(1)} km"
        : "-";

    final String duration = trip.route != null
        ? trip.route!.formattedDuration
        : "-";

    final String description = trip.route?.description ?? "Standard";

    return Container(
      color: isPending ? const Color(0xFFFFFBEB) : Colors.transparent, // Highlight giallo se pending
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Codice
          Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ])),

          // 2. Itinerario
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Usiamo i getter sicuri .origin e .destination
            _buildLocationRow(Icons.circle, trip.request.origin, isStart: true),
            const SizedBox(height: 4),
            _buildLocationRow(Icons.location_on, trip.request.destination, isStart: false),
          ])),

          // 3. Dati Tecnici
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text("$distance • $duration", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),

          // 4. Stato
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: _buildStatusChip(trip.status),
          )),

          // 5. Azioni
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPending) ...[
                _buildActionButton(
                  "Valida", const Color(0xFF0D0D1A), Colors.white, Icons.check,
                      () => _handleValidation(trip.id, true),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Rifiuta",
                  onPressed: () => _handleValidation(trip.id, false),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: Colors.blueGrey),
                  tooltip: "Vedi Mappa",
                  onPressed: () { },
                ),
              ]
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text, {bool isStart = false}) {
    return Row(children: [
      Icon(icon, size: 10, color: isStart ? Colors.black : Colors.red),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1))
    ]);
  }

  Widget _buildStatusChip(TripStatus status) {
    Color bg = Colors.grey.shade100;
    Color text = Colors.grey.shade700;
    String label = status.name;

    if (status == TripStatus.WAITING_VALIDATION) {
      bg = Colors.orange.shade50;
      text = Colors.orange.shade800;
      label = "DA VALIDARE";
    } else if (status == TripStatus.VALIDATED) {
      bg = Colors.green.shade50;
      text = Colors.green.shade800;
      label = "VALIDATO";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg == Colors.grey.shade100 ? Colors.transparent : text.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Widget _buildActionButton(String label, Color bg, Color fg, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: fg),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, 32),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}