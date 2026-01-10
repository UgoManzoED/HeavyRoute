import 'package:flutter/material.dart';

/**
 * Dialog di modifica per un utente esistente.
 * <p>
 * Permette di visualizzare il riepilogo dell'utente e modificare
 * email, password o attributi specifici per il ruolo (es. Veicolo per autisti).
 * </p>
 */
class EditUserPopup extends StatelessWidget {
  const EditUserPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Modifica Utente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              _buildUserSummary(),
              const SizedBox(height: 24),
              const Text('Credenziali di Accesso', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSimpleField('Email *', 'luca.verdi@heavyroute.it'),
              const SizedBox(height: 16),
              _buildSimpleField('Nuova Password (opzionale)', 'Lascia vuoto per non modificare'),
              const SizedBox(height: 24),
              const Text('Attributi Autista', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSimpleField('Veicolo Assegnato', 'Furgone pesante')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSimpleField('Targa', 'IJ789KL')),
                ],
              ),
              const SizedBox(height: 32),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ID', style: TextStyle(fontSize: 10)), Text('USR-003', style: TextStyle(fontWeight: FontWeight.bold))]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Username', style: TextStyle(fontSize: 10)), Text('l.verdi', style: TextStyle(fontWeight: FontWeight.bold))]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nome', style: TextStyle(fontSize: 10)), Text('Luca Verdi', style: TextStyle(fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildSimpleField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
          child: const Text('Salva Modifiche'),
        ),
      ],
    );
  }
}