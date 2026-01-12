import 'package:flutter/material.dart';
import '../../../requests/models/transport_request.dart';
import '../../../trips/models/route_model.dart';

class RoutePlanningSidebar extends StatelessWidget {
  final TransportRequest request;
  final RouteModel? route;
  final bool isLoading;
  final VoidCallback onCalculate;

  const RoutePlanningSidebar({
    super.key,
    required this.request,
    required this.route,
    required this.isLoading,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRequestInfoCard(),
          const SizedBox(height: 24),
          const Text("OPZIONI PERCORSO",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          // LOGICA VISUALIZZAZIONE
          if (route == null) ...[
            // STATO 1: Nessuna rotta calcolata
            _buildRouteOptionPlaceholder(),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onCalculate,
              icon: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.calculate_outlined),
              label: Text(isLoading ? "Elaborazione..." : "CALCOLA ITINERARIO"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Il sistema calcolerà il percorso ottimale per mezzi pesanti usando Mapbox Navigation AI.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ] else ...[
            // STATO 2: Rotta calcolata e visibile
            _buildResultCard(route!),
            const Spacer(),
            const Card(
              color: Color(0xFFE8F5E9),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(child: Text("Rotta generata. Verifica sulla mappa.", style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // --- WIDGETS INTERNI ALLA SIDEBAR ---

  Widget _buildRequestInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildLocRow(Icons.circle_outlined, request.originAddress, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 2, height: 16, color: Colors.grey.shade300)
            ),
          ),
          _buildLocRow(Icons.location_on, request.destinationAddress, Colors.red),
        ],
      ),
    );
  }

  Widget _buildLocRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOptionPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(child: Text("Nessuna rotta calcolata", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildResultCard(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Percorso Ottimale", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                child: const Text("FASTEST", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 24),
          _buildStatRow(Icons.timer_outlined, "Durata Stimata", route.formattedDuration),
          const SizedBox(height: 12),
          _buildStatRow(Icons.straighten, "Distanza Totale", "${route.distanceKm.toStringAsFixed(1)} km"),
          const SizedBox(height: 12),
          _buildStatRow(Icons.euro, "Pedaggio Stimato", "€${route.tollCost.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}