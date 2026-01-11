import 'package:flutter/material.dart';
import '../services/coordinator_service.dart';
import '../../trips/models/trip_model.dart'; // <--- Il tuo TripModel
import '../../../../common/models/enums.dart'; // TripStatus

class RouteValidationTab extends StatefulWidget {
  const RouteValidationTab({super.key});

  @override
  State<RouteValidationTab> createState() => _RouteValidationTabState();
}

class _RouteValidationTabState extends State<RouteValidationTab> {
  final TrafficCoordinatorService _service = TrafficCoordinatorService();

  // Usiamo la lista del modello reale
  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getProposedRoutes();
    if (mounted) {
      setState(() {
        _trips = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleValidation(int tripId, bool approved) async {
    final success = await _service.validateRoute(tripId, approved);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? "Percorso validato!" : "Richiesta modifica inviata"),
          backgroundColor: approved ? Colors.green : Colors.orange,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore operazione"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Validazione Percorsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Esamina e approva i percorsi pianificati per i trasporti eccezionali",
              style: TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 24),
          _buildTableHeader(),
          const Divider(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                ? const Center(child: Text("Nessun percorso da validare."))
                : ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) => _buildRouteRow(_trips[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("Codice", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Origine - Destinazione", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Dati Tecnici", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 1, child: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildRouteRow(TripModel trip) {
    // Controllo stato usando l'Enum (Type Safe)
    final bool isPending = trip.status == TripStatus.WAITING_VALIDATION;

    // Estrazione dati sicura (RouteModel è nullable)
    final String distance = trip.route != null
        ? "${trip.route!.routeDistance.toStringAsFixed(1)} km"
        : "N/D";

    final String duration = trip.route != null
        ? "${trip.route!.routeDuration.toStringAsFixed(0)} min"
        : "N/D";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isPending ? Border.all(color: Colors.orange.shade100) : null,
      ),
      child: Row(
        children: [
          // 1. Codice Viaggio
          Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text("ID #${trip.id}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),

          // 2. Origine / Destinazione (Dal TransportRequest annidato)
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLocationRow(Icons.my_location, trip.request.originAddress),
            const SizedBox(height: 4),
            _buildLocationRow(Icons.location_on, trip.request.destinationAddress),
          ])),

          // 3. Dati Tecnici (Dal RouteModel annidato)
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(distance, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),

          // 4. Stato
          Expanded(flex: 1, child: _buildStatusChip(trip.status)),

          // 5. Azioni
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Colors.blue),
                tooltip: "Vedi Mappa",
                onPressed: () { /* TODO: Apri mappa */ },
              ),
              if (isPending) ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  "Valida", Colors.black, Colors.white, Icons.check,
                      () => _handleValidation(trip.id, true),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Rifiuta",
                  onPressed: () => _handleValidation(trip.id, false),
                ),
              ]
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 12, color: Colors.grey),
      const SizedBox(width: 4),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))
    ]);
  }

  Widget _buildStatusChip(TripStatus status) {
    // Logica colori basata su Enum
    Color bg = Colors.grey.shade200;
    Color text = Colors.black;

    if (status == TripStatus.WAITING_VALIDATION) {
      bg = Colors.orange.shade100;
      text = Colors.orange.shade900;
    } else if (status == TripStatus.VALIDATED) {
      bg = Colors.green.shade100;
      text = Colors.green.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.name.replaceAll('_', ' '), // Visualizza "WAITING VALIDATION"
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
        textAlign: TextAlign.center,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}