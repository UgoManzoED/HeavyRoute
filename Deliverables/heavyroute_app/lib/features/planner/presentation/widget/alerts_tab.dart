import 'package:flutter/material.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

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
          const Text(
            "Segnalazioni e Notifiche",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Gestisci le segnalazioni dagli autisti e i cambi di percorso dal Traffic Coordinator",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 25, // Spaziatura tra colonne
                  headingRowColor: WidgetStateProperty.all(Colors.transparent),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 70, // Righe leggermente più alte per i badge
                  columns: const [
                    DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Mittente", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Viaggio", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Oggetto", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Priorità", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Data/Ora", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    _buildAlertRow("REP-001", "Autista", "Marco Rossi (DRV-001)", "ORD-045", "Problema al carico", "Alta", "Nuova", "2025-10-22 14:30", true),
                    _buildAlertRow("REP-002", "Traffic C.", "Traffic Coordinator", "ORD-038", "Cambio percorso approvato", "Media", "Nuova", "2025-10-22 13:15", true),
                    _buildAlertRow("REP-003", "Autista", "Giuseppe Bianchi (DRV-002)", "ORD-042", "Condizioni meteo avverse", "Alta", "Letta", "2025-10-22 11:45", false),
                    _buildAlertRow("REP-004", "Traffic C.", "Traffic Coordinator", "ORD-051", "Modifica orario scarico", "Bassa", "Gestita", "2025-10-22 09:20", false),
                    _buildAlertRow("REP-005", "Autista", "Andrea Neri (DRV-004)", "ORD-047", "Malfunzionamento GPS", "Media", "Nuova", "2025-10-22 08:55", true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildAlertRow(
      String id,
      String type,
      String sender,
      String tripId,
      String subject,
      String priority,
      String status,
      String date,
      bool isUrgent // Usato per decidere il colore del bottone
      ) {
    // Sfondo leggermente rosato per le righe prioritarie o nuove (come nella foto)
    final bool highlightRow = status == "Nuova" || priority == "Alta";

    return DataRow(
      color: highlightRow ? WidgetStateProperty.all(const Color(0xFFFFF5F5)) : null,
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataCell(_buildTypeBadge(type)),
        DataCell(Text(sender, style: const TextStyle(fontSize: 13))),
        DataCell(Text(tripId, style: const TextStyle(fontFamily: 'Monospace', fontSize: 12))),
        DataCell(Text(subject, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(_buildPriorityBadge(priority)),
        DataCell(_buildStatusBadge(status)),
        DataCell(Text(date, style: TextStyle(color: Colors.blue[800], fontSize: 12))),
        DataCell(
          isUrgent
              ? ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D0D1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text("Visualizza", style: TextStyle(fontSize: 12)),
          )
              : OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text("Dettagli", style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  // Badge per Autista vs Traffic Coordinator
  Widget _buildTypeBadge(String type) {
    final bool isDriver = type == "Autista";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDriver ? const Color(0xFF0D0D1A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: isDriver ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              isDriver ? Icons.person : Icons.near_me,
              size: 12,
              color: isDriver ? Colors.white : Colors.black54
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
                color: isDriver ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  // Badge Priorità (Alta = Nero, Media/Bassa = Grigio)
  Widget _buildPriorityBadge(String priority) {
    Color bg = Colors.grey.shade200;
    Color text = Colors.black87;

    if (priority == "Alta") {
      bg = const Color(0xFF0D0D1A);
      text = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(priority, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // Badge Stato (Nuova = Rosso, Altro = Bianco/Grigio)
  Widget _buildStatusBadge(String status) {
    if (status == "Nuova") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12)
      ),
      child: Text(status, style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}