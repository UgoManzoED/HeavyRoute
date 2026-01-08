import 'package:flutter/material.dart';
import '../../models/request_dto.dart';
import '../../services/request_service.dart';

/**
 * Schermata principale della Dashboard che gestisce la visualizzazione e
 * l'aggiunta di nuovi ordini tramite un menu pop-up.
 * * @author Roman
 * @version 1.2
 */
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RequestService _requestService = RequestService();
  late Future<List<RequestCreationDTO>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _requestService.getMyRequests();
  }

  /**
   * Mostra il pop-up centrale per l'inserimento di un nuovo ordine.
   * Ricalca il layout a due colonne mostrato nel design di riferimento.
   * * @param context Il contesto di build necessario per mostrare il dialog.
   */
  void _showAddOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const NewOrderPopup(),
          ),
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          _requestsFuture = _requestService.getMyRequests();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Carichi')),
      body: FutureBuilder<List<RequestCreationDTO>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          // ... (logica del FutureBuilder come precedentemente implementata)
          return const Center(child: Text('Dati caricati'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrderDialog(context),
        label: const Text('Nuova Inserzione'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

/**
 * Widget interno che gestisce il form all'interno del pop-up.
 * Implementa la logica di validazione e invio dei dati.
 */
class NewOrderPopup extends StatefulWidget {
  const NewOrderPopup({super.key});

  @override
  State<NewOrderPopup> createState() => _NewOrderPopupState();
}

class _NewOrderPopupState extends State<NewOrderPopup> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();

  // Controller per i campi richiesti nell'immagine
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _weightController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  /**
   * Gestisce l'invio del form e chiude il pop-up in caso di successo.
   */
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final request = RequestCreationDTO(
        originAddress: _originController.text,
        destinationAddress: _destController.text,
        pickupDate: _dateController.text,
        weight: double.parse(_weightController.text),
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        height: 0.0, // Campo non presente nell'immagine, impostato a default
      );

      final success = await _requestService.createRequest(request);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aggiungi Nuovo Ordine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Text('Inserisci i dettagli della consegna speciale che vuoi richiedere.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // Riga 1: Origine e Destinazione
              Row(
                children: [
                  Expanded(child: _buildPopupField('Origine del carico *', _originController, 'Es. Milano, Via Roma 123')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPopupField('Destinazione del carico *', _destController, 'Es. Roma, Via del Corso 45')),
                ],
              ),
              const SizedBox(height: 16),

              // Riga 2: Tipologia e Quantità
              Row(
                children: [
                  Expanded(child: _buildDropdownField('Tipologia di carico *')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPopupField('Quantità *', _quantityController, 'Es. 1')),
                ],
              ),
              const SizedBox(height: 16),

              // Riga 3: Lunghezza e Larghezza
              Row(
                children: [
                  Expanded(child: _buildPopupField('Lunghezza (m) *', _lengthController, 'Es. 5.5')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPopupField('Larghezza (m) *', _widthController, 'Es. 2.5')),
                ],
              ),
              const SizedBox(height: 16),

              // Riga 4: Peso e Data
              Row(
                children: [
                  Expanded(child: _buildPopupField('Peso Totale (kg) *', _weightController, 'Es. 2500')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPopupField('Data di ritiro *', _dateController, 'Seleziona data', isReadOnly: true, onTap: () => _selectDate())),
                ],
              ),
              const SizedBox(height: 16),

              // Note Operative
              _buildPopupField('Note operative', _notesController, 'Inserisci eventuali note...', maxLines: 3),
              const SizedBox(height: 24),

              // Bottoni Azione
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A), // Colore scuro come immagine
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Conferma Ordine'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Helper per costruire i campi di testo del pop-up.
   */
  Widget _buildPopupField(String label, TextEditingController controller, String hint, {int maxLines = 1, bool isReadOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: isReadOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (v) => v!.isEmpty ? 'Richiesto' : null,
        ),
      ],
    );
  }

  /**
   * Helper per il campo dropdown della tipologia.
   */
  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          hint: const Text('Seleziona tipologia'),
          items: const [DropdownMenuItem(value: 'standard', child: Text('Standard'))],
          onChanged: (v) {},
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (picked != null) setState(() => _dateController.text = picked.toIso8601String().split('T')[0]);
  }
}