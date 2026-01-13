import 'package:flutter/material.dart';
import '../../../../features/requests/models/transport_request.dart';
import '../../../../common/models/enums.dart'; // Importa l'enum per usare RequestStatus.PENDING etc

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
          columnSpacing: 24,
          showCheckboxColumn: false,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Origine", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Destinazione", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Carico", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: requests.map((req) => _buildRow(req)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(TransportRequest req) {
    final status = req.requestStatus;

    final originSummary = req.originAddress.split(',').first;
    final destSummary = req.destinationAddress.split(',').first;
    final weightStr = req.load != null ? "${(req.load!.weightKg / 1000).toStringAsFixed(1)}t" : "-"; // In tonnellate

    return DataRow(
      onSelectChanged: (selected) {
        if (selected != null && selected) {
          onRowTap?.call(req);
        }
      },
      cells: [
        DataCell(Text("#${req.id}", style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(req.clientFullName)),
        DataCell(SizedBox(width: 120, child: Text(originSummary, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 120, child: Text(destSummary, overflow: TextOverflow.ellipsis))),
        DataCell(Text(weightStr)),

        // 1. Badge Stato
        DataCell(_buildStatusBadge(status)),

        // 2. Azioni
        DataCell(_buildActionCell(status, req)),
      ],
    );
  }

  Widget _buildActionCell(RequestStatus status, TransportRequest req) {
    // Se è PENDING o APPROVED (In Lavorazione), mostriamo il tasto Pianifica
    if (status == RequestStatus.PENDING || status == RequestStatus.APPROVED) {
      bool isResume = status == RequestStatus.APPROVED;

      return ElevatedButton.icon(
        onPressed: () => onPlanTap(req),
        icon: Icon(isResume ? Icons.edit : Icons.map, size: 14),
        label: Text(isResume ? "Riprendi" : "Pianifica", style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isResume ? Colors.orange[800] : const Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: const Size(0, 32),
        ),
      );
    }
    // Se è già pianificata
    else if (status == RequestStatus.PLANNED) {
      return Row(children: [
        Icon(Icons.check_circle, size: 16, color: Colors.green),
        const SizedBox(width: 6),
        Text("Pianificato", style: TextStyle(color: Colors.green[800], fontSize: 12, fontWeight: FontWeight.bold)),
      ]);
    }
    // Altri casi (completato, cancellato)
    else {
      return const SizedBox();
    }
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color = Colors.grey;
    String label = status.name;

    // Mappatura Colori e Testi
    switch (status) {
      case RequestStatus.PENDING:
        color = Colors.orange;
        label = "NUOVA";
        break;
      case RequestStatus.APPROVED:
        color = Colors.blue;
        label = "IN BOZZA";
        break;
      case RequestStatus.PLANNED:
        color = Colors.green;
        label = "PIANIFICATA";
        break;
      case RequestStatus.REJECTED:
        color = Colors.red;
        label = "RIFIUTATA";
        break;
      case RequestStatus.COMPLETED:
        color = Colors.grey;
        label = "COMPLETATA";
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}