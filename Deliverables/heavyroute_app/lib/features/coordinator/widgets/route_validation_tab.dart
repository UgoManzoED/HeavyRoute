import 'package:flutter/material.dart';
import '../services/coordinator_service.dart';
import '../../trips/models/trip_model.dart';
import '../../../../common/models/enums.dart';
import 'route_validation_dialog.dart';

class RouteValidationTab extends StatefulWidget {
  const RouteValidationTab({super.key});

  @override
  State<RouteValidationTab> createState() => _RouteValidationTabState();
}

class _RouteValidationTabState extends State<RouteValidationTab> {
  final TrafficCoordinatorService _service = TrafficCoordinatorService();

  List<TripModel> _trips = [];
  bool _isLoading = true;

  // 0 = Da Validare, 1 = Storico
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _trips = [];
    });

    try {
      List<String> statusesToFetch = [];

      if (_filterIndex == 0) {
        statusesToFetch = ["WAITING_VALIDATION"];
      } else if (_filterIndex == 1) {
        statusesToFetch = ["CONFIRMED", "ACCEPTED", "IN_TRANSIT", "PAUSED", "DELIVERING"];
      } else {
        statusesToFetch = ["COMPLETED", "CANCELLED", "MODIFICATION_REQUESTED"];
      }

      final data = await _service.getTripsByStatuses(statusesToFetch);

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

  Future<void> _processValidation(int tripId, bool approved) async {
    final success = await _service.validateRoute(tripId, approved);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? "Percorso validato! Spostato nello Storico." : "Richiesta respinta."),
          backgroundColor: approved ? Colors.green : Colors.orange,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'operazione"), backgroundColor: Colors.red),
      );
    }
  }

  void _openDialog(TripModel trip) {
    // Determina se siamo in modalità sola lettura
    bool isHistory = _filterIndex == 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RouteValidationDialog(
        trip: trip,
        isReadOnly: isHistory,
        onValidation: isHistory ? (id, app) async {} : _processValidation, // Callback vuota se storico
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CON TOGGLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_filterIndex == 0 ? "Validazione Percorsi" : "Storico Viaggi",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              Row(
                children: [
                  // TOGGLE BUTTONS
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: [_filterIndex == 0, _filterIndex == 1],
                    onPressed: (index) {
                      if (_filterIndex != index) {
                        setState(() => _filterIndex = index);
                        _loadData();
                      }
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Da Validare")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Storico Approvati")),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              _filterIndex == 0
                  ? "Esamina la mappa e approva i percorsi per renderli definitivi."
                  : "Elenco dei viaggi già validati e operativi.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)
          ),

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
          Text("Nessun elemento da mostrare.",
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("VIAGGIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 3, child: Text("ITINERARIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("RISORSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("AZIONI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildRouteRow(TripModel trip) {
    bool isHistory = _filterIndex == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Codice
          Expanded(flex: 2, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(trip.request.clientFullName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          )),

          // 2. Itinerario
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(trip.request.originAddress, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Icon(Icons.arrow_downward, size: 12, color: Colors.grey),
            Text(trip.request.destinationAddress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),

          // 3. Risorse
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(trip.formattedDriverName, style: const TextStyle(fontSize: 12)),
            Text(trip.formattedVehicle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),

          // 4. Azioni
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isHistory)
              // BOTTONE DA VALIDARE
                ElevatedButton.icon(
                  onPressed: () => _openDialog(trip),
                  icon: const Icon(Icons.map, size: 14),
                  label: const Text("ESAMINA"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0D1A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
              else
              // BOTTONE STORICO
                OutlinedButton.icon(
                  onPressed: () => _openDialog(trip), // Apre il dialog in modalità ReadOnly
                  icon: const Icon(Icons.visibility, size: 14, color: Colors.blueGrey),
                  label: const Text("DETTAGLI", style: TextStyle(color: Colors.blueGrey)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
            ],
          )),
        ],
      ),
    );
  }
}