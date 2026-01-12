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
          // Rende la riga visivamente interattiva quando selezionata
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
    final bool isPending = statusName == "PENDING";

    // Formattazione per pulizia UI
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
        // Nota: Assicurati che il campo nel modello sia clientFullName
        DataCell(Text(req.clientFullName)),
        DataCell(SizedBox(width: 150, child: Text(originSummary, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 150, child: Text(destSummary, overflow: TextOverflow.ellipsis))),
        DataCell(Text(weightStr)),
        DataCell(Text(dateStr)),
        DataCell(_buildStatusBadge(statusName)),
        DataCell(
          isPending
              ? ElevatedButton.icon(
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
          )
              : const Text("Gestita",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == "APPROVED") color = Colors.green;
    if (status == "PENDING") color = Colors.orange;
    if (status == "REJECTED") color = Colors.red;
    if (status == "PLANNED") color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}