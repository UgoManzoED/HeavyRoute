import 'package:flutter/material.dart';
import '../../../../features/requests/models/transport_request.dart';

class TransportRequestsTable extends StatelessWidget {
  final List<TransportRequest> requests;
  // MODIFICA 1: Ora passiamo l'intero oggetto request, non solo l'int id
  final Function(TransportRequest) onPlanTap;

  const TransportRequestsTable({
    super.key,
    required this.requests,
    required this.onPlanTap, // Rinominiamo per chiarezza
  });

  @override
  Widget build(BuildContext context) {
    // ... il resto del build rimane uguale ...
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          // ... columns rimangono uguali ...
          columnSpacing: 30,
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
    final status = req.requestStatus.name;
    final bool canApprove = status == "PENDING";

    // ... logica formattazione date/stringhe rimane uguale ...
    final dateStr = req.pickupDate.toString().split(' ').first;
    final origin = req.originAddress.split(',').first;
    final dest = req.destinationAddress.split(',').first;
    final weight = req.load != null ? "${req.load!.weightKg} kg" : "-";

    return DataRow(cells: [
      DataCell(Text("#${req.id}", style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(req.customerName)),
      DataCell(SizedBox(width: 150, child: Text(origin, overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 150, child: Text(dest, overflow: TextOverflow.ellipsis))),
      DataCell(Text(weight)),
      DataCell(Text(dateStr)),
      DataCell(_buildStatusBadge(status)),
      DataCell(
        canApprove
            ? ElevatedButton.icon( // MODIFICA 2: Usiamo icon button per stile
          onPressed: () => onPlanTap(req), // Passiamo l'intera request
          icon: const Icon(Icons.map, size: 14), // Icona Mappa
          label: const Text("Pianifica", style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D0D1A), // O Colors.indigo per differenziare
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: const Size(0, 32),
          ),
        )
            : const Text("Gestita", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12)),
      ),
    ]);
  }

  // ... _buildStatusBadge rimane uguale ...
  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == "APPROVED") color = Colors.green;
    if (status == "PENDING") color = Colors.orange;
    if (status == "REJECTED") color = Colors.red;

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