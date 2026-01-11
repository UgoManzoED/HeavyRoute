import 'package:flutter/material.dart';
import '../../../../features/requests/models/transport_request.dart';
import '../../../../features/requests/services/request_service.dart';
import '../../../../features/trips/services/trip_service.dart';
import 'transport_requests_table.dart';
// IMPORTA IL DIALOG CHE HAI CREATO PRIMA
import 'route_planner_dialog.dart';

class TransportRequestsTab extends StatefulWidget {
  const TransportRequestsTab({super.key});

  @override
  State<TransportRequestsTab> createState() => _TransportRequestsTabState();
}

class _TransportRequestsTabState extends State<TransportRequestsTab> {
  final RequestService _requestService = RequestService();
  // TripService potrebbe non servire più qui se la logica è spostata nel Dialog,
  // ma lo lasciamo se serve per altre cose.

  late Future<List<TransportRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _requestsFuture = _requestService.getAllRequests();
    });
  }

  /// NUOVA FUNZIONE: Apre il dialog invece di approvare subito

  void _openPlanningDialog(TransportRequest request) {
    showDialog(
      context: context,
      barrierDismissible: false, // L'utente deve premere Annulla o Invia
      builder: (context) => RoutePlanningDialog(
        request: request,
        onSuccess: () {
          // Questa funzione viene chiamata quando il dialog ha finito con successo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Viaggio pianificato e inviato al Traffic Coordinator!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Ricarichiamo la tabella per mostrare lo stato aggiornato
          _loadData();
        },
      ),
    );
  }

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
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<TransportRequest>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Errore dati: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return TransportRequestsTable(
                  requests: snapshot.data!,
                  // COLLEGAMENTO: Passiamo la nuova funzione che apre il dialog
                  onPlanTap: _openPlanningDialog,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ... _buildHeader e _buildEmptyState rimangono uguali ...
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Richieste dal Database", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Elenco aggiornato in tempo reale delle richieste clienti", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _loadData,
          tooltip: "Sincronizza Dati",
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Nessuna richiesta trovata.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}