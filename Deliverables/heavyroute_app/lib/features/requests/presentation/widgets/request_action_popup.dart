import 'package:flutter/material.dart';
import '../../models/transport_request.dart';

/**
 * Popup per la richiesta di modifica o annullamento di un ordine esistente.
 * <p>
 * Questa versione ignora l'ID ordine e lo stato, mostrando solo l'indirizzo
 * di destinazione per identificare la spedizione.
 * </p>
 * @author Roman
 */
class RequestActionPopup extends StatefulWidget {
  /** Il DTO della richiesta contenente i dati necessari. */
  final TransportRequest request;

  /**
   * Costruttore del popup.
   * @param request L'oggetto {@link RequestDetailDTO} da cui estrarre l'indirizzo.
   */
  const RequestActionPopup({super.key, required this.request});

  @override
  State<RequestActionPopup> createState() => _RequestActionPopupState();
}

class _RequestActionPopupState extends State<RequestActionPopup> {
  final _formKey = GlobalKey<FormState>();
  String _requestType = 'Richiesta di Modifica';
  final TextEditingController _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildOrderSummaryCard(),
                const SizedBox(height: 16),
                _buildWarningBox(),
                const SizedBox(height: 24),
                _buildRequestTypeDropdown(),
                const SizedBox(height: 24),
                _buildDetailsField(),
                const SizedBox(height: 32),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /**
   * Costruisce l'intestazione del popup.
   */
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Richiedi Modifica o Annullamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Invia una nota al team logistico per questo ordine',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 20),
        ),
      ],
    );
  }

  /**
   * Costruisce la card di riepilogo semplificata.
   * <p>
   * Visualizza l'icona del pacco e l'indirizzo di consegna estratto dal DTO.
   * </p>
   */
  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Destinazione Consegna',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  widget.request.destinationAddress,
                  style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Box informativo per l'utente riguardo i tempi di valutazione.
   */
  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'La richiesta verrà valutata dal team logistico. Verrai contattato per confermare le modifiche o l\'annullamento.',
              style: TextStyle(color: Color(0xFF92400E), fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Dropdown per la selezione del tipo di operazione.
   */
  Widget _buildRequestTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo di Richiesta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _requestType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          items: ['Richiesta di Modifica', 'Annullamento Ordine']
              .map((label) => DropdownMenuItem(value: label, child: Text(label, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => _requestType = val!),
        ),
      ],
    );
  }

  /**
   * Campo di testo per l'inserimento dei dettagli descrittivi.
   */
  Widget _buildDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dettagli della Richiesta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _detailsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Es. Variazione data di ritiro, cambio contatto di scarico...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  /**
   * Pulsanti di azione per annullare o inviare il form.
   */
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Annulla', style: TextStyle(color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(_requestType == 'Annullamento Ordine' ? 'Invia Annullamento' : 'Invia Modifica'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7280),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}