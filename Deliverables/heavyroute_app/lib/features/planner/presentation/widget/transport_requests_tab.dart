import 'package:flutter/material.dart';

class TransportRequestsTab extends StatelessWidget {
  const TransportRequestsTab({super.key});

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
          const Text("Nuove Richieste di Trasporto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Gestisci e approva le richieste di trasporto dai committenti", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 30,
                  headingRowColor: MaterialStateProperty.all(Colors.transparent),
                  columns: const [
                    DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Committente", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Origine", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Destinazione", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Tipologia", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Peso", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Data Ritiro", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    _buildRow("REQ-001", "ABC Logistics", "Milano, Via Roma 123", "Roma, Via del Corso 45", "Macchinari industriali", "15 ton", "2025-10-25", "In Attesa"),
                    _buildRow("REQ-002", "XYZ Construction", "Torino, Corso Francia", "Napoli, Via Toledo", "Materiali edili", "8 ton", "2025-10-24", "In Attesa"),
                    _buildRow("REQ-003", "Tech Solutions", "Bologna, Via Indip.", "Firenze, P.zza Duomo", "Apparecchiature", "3.5 ton", "2025-10-26", "Approvata", approved: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(String id, String client, String origin, String dest, String type, String weight, String date, String status, {bool approved = false}) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(client)),
      DataCell(SizedBox(width: 150, child: Text(origin, overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 150, child: Text(dest, overflow: TextOverflow.ellipsis))),
      DataCell(Text(type)),
      DataCell(Text(weight)),
      DataCell(Text(date)),
      DataCell(_buildStatusBadge(status, approved)),
      DataCell(Row(
        children: [
          if (!approved) ...[
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calculate_outlined, size: 14),
              label: const Text("Preventivo"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white), child: const Text("Approva")),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text("Rifiuta")),
          ] else ...[
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map, size: 14),
              label: const Text("Percorso"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black87),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.near_me, size: 14),
              label: const Text("Assegna"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white),
            ),
          ]
        ],
      )),
    ]);
  }

  Widget _buildStatusBadge(String text, bool approved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: approved ? const Color(0xFF0D0D1A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: approved ? Colors.transparent : Colors.grey.shade300)
      ),
      child: Text(text, style: TextStyle(color: approved ? Colors.white : Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}