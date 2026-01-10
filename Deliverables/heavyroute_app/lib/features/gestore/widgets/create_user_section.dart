import 'package:flutter/material.dart';

/**
 * Sezione per l'inserimento di un nuovo account per il personale interno.
 * <p>
 * Presenta un form strutturato per raccogliere dati anagrafici e di contatto,
 * con un pulsante finale per la generazione automatica delle credenziali.
 * </p>
 */
class CreateUserSection extends StatelessWidget {
  const CreateUserSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crea Nuovo Utente Interno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Inserisci i dati per creare un nuovo account per il personale interno', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const Text('Dati Anagrafici e di Contatto', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildFormGrid(),
          const SizedBox(height: 32),
          _buildInfoBox(),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Text('Crea Utente e Invia Credenziali'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64748B), foregroundColor: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildField('Username *', 'es. m.rossi', 300),
        _buildField('Ruolo *', 'Seleziona ruolo..', 300, isDropdown: true),
        _buildField('Nome *', 'Mario', 300),
        _buildField('Cognome *', 'Rossi', 300),
        _buildField('Email *', 'mario.rossi@heavyroute.it', 300),
        _buildField('Telefono', '+39 340 1234567', 300),
      ],
    );
  }

  Widget _buildField(String label, String hint, double width, {bool isDropdown = false}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down) : null,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
      child: const Text(
        'Nota: Dopo la creazione, verranno inviate automaticamente le credenziali temporanee all\'indirizzo email specificato.',
        style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13),
      ),
    );
  }
}