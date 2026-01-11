import 'package:flutter/material.dart';
import '../../../requests/models/transport_request.dart'; // Assicurati di importare il tuo modello
import '../service/planner_service.dart';

class RoutePlanningDialog extends StatefulWidget {
  final TransportRequest request;
  final VoidCallback onSuccess;

  const RoutePlanningDialog({
    super.key,
    required this.request,
    required this.onSuccess,
  });

  @override
  State<RoutePlanningDialog> createState() => _RoutePlanningDialogState();
}

class _RoutePlanningDialogState extends State<RoutePlanningDialog> {
  final  PlannerService _service = PlannerService();
  bool _isSubmitting = false;
  int _selectedRouteIndex = 0; // Simuliamo la scelta tra più percorsi (0, 1, 2)

  Future<void> _submitToCoordinator() async {
    setState(() => _isSubmitting = true);

    // Chiama il servizio per creare il viaggio e metterlo in stato WAITING_VALIDATION
    final success = await _service.planTripAndSendToCoordinator(
      widget.request.id,
      "Itinerario ${_selectedRouteIndex + 1} (Selezionato su Mappa)", // Simuliamo dati del percorso
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context); // Chiudi il dialog
        widget.onSuccess(); // Aggiorna la lista chiamante
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore nell'invio al Coordinator")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800, // Popup largo per la mappa
        height: 700,
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header
            Padding(
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Body con Mappa e Sidebar
            Expanded(
              child: Row(
                children: [
                  // Sidebar opzioni percorso
                  Container(
                    width: 250,
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Percorsi Calcolati",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 16),
                        _buildRouteOption(0, "Principale (A1)", "240 km", "3h 10m", isRecommended: true),
                        const SizedBox(height: 12),
                        _buildRouteOption(1, "Alternativa (SS45)", "265 km", "4h 20m"),
                        const Spacer(),
                        const Text(
                          "Seleziona il percorso ottimale per procedere all'invio al Traffic Coordinator.",
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Area Mappa
                  Expanded(
                    child: Stack(
                      children: [
                        // Placeholder Mappa
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFE3F2FD),
                            child: CustomPaint(
                              painter: MapRoutePainter(), // Un painter semplice per disegnare una linea
                            ),
                          ),
                        ),
                        // Overlay info
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)]),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 12, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(widget.request.origin, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(widget.request.destination, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            // Footer Azioni
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitToCoordinator,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                    label: Text(_isSubmitting ? "Invio in corso..." : "INVIA AL COORDINATOR"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOption(int index, String name, String dist, String time, {bool isRecommended = false}) {
    bool isSelected = _selectedRouteIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRouteIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.indigo : Colors.transparent),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.indigo : Colors.black)),
                if (isRecommended) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
                    child: Text("BEST", style: TextStyle(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.directions_car, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("$dist • $time", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Painter semplice per disegnare una linea curva sulla "mappa"
class MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8); // Start
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.5, // Control point
        size.width * 0.8, size.height * 0.2 // End
    );

    canvas.drawPath(path, paint);

    // Draw Start Point
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 6, Paint()..color = Colors.black);
    // Draw End Point
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 6, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}