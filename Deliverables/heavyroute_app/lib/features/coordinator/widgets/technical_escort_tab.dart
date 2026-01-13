import 'package:flutter/material.dart';

class TechnicalEscortTab extends StatelessWidget {
  const TechnicalEscortTab({super.key});

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gestione Scorta Tecnica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Coordina le scorte di polizia e private per i trasporti eccezionali",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {}, // Futura implementazione Nuovo Ordine Scorta
                icon: const Icon(Icons.add_moderator, size: 16),
                label: const Text("Richiedi Nuova Scorta"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D0D1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )
            ],
          ),

          const SizedBox(height: 24),

          // Intestazione Tabella
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text("RIFERIMENTO TRASPORTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 2, child: Text("TIPOLOGIA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 3, child: Text("FORNITORE / ENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 2, child: Text("DATA PREVISTA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 1, child: Text("STATO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 1, child: Text("AZIONI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey), textAlign: TextAlign.end)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista Righe
          Expanded(
            child: ListView(
              children: [
                _buildEscortRow(
                  ref: "T-2026-0001 (Hitachi Napoli -> Pistoia)",
                  type: "Scorta Tecnica Privata",
                  provider: "RoadSafe S.r.l.",
                  date: "22 Gen 2026 - 08:00",
                  status: "PIANIFICATA",
                  statusColor: Colors.blue,
                ),
                _buildEscortRow(
                  ref: "T-2026-0045 (Genova -> Milano)",
                  type: "Polizia Stradale",
                  provider: "Compartimento Lombardia",
                  date: "20 Feb 2026 - 22:00",
                  status: "CONFERMATA",
                  statusColor: Colors.green,
                ),
                _buildEscortRow(
                  ref: "T-2026-0099 (Bologna -> Bari)",
                  type: "Mista (Poli + Priv)",
                  provider: "Polizia Stradale + EuroGuard",
                  date: "Da definire",
                  status: "IN ATTESA",
                  statusColor: Colors.orange,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(ref, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Row(children: [
            Icon(type.contains("Polizia") ? Icons.local_police_outlined : Icons.security_outlined, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Expanded(child: Text(type, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          ])),
          Expanded(flex: 3, child: Text(provider, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey))),

          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
            ),
          )),

          Expanded(flex: 1, child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
              tooltip: "Gestisci",
              onPressed: () {},
            ),
          )),
        ],
      ),
    );
  }
}