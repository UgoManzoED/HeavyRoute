import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_map.dart';
import '../../trips/models/route_model.dart';
import '../../trips/models/trip_model.dart';

class RouteValidationDialog extends StatefulWidget {
  final TripModel trip;
  final bool isReadOnly;
  final Future<void> Function(int tripId, bool approved) onValidation;

  const RouteValidationDialog({
    super.key,
    required this.trip,
    this.isReadOnly = false, // Default false (Modalità Modifica)
    required this.onValidation,
  });

  @override
  State<RouteValidationDialog> createState() => _RouteValidationDialogState();
}

class _RouteValidationDialogState extends State<RouteValidationDialog> {
  bool _isProcessing = false;

  // Stato per i permessi ANAS
  bool _anasPermissionRequested = false;
  bool _policePermissionRequested = false;

  @override
  void initState() {
    super.initState();
    // Se siamo in sola lettura (Storico), simuliamo che i permessi siano già OK
    if (widget.isReadOnly) {
      _anasPermissionRequested = true;
      _policePermissionRequested = true;
    }
  }

  Future<void> _handleValidation(bool approved) async {
    setState(() => _isProcessing = true);
    await widget.onValidation(widget.trip.id, approved);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final RouteModel? route = widget.trip.route;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000,
        height: 800,
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Dettaglio Percorso ${widget.trip.tripCode}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          // Badge se sola lettura
                          if (widget.isReadOnly)
                            Container(
                              margin: const EdgeInsets.only(left: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                              child: const Text("CONFERMATO", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("${widget.trip.request.originAddress} -> ${widget.trip.request.destinationAddress}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // BODY
            Expanded(
              child: Row(
                children: [
                  // COLONNA SINISTRA: Controlli
                  Container(
                    width: 350,
                    color: Colors.grey[50],
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(),
                        const SizedBox(height: 24),
                        const Text("PERMESSI E SCORTA",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 12),

                        // Checkbox disabilitati se readonly
                        _buildCheckItem("Nulla Osta ANAS", _anasPermissionRequested,
                            widget.isReadOnly ? null : (val) => setState(() => _anasPermissionRequested = val!)),
                        _buildCheckItem("Notifica Polizia Stradale", _policePermissionRequested,
                            widget.isReadOnly ? null : (val) => setState(() => _policePermissionRequested = val!)),

                        const Spacer(),

                        // LOGICA BOTTONI
                        if (!widget.isReadOnly) ...[
                          // MODALITÀ VALIDAZIONE
                          if (_isProcessing)
                            const Center(child: CircularProgressIndicator())
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _handleValidation(false),
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  label: const Text("RIFIUTA PERCORSO", style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(20)),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: (_anasPermissionRequested && _policePermissionRequested)
                                      ? () => _handleValidation(true)
                                      : null,
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text("VALIDA E CONFERMA"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D0D1A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(20),
                                  ),
                                ),
                              ],
                            )
                        ] else ...[
                          // MODALITÀ SOLA LETTURA
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Viaggio validato e operativo.\nNon sono possibili modifiche.",
                                    style: TextStyle(color: Colors.green[800], fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // COLONNA DESTRA: Mappa Reale
                  Expanded(
                    child: Stack(
                      children: [
                        HeavyRouteMap(route: route),
                        if (!widget.isReadOnly)
                          Positioned(
                            top: 16, right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white.withOpacity(0.9),
                              child: const Text("Visualizzazione Punti Critici",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(Icons.straighten, "Lunghezza Carico", "${widget.trip.request.load?.length} m"),
          const SizedBox(height: 8),
          _buildRow(Icons.monitor_weight, "Peso Totale", "${widget.trip.request.load?.weightKg} kg"),
          const SizedBox(height: 8),
          _buildRow(Icons.person, "Autista", "${widget.trip.formattedDriverName}"),
          const SizedBox(height: 8),
          _buildRow(Icons.local_shipping, "Veicolo", "${widget.trip.vehiclePlate}"),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String val) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Text("$label:", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(width: 4),
      Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildCheckItem(String title, bool val, Function(bool?)? onChanged) {
    return CheckboxListTile(
      value: val,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontSize: 13)),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      activeColor: Colors.green,
    );
  }
}