import 'package:flutter/material.dart';

/// Widget atomico per l'input di testo.
/// <p>
/// Standardizza lo stile dei form in tutta l'applicazione (registrazione, login, profili).
/// Gestisce automaticamente il layout "Label sopra Input" e la visualizzazione degli errori.
/// </p>
class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Etichetta
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        // 2. Campo di Input
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          // 3. Stile e Decorazione
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            // Gestione Errore
            errorText: errorText,
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          // 4. Validazione
          validator: (value) {
            if (label.contains('*') && (value == null || value.trim().isEmpty)) {
              return 'Campo obbligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }
}