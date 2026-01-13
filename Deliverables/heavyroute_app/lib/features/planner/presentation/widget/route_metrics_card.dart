import 'package:flutter/material.dart';
import '../../../trips/models/route_model.dart';

class RouteMetricsCard extends StatelessWidget {
  final RouteModel? route;

  const RouteMetricsCard({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    if (route == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.map_outlined, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
                child: Text("Mappa non ancora generata",
                    style: TextStyle(color: Colors.grey))),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Percorso Ottimale",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green, borderRadius: BorderRadius.circular(4)),
                child: const Text("FASTEST",
                    style: TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 24),
          _buildStatRow(Icons.timer_outlined, "Durata", route!.formattedDuration),
          const SizedBox(height: 12),
          _buildStatRow(Icons.straighten, "Distanza", "${route!.distanceKm.toStringAsFixed(1)} km"),
          const SizedBox(height: 12),
          _buildStatRow(Icons.euro, "Costo", "€${route!.tollCost.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}