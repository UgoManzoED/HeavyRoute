import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_map.dart';
import '../../../requests/models/transport_request.dart';
import '../../../trips/models/trip_model.dart';
import '../../../trips/models/route_model.dart';
import '../service/planner_service.dart';
import 'route_planning_sidebar.dart';

class RoutePlanningDialog extends StatefulWidget {
  final TransportRequest request;
  final Function(TripModel?) onSuccess;

  const RoutePlanningDialog({
    super.key,
    required this.request,
    required this.onSuccess,
  });

  @override
  State<RoutePlanningDialog> createState() => _RoutePlanningDialogState();
}

class _RoutePlanningDialogState extends State<RoutePlanningDialog> {
  final PlannerService _service = PlannerService();

  bool _isLoading = false;
  TripModel? _previewTrip;

  // STATO SELEZIONI UTENTE
  int? _selectedDriverId;
  String? _selectedVehiclePlate;

  // --- STEP 1: CALCOLO ROTTA PRELIMINARE ---
  Future<void> _calculateRoute() async {
    setState(() => _isLoading = true);

    try {
      // Chiama il backend per generare il Trip (bozza) e la Rotta
      final TripModel? trip = await _service.approveRequestAndGetTrip(
        widget.request.id,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _previewTrip = trip;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore Calcolo: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- STEP 2: CONFERMA E ASSEGNAZIONE RISORSE ---
  Future<void> _confirmAndSend() async {
    // Validazione finale
    if (_previewTrip == null || _selectedDriverId == null || _selectedVehiclePlate == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chiamata al backend per assegnare Autista e Veicolo al Trip creato
      bool success = await _service.assignResources(
          _previewTrip!.id,
          _selectedDriverId!,
          _selectedVehiclePlate!
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context); // Chiude il dialog
          widget.onSuccess(_previewTrip); // Aggiorna la dashboard

          // Feedback visivo positivo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Viaggio pianificato e risorse assegnate con successo!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("Il server ha rifiutato l'assegnazione.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore Assegnazione: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final RouteModel? routeToShow = _previewTrip?.route;

    // Key per forzare il refresh della mappa se cambia la rotta
    final String mapKey = routeToShow?.polyline ?? "empty";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 1200,
        height: 850,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. SIDEBAR INTELLIGENTE ---
                  RoutePlanningSidebar(
                    request: widget.request,
                    route: routeToShow,
                    isLoading: _isLoading,
                    onCalculate: _calculateRoute,
                    // Catturiamo le scelte dell'utente dalla sidebar
                    onResourcesSelected: (driverId, plate) {
                      _selectedDriverId = driverId;
                      _selectedVehiclePlate = plate;
                    },
                  ),

                  const VerticalDivider(width: 1),

                  // --- 2. MAPPA ---
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRect(
                          child: HeavyRouteMap(
                            key: ValueKey(mapKey),
                            route: routeToShow,
                          ),
                        ),

                        _buildMapOverlay(),

                        if (_isLoading)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 16),
                                  Text("Elaborazione in corso...",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pianificazione Viaggio",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Richiesta #${widget.request.id} • ${widget.request.clientFullName}",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: "Chiudi",
          )
        ],
      ),
    );
  }

  Widget _buildMapOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers, size: 16, color: Colors.blueGrey),
            SizedBox(width: 8),
            Text("Mapbox Streets v12", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    // Il pulsante di conferma è attivo SOLO se abbiamo tutto: rotta, autista e veicolo.
    final bool canConfirm = _previewTrip != null &&
        _selectedDriverId != null &&
        _selectedVehiclePlate != null;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: canConfirm ? _confirmAndSend : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              disabledBackgroundColor: Colors.grey[300],
            ),
            icon: const Icon(Icons.send),
            label: const Text("INVIA AL TRAFFIC COORDINATOR"),
          ),
        ],
      ),
    );
  }
}