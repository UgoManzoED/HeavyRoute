import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_app_bar.dart';
import 'driver_navigation_screen.dart'; // Assicurati che questo file esista (dallo step precedente)

class DriverTripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip; // JSON completo del viaggio

  const DriverTripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // --- 1. ESTRAZIONE DATI SICURA (Anti-Crash) ---

    // Request & Load
    final request = trip['request'] ?? {};
    final load = request['load'] ?? {};

    // Dati Testuali
    final code = trip['tripCode'] ?? "N/D";
    final statusRaw = trip['status']?.toString() ?? "UNK";
    final statusClean = statusRaw.replaceAll('_', ' '); // Es: IN_TRANSIT -> IN TRANSIT

    final customerName = request['customerName'] ?? "Cliente Standard";
    final origin = request['originAddress'] ?? "Indirizzo Ritiro non disp.";
    final destination = request['destinationAddress'] ?? "Indirizzo Consegna non disp.";

    // Dati Numerici (Gestione Load)
    final loadType = request['loadType'] ?? "Merce Generale";
    final weight = load['weightKg']?.toString() ?? "-";
    final length = load['length']?.toString() ?? "-";
    final width = load['width']?.toString() ?? "-";
    final height = load['height']?.toString() ?? "-";

    // Contatto (Placeholder se non arriva dal backend)
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
            // --- HEADER NAVIGAZIONE ---
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
                    // Passa l'intero oggetto trip alla navigazione
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DriverNavigationScreen(trip: trip))
                    );
                  },
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text("NAVIGA"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // --- CARD PRINCIPALE ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Riga Codice e Stato
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(code, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                            statusClean,
                            style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold)
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nome Cliente
                  Text(customerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Indirizzi
                  _buildDetailRow("Indirizzo Ritiro", origin, isAddress: true),
                  _buildDetailRow("Indirizzo Consegna", destination, isAddress: true),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Dettagli Carico
                  _buildDetailRow("Tipologia Merce", "$loadType ($weight kg)"),
                  _buildDetailRow("Dimensioni (LxPxA)", "${length}x${width}x$height m"),
                  _buildDetailRow("Riferimento", contact),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Documentazione Digitale", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // --- DOCUMENTI (Mock Dinamico) ---
            _buildDocTile("DDT_${code.replaceAll('-', '_')}.pdf", "Documento di Trasporto"),
            const SizedBox(height: 8),
            _buildDocTile("AUTORIZZAZIONE_TRANSITO.pdf", "Permesso Trasporto Eccezionale"),
          ],
        ),
      ),
    );
  }

  // Widget Helper per le righe di dettaglio
  Widget _buildDetailRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13))
          ),
          Expanded(
              child: Text(
                value,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isAddress ? Colors.black87 : Colors.black
                ),
                maxLines: isAddress ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              )
          ),
        ],
      ),
    );
  }

  // Widget Helper per i documenti
  Widget _buildDocTile(String filename, String description) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        ),
        title: Text(filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.download_rounded, color: Colors.grey),
          onPressed: () {
            // Placeholder per download
          },
        ),
      ),
    );
  }
}