import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../common/models/enums.dart';
import '../../models/transport_request.dart';
import 'request_action_popup.dart';

class RequestCard extends StatelessWidget {
  final TransportRequest request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMM yyyy', 'it_IT').format(request.pickupDate);

    // Gestione status
    final statusColor = _getStatusColor(request.requestStatus);
    final statusText = _getStatusText(request.requestStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: ID e STATO
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D1A).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tag, size: 16, color: Color(0xFF0D0D1A)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      request.formattedId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D0D1A)),
                    ),
                  ],
                ),
                // Badge Stato
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          // BODY: Timeline e Dettagli
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // TIMELINE (Origine -> Destinazione)
                _buildTimeline(),

                const SizedBox(height: 20),

                // DETTAGLI CARICO & DATA (Griglia 2x1)
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                          Icons.monitor_weight_outlined,
                          "Carico",
                          _getLoadDetailsString()
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                          Icons.calendar_today_outlined,
                          "Data Ritiro",
                          formattedDate
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FOOTER: Bottone Azione
          if (request.requestStatus == RequestStatus.PENDING)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openRequestActionDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Modifica / Annulla"),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildTimeline() {
    final origin = request.originAddress ?? "Origine non disp.";
    final dest = request.destinationAddress ?? "Destinazione non disp.";

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Linea grafica
          Column(
            children: [
              const Icon(Icons.circle, size: 12, color: Color(0xFF0D0D1A)),
              Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
              const Icon(Icons.location_on, size: 14, color: Color(0xFF0D0D1A)),
            ],
          ),
          const SizedBox(width: 16),
          // Testi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("RITIRO", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    Text(origin, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CONSEGNA", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    Text(dest, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D0D1A))),
      ],
    );
  }

  // --- LOGICA DATI ---

  String _getLoadDetailsString() {
    if (request.load == null) return "Non specificato";

    final type = request.load!.loadType;
    final weight = request.load!.weightKg > 1000
        ? "${(request.load!.weightKg / 1000).toStringAsFixed(1)}t"
        : "${request.load!.weightKg.toInt()}kg";

    return "$type • $weight";
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.PENDING: return Colors.orange.shade700;
      case RequestStatus.APPROVED: return Colors.blue.shade700;
      case RequestStatus.COMPLETED: return Colors.green.shade700;
      case RequestStatus.REJECTED: return Colors.red.shade700;
      default: return Colors.grey.shade700;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.PENDING: return "IN ATTESA";
      case RequestStatus.APPROVED: return "APPROVATO";
      case RequestStatus.COMPLETED: return "COMPLETATO";
      case RequestStatus.REJECTED: return "RIFIUTATO";
      default: return status.name;
    }
  }

  void _openRequestActionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RequestActionPopup(request: request),
    );
  }
}