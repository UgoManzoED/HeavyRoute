import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_map.dart';
import '../../../requests/models/transport_request.dart';
import '../../../trips/models/trip_model.dart';
import '../service/planner_service.dart';

class RoutePlanningDialog extends StatefulWidget {
  final TransportRequest request;

  final Function(TripModel?) onSuccess;

  const RoutePlanningDialog({
    super.key,
    required this.request,
    required this.onSuccess,
  });

  @override
  State<RoutePlanningDialog> createState() => _RoutePlanningDialogState();
}

class _RoutePlanningDialogState extends State<RoutePlanningDialog> {
  final PlannerService _service = PlannerService();
  bool _isSubmitting = false;
  int _selectedRouteIndex = 0;

  // Funzione aggiornata per gestire il ritorno del modello dal backend
  Future<void> _submitToCoordinator() async {
    setState(() => _isSubmitting = true);

    try {
      // Il servizio deve chiamare l'endpoint /approve che restituisce il TripModel
      final TripModel? createdTrip = await _service.approveRequestAndGetTrip(
        widget.request.id,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (createdTrip != null) {
          Navigator.pop(context); // Chiudi il dialog

          // NOTIFICA IL PADRE: Passiamo il trip creato con la sua rotta reale
          widget.onSuccess(createdTrip);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000, // Leggermente più largo per far spazio alla mappa reale
        height: 800,
        child: Column(
          children: [
            // Header (Rimane simile, corretto i nomi dei campi della richiesta)
            _buildHeader(),
            const Divider(height: 1),

            Expanded(
              child: Row(
                children: [
                  _buildSidebar(),
                  const VerticalDivider(width: 1),
                  // AREA MAPPA REALE
                  Expanded(
                    child: Stack(
                      children: [
                        // Qui usiamo il widget mappa che abbiamo creato prima!
                        // Nota: Se non hai ancora la rotta calcolata, mostriamo una mappa base
                        const HeavyRouteMap(),
                        _buildMapOverlay(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS INTERNI (Estratti per pulizia) ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pianificazione Percorso",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Richiesta #${widget.request.id} • ${widget.request.clientFullName}",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("OPZIONI PERCORSO",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          _buildRouteOption(0, "Percorso Standard", "Calcolo dinamico...", "A1/E35", isRecommended: true),
          const Spacer(),
          const Card(
            color: Color(0xFFFFF9C4),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Inviando la proposta, il Traffic Coordinator riceverà una notifica per la validazione tecnica.",
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(widget.request.originAddress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
            ),
            const Icon(Icons.flag, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(widget.request.destinationAddress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitToCoordinator,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            icon: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded),
            label: Text(_isSubmitting ? "Invio..." : "INVIA AL COORDINATOR"),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOption(int index, String name, String dist, String desc, {bool isRecommended = false}) {
    bool isSelected = _selectedRouteIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRouteIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.indigo : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.indigo : Colors.black)),
            Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}