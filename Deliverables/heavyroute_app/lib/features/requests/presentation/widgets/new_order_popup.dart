import 'package:flutter/material.dart';
import '../../models/create_request_model.dart';
import '../../services/request_service.dart';
import '../../../auth/services/user_service.dart';

/**
 * Widget del Form Pop-up per la creazione di un nuovo ordine.
 * <p>
 * Questa classe gestisce l'intero ciclo di vita dell'inserimento:
 * dalla validazione dei campi alla persistenza tramite il backend.
 * </p>
 * @author Roman
 */
class NewOrderPopup extends StatefulWidget {
  const NewOrderPopup({super.key});

  @override
  State<NewOrderPopup> createState() => _NewOrderPopupState();
}

class _NewOrderPopupState extends State<NewOrderPopup> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();
  final UserService _userService = UserService();

  // Controller per i campi di testo
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _quantCtrl = TextEditingController();
  final _lenCtrl = TextEditingController();
  final _widCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  /**
   * Gestisce il salvataggio della richiesta.
   * <p>
   * Recupera l'utente loggato, valida il form e invia il DTO al service.
   * Restituisce 'true' al Navigator se l'operazione ha successo.
   * </p>
   */
  void _handleConfirm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = await _userService.getCurrentUser();
        if (currentUser == null || currentUser.id == null) return;

        final int userId = int.parse(currentUser.id as String);

        final dto = CreateRequestModel(
          origin: _originCtrl.text.trim(),
          destination: _destCtrl.text.trim(),
          pickupDate: _dateCtrl.text,
          weight: double.tryParse(_weightCtrl.text) ?? 0.0,
          length: double.tryParse(_lenCtrl.text) ?? 0.0,
          width: double.tryParse(_widCtrl.text) ?? 0.0,
          height: double.tryParse(_heightCtrl.text) ?? 0.0,
          loadType: 'speciale',
        );

        final success = await _requestService.createRequest(dto);
        if (success && mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint("Errore durante la creazione: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              // Righe del Form
              Row(
                children: [
                  Expanded(child: _buildInput('Origine del carico *', 'Es. Milano', _originCtrl)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Destinazione *', 'Es. Roma', _destCtrl)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildDropdown('Tipologia di carico *')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Quantità *', 'Es. 1', _quantCtrl, isNum: true)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildInput('Lunghezza (m) *', 'Es. 12.0', _lenCtrl, isNum: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Larghezza (m) *', 'Es. 2.5', _widCtrl, isNum: true)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildInput('Altezza (m) *', 'Es. 4.0', _heightCtrl, isNum: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Peso Totale (kg) *', 'Es. 35000', _weightCtrl, isNum: true)),
                ],
              ),
              const SizedBox(height: 20),

              _buildInput('Data di ritiro *', 'Seleziona data', _dateCtrl, isDate: true),
              const SizedBox(height: 20),

              _buildInput('Note operative', 'Note aggiuntive...', _noteCtrl, maxLines: 3),
              const SizedBox(height: 40),

              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /** Costruisce l'intestazione del popup. */
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Aggiungi Nuovo Ordine', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ],
    );
  }

  /** Costruisce i pulsanti di azione. */
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla', style: TextStyle(color: Colors.black87)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D0D1A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Conferma Ordine'),
        ),
      ],
    );
  }

  /** Helper per la creazione dei campi di input. */
  Widget _buildInput(String label, String hint, TextEditingController ctrl, {int maxLines = 1, bool isDate = false, bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          readOnly: isDate,
          onTap: isDate ? _showPicker : null,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) => v!.isEmpty && label.contains('*') ? 'Richiesto' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          items: const [DropdownMenuItem(value: 'eco', child: Text('Trasporto Eccezionale'))],
          onChanged: (v) {},
        ),
      ],
    );
  }

  Future<void> _showPicker() async {
    final DateTime? d = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030)
    );
    if (d != null) setState(() => _dateCtrl.text = d.toIso8601String().split('T')[0]);
  }
}