import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_app_bar.dart';

class DriverTripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const DriverTripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      // RIUTILIZZO APP BAR COMUNE
      appBar: const HeavyRouteAppBar(
        subtitle: "Dettaglio Viaggio",
        isLanding: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tasto Indietro
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              label: const Text("Torna alla lista", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),

            // Info Principali
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip['code'], style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(trip['company'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow("Merce", "Bobine d'Acciaio (25t)"),
                  _buildDetailRow("Note", "Attenzione al carico sporgente."),
                  _buildDetailRow("Contatto", "+39 333 9998877 (Sig. Brambilla)"),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Documentazione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Widget Documenti Simile al mockup
            _buildDocTile("DDT_2025_001.pdf", "Documento di Trasporto"),
            const SizedBox(height: 8),
            _buildDocTile("PERMESSO_TRANSITO.pdf", "Autorizzazione Eccezionale"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDocTile(String filename, String description) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.redAccent),
        title: Text(filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {},
        ),
      ),
    );
  }
}