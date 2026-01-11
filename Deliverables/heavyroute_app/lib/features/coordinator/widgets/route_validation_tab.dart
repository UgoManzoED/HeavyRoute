import 'package:flutter/material.dart';
import '../services/coordinator_service.dart';
import '../../trips/models/trip_model.dart';
import '../../../../common/models/enums.dart';

class RouteValidationTab extends StatefulWidget {
  const RouteValidationTab({super.key});

  @override
  State<RouteValidationTab> createState() => _RouteValidationTabState();
}

class _RouteValidationTabState extends State<RouteValidationTab> {
  final TrafficCoordinatorService _service = TrafficCoordinatorService();

  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Recupera sia quelli DA VALIDARE (per lavorarli)
      // sia quelli VALIDATI (per storico, se il backend lo permette, o filtra solo WAITING)
      final data = await _service.getProposedRoutes();
      if (mounted) {
        setState(() {
          _trips = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Gestisce la validazione effettiva chiamando il servizio
  Future<void> _executeValidation(int tripId, bool approved) async {
    // Mostra caricamento (opzionale se dentro dialog)
    final success = await _service.validateRoute(tripId, approved);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? "Percorso validato e notificato al Planner!" : "Richiesta respinta."),
          backgroundColor: approved ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Ricarica i dati per aggiornare la UI e rimuovere l'elemento o cambiare stato
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'operazione"), backgroundColor: Colors.red),
      );
    }
  }

  /// Apre il popup con la Mappa (Placeholder) prima di confermare
  void _openValidationDialog(TripModel trip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Verifica Percorso: ${trip.tripCode}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("${trip.request.origin} -> ${trip.request.destination}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // --- PLACEHOLDER MAPPA ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // Colore azzurrino tipo mappa
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Stack(
                    children: [
                      // Sfondo griglia simulata
                      Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: GridView.builder(
                            itemCount: 100,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                            itemBuilder: (c, i) => Container(
                              margin: const EdgeInsets.all(1),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Tracciato e Pin
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_outlined, size: 64, color: Colors.blueGrey),
                            const SizedBox(height: 16),
                            Text("Visualizzazione Mappa Interattiva",
                                style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("Qui verrà renderizzato il percorso calcolato\ncon i vincoli di viabilità applicati.",
                                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // -------------------------

              const SizedBox(height: 24),

              // Pulsanti Azione
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // 1. Chiudi Dialog
                      Navigator.pop(context);
                      // 2. Esegui Validazione
                      await _executeValidation(trip.id, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("CONFERMA E VALIDA", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Validazione Percorsi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Esamina la mappa e approva i percorsi per renderli definitivi.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),

          const SizedBox(height: 32),
          _buildTableHeader(),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _trips.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildRouteRow(_trips[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ... _buildEmptyState e _buildTableHeader restano uguali ...
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Nessun percorso in attesa di validazione",
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 1, child: Text("VIAGGIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 3, child: Text("ITINERARIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("DATI TECNICI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("STATO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("AZIONI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildRouteRow(TripModel trip) {
    final bool isPending = trip.status == TripStatus.WAITING_VALIDATION;

    final String distance = trip.route != null
        ? "${trip.route!.distanceKm.toStringAsFixed(1)} km"
        : "-";

    final String duration = trip.route != null
        ? trip.route!.formattedDuration
        : "-";

    final String description = trip.route?.description ?? "Standard";

    return Container(
      color: isPending ? const Color(0xFFFFFBEB) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Codice
          Expanded(flex: 1, child: Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),

          // 2. Itinerario
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLocationRow(Icons.circle, trip.request.origin, isStart: true),
            const SizedBox(height: 4),
            _buildLocationRow(Icons.location_on, trip.request.destination, isStart: false),
          ])),

          // 3. Dati Tecnici
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text("$distance • $duration", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),

          // 4. Stato
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: _buildStatusChip(trip.status),
          )),

          // 5. Azioni
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPending) ...[
                // MODIFICA QUI: Il bottone chiama _openValidationDialog
                _buildActionButton(
                  "Esamina",
                  const Color(0xFF0D0D1A),
                  Colors.white,
                  Icons.map, // Icona cambiata in Mappa
                      () => _openValidationDialog(trip),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Rifiuta",
                  onPressed: () => _executeValidation(trip.id, false), // Rifiuto diretto senza mappa
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: Colors.blueGrey),
                  tooltip: "Vedi Dettagli",
                  onPressed: () => _openValidationDialog(trip), // Riapre la mappa solo per view
                ),
              ]
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text, {bool isStart = false}) {
    return Row(children: [
      Icon(icon, size: 10, color: isStart ? Colors.black : Colors.red),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1))
    ]);
  }

  Widget _buildStatusChip(TripStatus status) {
    Color bg = Colors.grey.shade100;
    Color text = Colors.grey.shade700;
    String label = status.name;

    if (status == TripStatus.WAITING_VALIDATION) {
      bg = Colors.orange.shade50;
      text = Colors.orange.shade800;
      label = "DA VALIDARE";
    } else if (status == TripStatus.VALIDATED) {
      bg = Colors.green.shade50;
      text = Colors.green.shade800;
      label = "VALIDATO";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg == Colors.grey.shade100 ? Colors.transparent : text.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Widget _buildActionButton(String label, Color bg, Color fg, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: fg),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, 32),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}