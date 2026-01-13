import 'package:flutter/material.dart';
import '../../../../features/requests/models/transport_request.dart';
import '../../../../features/requests/services/request_service.dart';
import '../../../../features/trips/models/route_model.dart';
import '../../../../features/trips/models/trip_model.dart';
import 'transport_requests_table.dart';
import 'route_planner_dialog.dart';

class TransportRequestsTab extends StatefulWidget {
  final Function(RouteModel?) onRoutePreview;

  const TransportRequestsTab({
    super.key,
    required this.onRoutePreview,
  });

  @override
  State<TransportRequestsTab> createState() => _TransportRequestsTabState();
}

class _TransportRequestsTabState extends State<TransportRequestsTab> {
  final RequestService _requestService = RequestService();
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

  /// Apre il dialog di pianificazione e gestisce il ritorno della rotta
  void _openPlanningDialog(TransportRequest request) async{
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoutePlanningDialog(
        request: request,
        onSuccess: (TripModel? createdTrip) {
          // 1. Notifica la Dashboard per mostrare la rotta sulla mappa
          if (createdTrip != null && createdTrip.route != null) {
            widget.onRoutePreview(createdTrip.route);
          }

          // 2. Feedback visivo all'utente
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Viaggio pianificato! Proposta inviata al Coordinator."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 3. Ricarica la tabella
          _loadData();
        },
      ),
    );
    if (mounted) {
      _loadData();
    }
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
                  // Passiamo la funzione che apre il dialog
                  onPlanTap: _openPlanningDialog,
                  // Se l'utente clicca sulla riga, possiamo resettare o mostrare la mappa
                  onRowTap: (request) {
                    // Opzionale: se la richiesta ha già una rotta, mostriamola
                    // widget.onRoutePreview(request.existingRoute);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Richieste dal Database",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Elenco aggiornato in tempo reale",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
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
          const Text("Nessuna richiesta trovata.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}