import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_app_bar.dart';
import 'driver_navigation_screen.dart'; // Importa la schermata di navigazione

class DriverTripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip; // Questo è il JSON completo del TripModel

  const DriverTripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // Estrazione sicura dei dati annidati
    final request = trip['request'] ?? {};
    final load = request['load'] ?? {};
    final customerName = request['customerName'] ?? "Cliente Standard";
    final loadType = request['loadType'] ?? "Merce Generale";
    final weight = load['weightKg']?.toString() ?? "N/D";

    // Contatto Mock (se non presente nel backend, mettiamo un placeholder)
    final contact = "Ufficio Logistica: +39 02 1234567";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: const HeavyRouteAppBar(
        subtitle: "Dettaglio Viaggio",
        isLanding: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con Navigazione
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: const Text("Torna alla lista", style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Naviga alla schermata mappa passando le coordinate reali
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DriverNavigationScreen(trip: trip)));
                  },
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text("NAVIGA"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Info Principali
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(trip['tripCode'] ?? "-", style: const TextStyle(color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(trip['status'] ?? "", style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildDetailRow("Indirizzo Ritiro", request['originAddress'] ?? "-"),
                  _buildDetailRow("Indirizzo Consegna", request['destinationAddress'] ?? "-"),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  _buildDetailRow("Merce", "$loadType ($weight kg)"),
                  _buildDetailRow("Dimensioni", "${load['length']}x${load['width']}x${load['height']} m"),
                  _buildDetailRow("Contatto", contact),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Documentazione Digitale", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Documenti (Mock per ora, ma pronti per l'integrazione)
            _buildDocTile("DDT_${trip['id']}.pdf", "Documento di Trasporto (Generato)"),
            const SizedBox(height: 8),
            _buildDocTile("AUTORIZZAZIONE_TRANSITO.pdf", "Permesso Eccezionale"),
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
        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        title: Text(filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: () {
            // TODO: Implementare download reale
          },
        ),
      ),
    );
  }
}