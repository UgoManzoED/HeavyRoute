import 'package:flutter/material.dart';
import '../../../requests/models/transport_request.dart';
import '../../../trips/models/route_model.dart';
import '../service/planner_service.dart';
import 'request_info_card.dart';
import 'resource_selectors.dart';
import 'route_metrics_card.dart';

class RoutePlanningSidebar extends StatefulWidget {
  final TransportRequest request;
  final RouteModel? route;
  final bool isLoading;
  final VoidCallback onCalculate;
  final Function(int driverId, String vehiclePlate) onResourcesSelected;

  const RoutePlanningSidebar({
    super.key,
    required this.request,
    required this.route,
    required this.isLoading,
    required this.onCalculate,
    required this.onResourcesSelected,
  });

  @override
  State<RoutePlanningSidebar> createState() => _RoutePlanningSidebarState();
}

class _RoutePlanningSidebarState extends State<RoutePlanningSidebar> {
  final PlannerService _plannerService = PlannerService();

  List<dynamic> _drivers = [];
  List<dynamic> _vehicles = [];
  bool _loadingResources = true;

  int? _selectedDriverId;
  String? _selectedVehiclePlate;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      final results = await Future.wait([
        _plannerService.getAvailableDrivers(),
        _plannerService.getAvailableVehicles(),
      ]);

      if (mounted) {
        setState(() {
          _drivers = results[0];
          _vehicles = results[1];
          _loadingResources = false;
        });
      }
    } catch (e) {
      debugPrint("Errore risorse: $e");
      if (mounted) setState(() => _loadingResources = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rilevamento Trasporto Eccezionale
    final double loadLen = widget.request.load?.length ?? 0.0;
    final double loadWid = widget.request.load?.width ?? 0.0;
    final bool isExceptional = loadLen > 16.5 || loadWid > 2.55;

    return Container(
      width: 350,
      color: Colors.grey[50],
      child: Column(
        children: [
          // PARTE SCROLLABILE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RequestInfoCard(request: widget.request),
                  const SizedBox(height: 16),

                  if (isExceptional)
                    _buildExceptionalAlert(),

                  const SizedBox(height: 16),
                  const Text("ASSEGNAZIONE RISORSE",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),

                  ResourceSelectors(
                    isLoading: _loadingResources,
                    drivers: _drivers,
                    vehicles: _vehicles,
                    selectedDriverId: _selectedDriverId,
                    selectedVehiclePlate: _selectedVehiclePlate,
                    onDriverChanged: (val) => setState(() => _selectedDriverId = val),
                    onVehicleChanged: (val) => setState(() => _selectedVehiclePlate = val),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  const Text("PIANIFICAZIONE PERCORSO",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),

                  RouteMetricsCard(route: widget.route),

                  if (widget.route != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Percorso pronto per validazione.",
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),

          // PARTE FISSA IN BASSO
          if (widget.route == null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: (widget.isLoading || _selectedDriverId == null || _selectedVehiclePlate == null)
                        ? null
                        : () {
                      widget.onResourcesSelected(_selectedDriverId!, _selectedVehiclePlate!);
                      widget.onCalculate();
                    },
                    icon: widget.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.calculate_outlined),
                    label: Text(widget.isLoading ? "Elaborazione..." : "GENERA PERCORSO PRELIMINARE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                  if (_selectedDriverId == null || _selectedVehiclePlate == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Seleziona risorse per procedere.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExceptionalAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "TRASPORTO ECCEZIONALE\nRichiede scorta tecnica e validazione TC.",
              style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}