import 'package:flutter/material.dart';
import '../../models/create_request_model.dart';
import '../../services/request_service.dart';

/**
 * Schermata per la creazione di una nuova richiesta di trasporto.
 * Presenta un modulo validato per inserire indirizzi, data e specifiche tecniche del carico.
 * * @author Roman
 * @version 1.0
 */
class CreateRequestScreen extends StatefulWidget {
  /**
   * Costruttore per CreateRequestScreen.
   * * @param key Chiave univoca del widget.
   */
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

/**
 * Stato della schermata CreateRequestScreen.
 * Gestisce i controller del testo, la validazione del form e l'invio dei dati.
 */
class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();

  // Controller per i campi di testo
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _dateController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /**
   * Mostra il selettore di data e aggiorna il controller relativo.
   * * @param context Il contesto di build.
   */
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Formattazione YYYY-MM-DD come richiesto dal DTO
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  /**
   * Valida il form e invia la richiesta tramite il [RequestService].
   */
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final request = CreateRequestModel(
        origin: _originController.text,
        destination: _destController.text,
        pickupDate: _dateController.text,
        weight: double.parse(_weightController.text),
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        height: double.parse(_heightController.text),
        loadType: 'special',
      );

      try {
        // Supponiamo che createRequest restituisca un bool o un oggetto
        await _requestService.createRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Richiesta inviata con successo!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante l\'invio: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova Richiesta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Percorso'),
              _buildTextField(_originController, 'Indirizzo Origine', Icons.location_on),
              const SizedBox(height: 12),
              _buildTextField(_destController, 'Indirizzo Destinazione', Icons.flag),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data di Ritiro (YYYY-MM-DD)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
                validator: (value) => value!.isEmpty ? 'Seleziona una data' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Specifiche Carico'),
              _buildTextField(_weightController, 'Peso (t)', Icons.monitor_weight, isNumeric: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_lengthController, 'Lung. (m)', Icons.straighten, isNumeric: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_widthController, 'Larg. (m)', Icons.format_line_spacing, isNumeric: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_heightController, 'Alt. (m)', Icons.height, isNumeric: true)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('INVIA RICHIESTA', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Helper per costruire i campi di testo del form.
   */
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obbligatorio';
        if (isNumeric && double.tryParse(value) == null) return 'Inserisci un numero valido';
        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }
}