import 'package:flutter/material.dart';
import '../../../auth/models/user_dto.dart';

class PersonalDataTab extends StatelessWidget {
  final UserDTO user; // Riceviamo i dati

  const PersonalDataTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Esempio di visualizzazione dati (Puoi sostituire con TextFormFields)
          _buildReadOnlyField("Nome", user.firstName),
          const SizedBox(height: 16),
          _buildReadOnlyField("Cognome", user.lastName),
          const SizedBox(height: 16),
          _buildReadOnlyField("Email", user.email),
          const SizedBox(height: 16),
          _buildReadOnlyField("Telefono", user.phone ?? "Non specificato"),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Text(value ?? "-", style: const TextStyle(fontSize: 16)),
        )
      ],
    );
  }
}