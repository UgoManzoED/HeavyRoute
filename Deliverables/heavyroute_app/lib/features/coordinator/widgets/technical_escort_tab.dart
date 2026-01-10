import 'package:flutter/material.dart';

class TechnicalEscortTab extends StatelessWidget {
  const TechnicalEscortTab({super.key});

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
          // Header
          const Text("Gestione Scorta Tecnica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Coordina le scorte di polizia e private per i trasporti eccezionali",
              style: TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 24),

          // Intestazione Tabella
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text("Riferimento Trasporto", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text("Tipologia Scorta", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 3, child: Text("Fornitore / Ente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text("Data e Orario", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
          ),
          const Divider(),

          // Lista Righe (Mockup)
          Expanded(
            child: ListView(
              children: [
                _buildEscortRow(
                  ref: "ORD-045 (Milano-Roma)",
                  type: "Polizia Stradale",
                  provider: "Compartimento Lombardia",
                  date: "20 Gen 2025 - 22:00",
                  status: "Confermata",
                  statusColor: Colors.green,
                ),
                _buildEscortRow(
                  ref: "ORD-051 (Torino-Napoli)",
                  type: "Scorta Tecnica Privata",
                  provider: "SicurTransport S.r.l.",
                  date: "22 Gen 2025 - 05:00",
                  status: "In Attesa",
                  statusColor: Colors.orange,
                ),
                _buildEscortRow(
                  ref: "ORD-099 (Genova-Bari)",
                  type: "Mista (Poli + Priv)",
                  provider: "Polizia Stradale + EuroGuard",
                  date: "25 Gen 2025 - 23:00",
                  status: "Richiesta",
                  statusColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscortRow({
    required String ref, required String type, required String provider,
    required String date, required String status, required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(ref, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 2, child: Row(children: [
            Icon(type.contains("Polizia") ? Icons.local_police : Icons.security, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Text(type, style: const TextStyle(fontSize: 13)),
          ])),
          Expanded(flex: 3, child: Text(provider, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13))),

          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
            ),
          )),

          Expanded(flex: 1, child: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
            onPressed: () {},
          )),
        ],
      ),
    );
  }
}