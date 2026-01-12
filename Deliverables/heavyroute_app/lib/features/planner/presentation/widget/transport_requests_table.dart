import 'package:flutter/material.dart';
import '../../../../features/requests/models/transport_request.dart';

class TransportRequestsTable extends StatelessWidget {
  final List<TransportRequest> requests;
  final Function(TransportRequest) onPlanTap;
  final Function(TransportRequest)? onRowTap;

  const TransportRequestsTable({
    super.key,
    required this.requests,
    required this.onPlanTap,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 30,
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Origine", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Destinazione", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Peso", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Data", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: requests.map((req) => _buildRow(req)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(TransportRequest req) {
    final String statusName = req.requestStatus.name;

    // Logica stati
    final bool isPending = statusName == "PENDING";
    final bool isWaitingValidation = statusName == "WAITING_VALIDATION";

    // Formattazione
    final dateStr = req.pickupDate.toString().split(' ').first;
    final originSummary = req.originAddress.split(',').first;
    final destSummary = req.destinationAddress.split(',').first;
    final weightStr = req.load != null ? "${req.load!.weightKg} kg" : "-";

    return DataRow(
      onSelectChanged: (selected) {
        if (selected != null && selected) {
          onRowTap?.call(req);
        }
      },
      cells: [
        DataCell(Text("#${req.id}", style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(req.clientFullName)),
        DataCell(SizedBox(width: 150, child: Text(originSummary, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 150, child: Text(destSummary, overflow: TextOverflow.ellipsis))),
        DataCell(Text(weightStr)),
        DataCell(Text(dateStr)),
        // 1. Badge Stato Colorato
        DataCell(_buildStatusBadge(statusName)),

        // 2. Colonna Azioni Dinamica
        DataCell(
          _buildActionCell(isPending, isWaitingValidation, req),
        ),
      ],
    );
  }

  /// Costruisce il contenuto della cella azioni in base allo stato
  Widget _buildActionCell(bool isPending, bool isWaitingValidation, TransportRequest req) {
    if (isPending) {
      // CASO 1: Nuova richiesta da pianificare
      return ElevatedButton.icon(
        onPressed: () => onPlanTap(req),
        icon: const Icon(Icons.map, size: 14),
        label: const Text("Pianifica", style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: const Size(0, 32),
        ),
      );
    } else if (isWaitingValidation) {
      // CASO 2: Inviata al TC, in attesa di validazione
      return Row(
        children: [
          Icon(Icons.hourglass_top, size: 16, color: Colors.indigo[300]),
          const SizedBox(width: 6),
          Text("Attesa TC", style: TextStyle(color: Colors.indigo[900], fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );
    } else {
      // CASO 3: Approvata, Rifiutata o altro
      return const Text("Gestita",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12));
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String label = status;

    // Mappatura Colori e Testi
    switch (status) {
      case "APPROVED":
        color = Colors.green;
        break;
      case "PENDING":
        color = Colors.orange;
        break;
      case "REJECTED":
        color = Colors.red;
        break;
      case "PLANNED":
        color = Colors.blue;
        break;
      case "WAITING_VALIDATION":
        color = Colors.indigo;
        label = "VALIDAZIONE";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}