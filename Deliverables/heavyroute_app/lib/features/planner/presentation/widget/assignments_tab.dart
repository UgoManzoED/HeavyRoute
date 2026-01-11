import 'package:flutter/material.dart';
import '../../../../common/models/enums.dart';
import '../../../trips/models/trip_model.dart';
import '../service/assignment_service.dart';

/**
 * Tab per la gestione e visualizzazione delle assegnazioni attive.
 */
class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  final AssignmentService _assignmentService = AssignmentService();

  late Future<List<TripModel>> _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  /**
   * Innesca il caricamento delle assegnazioni dal backend.
   * Recupera i viaggi in stato 'CONFIRMED' o 'IN_TRANSIT'.
   */
  void _loadAssignments() {
    setState(() {
      _assignmentsFuture = _assignmentService.getTripsByStatus(TripStatus.CONFIRMED);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<TripModel>>(
              future: _assignmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildAssignmentsTable(snapshot.data!);
              },
            ),
          )
        ],
      ),
    );
  }

  /**
   * Costruisce l'header con titolo e pulsante di refresh.
   */
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Assegnazioni Attive", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Visualizza e gestisci le assegnazioni di viaggio dal database",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAssignments,
          tooltip: "Sincronizza",
        )
      ],
    );
  }

  Widget _buildAssignmentsTable(List<TripModel> trips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 30,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text("Codice", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Percorso", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Autista", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Veicolo", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: trips.map((trip) => _buildDataRow(trip)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(TripModel trip) {
    final origin = trip.request.originAddress.split(',').first;
    final destination = trip.request.destinationAddress.split(',').first;

    return DataRow(cells: [
      DataCell(Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(trip.request.customerName ?? "Cliente")),
      DataCell(Text("$origin → $destination")),
      DataCell(Text(trip.driverName ?? "In attesa")),
      DataCell(Text(trip.vehiclePlate ?? "N/D")),
      DataCell(_buildStatusBadge(trip.status)),
    ]);
  }

  Widget _buildStatusBadge(TripStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D0D1A).withOpacity(0.1)),
      ),
      child: Text(
        status.name,
        style: const TextStyle(color: Color(0xFF0D0D1A), fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  /**
   * Widget per lo stato vuoto (nessun dato nel DB).
   */
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.near_me_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Nessuna assegnazione attiva trovata nel database", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  /**
   * Widget per lo stato di errore.
   */
  Widget _buildErrorState(String message) {
    return Center(child: Text("Errore durante il recupero delle assegnazioni: $message", style: const TextStyle(color: Colors.red)));
  }
}