import 'package:flutter/material.dart';
import '../../models/request_detail_dto.dart';
import 'request_action_popup.dart';

/**
 * Widget grafico per mostrare una singola richiesta nella lista della Dashboard.
 * <p>
 * Visualizza lo stato della spedizione, i dettagli del percorso, il peso e
 * fornisce l'accesso alle azioni di modifica o annullamento.
 * </p>
 * @author Roman
 * @version 1.0
 */
class RequestCard extends StatelessWidget {
  /** I dati di dettaglio della richiesta da visualizzare. */
  final RequestDetailDTO request;

  /**
   * Costruttore della classe {@link RequestCard}.
   * @param key Chiave univoca del widget.
   * @param request L'oggetto DTO contenente i dati della richiesta.
   */
  const RequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 24,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ordine',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.location_on_outlined,
            request.originAddress,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.location_on_outlined,
            request.destinationAddress,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.monitor_weight_outlined,
            'Peso: ${request.weight} ton',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            request.pickupDate,
          ),
          const SizedBox(height: 20),

          // PULSANTE AZIONE
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              // MODIFICA: Invocazione del metodo per aprire il popup
              onPressed: () => _openRequestActionDialog(context, request),
              icon: const Icon(Icons.edit_note, size: 20, color: Colors.black87),
              label: const Text(
                'Richiedi Modifica o Annullamento',
                style: TextStyle(color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Costruisce il badge dello stato con colore appropriato.
   * @return Un Widget Container formattato come chip.
   */
  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /**
   * Costruisce una riga di informazione con icona e testo.
   * @param icon L'icona da visualizzare.
   * @param text Il testo descrittivo.
   * @return Un Widget Row contenente icona e testo.
   */
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /**
   * Determina il colore primario in base allo stato della richiesta.
   * @param status Lo stato corrente della richiesta.
   * @return Un oggetto {@link Color}.
   */
  Color _getStatusColor(RequestStatus? status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.inTransit:
        return Colors.blue;
      case RequestStatus.completed:
        return Colors.grey;
      default:
        return const Color(0xFF0D0D1A);
    }
  }

  /**
   * Apre il dialog per richiedere modifiche o annullamenti di un ordine.
   * <p>
   * Utilizza {@link showDialog} per visualizzare il widget {@link RequestActionPopup}.
   * </p>
   * @param context Il contesto di navigazione corrente.
   * @param request L'ordine selezionato dall'utente.
   */
  void _openRequestActionDialog(BuildContext context, RequestDetailDTO request) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RequestActionPopup(request: request),
    );
  }

  /**
   * Traduce l'enum dello stato in una stringa leggibile dall'utente.
   * @param status Lo stato della richiesta.
   * @return Una stringa localizzata.
   */
  String _getStatusText(RequestStatus? status) {
    switch (status) {
      case RequestStatus.pending:
        return 'In Attesa';
      case RequestStatus.approved:
        return 'Approvato';
      case RequestStatus.rejected:
        return 'Rifiutato';
      case RequestStatus.inTransit:
        return 'In Transito';
      case RequestStatus.completed:
        return 'Completato';
      default:
        return 'Sconosciuto';
    }
  }
}