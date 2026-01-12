import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_map.dart';
import '../../../requests/models/transport_request.dart';
import '../../../trips/models/trip_model.dart';
import '../../../trips/models/route_model.dart';
import '../service/planner_service.dart';

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

  Future<void> _calculateRoute() async {
    setState(() => _isLoading = true);

    try {
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
            content: Text("Errore Calcolo Rotta: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmAndSend() {
    if (_previewTrip != null) {
      Navigator.pop(context);
      widget.onSuccess(_previewTrip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RouteModel? routeToShow = _previewTrip?.route;

    final String mapKey = routeToShow?.polyline ?? "empty_map";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1100,
        height: 800,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),

            Expanded(
              child: Row(
                children: [
                  // --- SIDEBAR ---
                  Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRequestInfoCard(),
                        const SizedBox(height: 24),
                        const Text("OPZIONI PERCORSO",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 16),

                        if (_previewTrip == null) ...[
                          _buildRouteOptionPlaceholder(),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _calculateRoute,
                            icon: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.calculate_outlined),
                            label: Text(_isLoading ? "Elaborazione..." : "CALCOLA ITINERARIO"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Il sistema calcolerà il percorso ottimale per mezzi pesanti usando Mapbox Navigation AI.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ] else ...[
                          _buildResultCard(routeToShow),
                          const Spacer(),
                          const Card(
                            color: Color(0xFFE8F5E9),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 12),
                                  Expanded(child: Text("Rotta generata. Verifica sulla mappa.", style: TextStyle(fontSize: 12))),
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // --- AREA MAPPA ---
                  Expanded(
                    child: Stack(
                      children: [
                        HeavyRouteMap(
                          key: ValueKey(mapKey),
                          route: routeToShow,
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
                                  Text("Interrogazione Mapbox Direction API...",
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

  // --- WIDGETS DI SUPPORTO ---

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
            tooltip: "Chiudi senza salvare",
          )
        ],
      ),
    );
  }

  Widget _buildRequestInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildLocRow(Icons.circle_outlined, widget.request.originAddress, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 2, height: 16, color: Colors.grey.shade300)
            ),
          ),
          _buildLocRow(Icons.location_on, widget.request.destinationAddress, Colors.red),
        ],
      ),
    );
  }

  Widget _buildLocRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOptionPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(child: Text("Nessuna rotta calcolata", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildResultCard(RouteModel? route) {
    if (route == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Percorso Ottimale", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                child: const Text("FASTEST", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 24),
          _buildStatRow(Icons.timer_outlined, "Durata Stimata", route.formattedDuration),
          const SizedBox(height: 12),
          _buildStatRow(Icons.straighten, "Distanza Totale", "${route.distanceKm.toStringAsFixed(1)} km"),
          const SizedBox(height: 12),
          _buildStatRow(Icons.euro, "Pedaggio Stimato", "€${route.tollCost.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
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
            Text("Mappa: Mapbox Streets v12", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
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
            onPressed: _previewTrip != null ? _confirmAndSend : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              disabledBackgroundColor: Colors.grey[300],
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("CONFERMA E INVIA AL COORDINATOR"),
          ),
        ],
      ),
    );
  }
}