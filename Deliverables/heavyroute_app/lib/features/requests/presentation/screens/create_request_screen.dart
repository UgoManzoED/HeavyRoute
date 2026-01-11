import 'package:flutter/material.dart';
import '../../models/dto/create_request_model.dart';
import '../../services/request_service.dart';

/**
 * Schermata per la creazione di una nuova richiesta di trasporto.
 */
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();

  // Controller
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  // Controller per il tipo di carico
  final _typeController = TextEditingController(text: "Generico");

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _dateController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Formato ISO YYYY-MM-DD
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  /**
   * Crea la struttura PIATTA richiesta dal Backend.
   */
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {

      try {
        final request = CreateRequestModel(
          originAddress: _originController.text,
          destinationAddress: _destController.text,
          pickupDate: _dateController.text,

          loadType: _typeController.text.isNotEmpty ? _typeController.text : 'Special',
          description: "Carico standard",
          weight: double.parse(_weightController.text),
          length: double.parse(_lengthController.text),
          width: double.parse(_widthController.text),
          height: double.parse(_heightController.text),
        );

        // Invio
        final success = await _requestService.createRequest(request);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Richiesta inviata con successo!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Errore: Il server ha rifiutato la richiesta'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Eccezione invio: $e'), backgroundColor: Colors.red),
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
              _buildTextField(_typeController, 'Tipo Merce', Icons.category),
              const SizedBox(height: 12),
              _buildTextField(_weightController, 'Peso (kg)', Icons.monitor_weight, isNumeric: true),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF0D0D1A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('INVIA RICHIESTA', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

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