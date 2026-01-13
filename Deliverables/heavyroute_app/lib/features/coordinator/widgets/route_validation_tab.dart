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

  // 0 = Da Validare (WAITING_VALIDATION), 1 = Storico (CONFIRMED)
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Se filtro è 0 -> WAITING_VALIDATION
      // Se filtro è 1 -> CONFIRMED (Viaggi già approvati e pronti)
      String statusToFetch = _filterIndex == 0 ? "WAITING_VALIDATION" : "CONFIRMED";

      final data = await _service.getTripsByStatus(statusToFetch);

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
          content: Text(approved ? "Percorso validato con successo!" : "Richiesta respinta."),
          backgroundColor: approved ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadData(); // Ricarica la lista per riflettere il cambio di stato
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'operazione"), backgroundColor: Colors.red),
      );
    }
  }

  void _openDialog(TripModel trip) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RouteValidationDialog(
        trip: trip,
        onValidation: _filterIndex == 0 ? _processValidation : (id, app) async {},
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
              const Text("Gestione Percorsi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              Row(
                children: [
                  // TOGGLE BUTTONS
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: [_filterIndex == 0, _filterIndex == 1],
                    onPressed: (index) {
                      setState(() => _filterIndex = index);
                      _loadData();
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
          Text(
              _filterIndex == 0 ? "Nessun percorso in attesa." : "Nessun viaggio nello storico.",
              style: TextStyle(color: Colors.grey[500], fontSize: 16)
          ),
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
              if (_filterIndex == 0)
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
              // Per lo storico mostriamo un bottone di sola visualizzazione o stato
                TextButton.icon(
                  onPressed: null, // Disabilitato
                  icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  label: const Text("APPROVATO", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                )
            ],
          )),
        ],
      ),
    );
  }
}