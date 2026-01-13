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

    final statusConfig = _getStatusConfig(request.requestStatus);

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
                      "#${request.id}", // ID semplice
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D0D1A)),
                    ),
                  ],
                ),
                // Badge Stato
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusConfig.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusConfig.color.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusConfig.icon, size: 12, color: statusConfig.color),
                      const SizedBox(width: 6),
                      Text(
                        statusConfig.label,
                        style: TextStyle(color: statusConfig.color, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
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
                _buildTimeline(),
                const SizedBox(height: 20),
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

          // FOOTER: Bottone Azione (Solo se PENDING)
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const Icon(Icons.circle, size: 12, color: Color(0xFF0D0D1A)),
              Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
              const Icon(Icons.location_on, size: 14, color: Color(0xFF0D0D1A)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("RITIRO", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    Text(request.originAddress, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CONSEGNA", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    Text(request.destinationAddress, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
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
    if (request.load == null) return "N/A";
    final w = request.load!.weightKg;
    final wStr = w > 1000 ? "${(w / 1000).toStringAsFixed(1)}t" : "${w.toInt()}kg";
    return "${request.load!.loadType} • $wStr";
  }

  _StatusConfig _getStatusConfig(RequestStatus status) {
    switch (status) {
      case RequestStatus.PENDING:
        return _StatusConfig("IN ATTESA", Colors.orange.shade700, Icons.hourglass_empty);
      case RequestStatus.APPROVED:
        return _StatusConfig("IN LAVORAZIONE", Colors.blue.shade700, Icons.settings);
      case RequestStatus.PLANNED:
        return _StatusConfig("CONFERMATA", Colors.green.shade700, Icons.check_circle_outline);
      case RequestStatus.IN_PROGRESS:
        return _StatusConfig("IN VIAGGIO", Colors.purple.shade700, Icons.local_shipping);
      case RequestStatus.COMPLETED:
        return _StatusConfig("CONSEGNATA", Colors.grey.shade700, Icons.flag);
      case RequestStatus.REJECTED:
        return _StatusConfig("RIFIUTATA", Colors.red.shade700, Icons.cancel_outlined);
      case RequestStatus.CANCELLED:
        return _StatusConfig("ANNULLATA", Colors.red.shade300, Icons.block);
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

// Helper class per configurazione stato
class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig(this.label, this.color, this.icon);
}