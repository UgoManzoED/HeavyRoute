import 'package:flutter/material.dart';
import '../../../auth/models/user_dto.dart';

class CompanyDataTab extends StatelessWidget {
  final UserDTO user;

  const CompanyDataTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildReadOnlyField("Nome Azienda", user.company ?? "Non specificato"),
          const SizedBox(height: 16),
          _buildReadOnlyField("Partita IVA", user.vat ?? "Non specificata"),
        ],
      ),
    );
  }

  // (Usa lo stesso helper _buildReadOnlyField di sopra o crea un widget condiviso)
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