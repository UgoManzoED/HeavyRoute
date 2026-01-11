import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa intl per le date
import '../../../../common/models/enums.dart'; // <--- Usa il nuovo model
import 'request_action_popup.dart';
import '../../models/transport_request.dart';

class RequestCard extends StatelessWidget {
  // Usa TransportRequest invece di RequestDetailDTO
  final TransportRequest request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // Formatter per la data
    final String formattedDate = DateFormat('dd/MM/yyyy').format(request.pickupDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_outlined, size: 24, color: Color(0xFF374151)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ordine #${request.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(), // Badge aggiornato
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.location_on_outlined, request.originAddress),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.location_on_outlined, request.destinationAddress),
          const SizedBox(height: 10),
          // ACCESSO AI DATI ANNIDATI (LoadDetails)
          // Assumiamo che request.load abbia un campo 'weight' o 'description'
          _buildInfoRow(Icons.monitor_weight_outlined, 'Dettagli carico: ${request.load.toString()}'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.calendar_today_outlined, formattedDate),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openRequestActionDialog(context),
              icon: const Icon(Icons.edit_note, size: 20, color: Colors.black87),
              label: const Text('Richiedi Modifica', style: TextStyle(color: Colors.black87)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    // Nota: Accesso a request.requestStatus invece di request.status
    final statusColor = _getStatusColor(request.requestStatus);
    final statusText = _getStatusText(request.requestStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
      child: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.PENDING: return Colors.orange;
      case RequestStatus.APPROVED: return Colors.green;
      case RequestStatus.REJECTED: return Colors.red;
      case RequestStatus.COMPLETED: return Colors.grey;
      default: return const Color(0xFF0D0D1A);
    }
  }

  String _getStatusText(RequestStatus status) {
    // Puoi personalizzare le stringhe o usare .name
    return status.name.toUpperCase();
  }

  void _openRequestActionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // Passiamo TransportRequest al popup (dovrai aggiornare anche il popup se necessario)
      builder: (context) => RequestActionPopup(request: request),
    );
  }
}