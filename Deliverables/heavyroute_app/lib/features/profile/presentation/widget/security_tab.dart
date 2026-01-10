import 'package:flutter/material.dart';

class SecurityTab extends StatefulWidget {
  const SecurityTab({super.key});

  @override
  State<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Modifica Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Per la tua sicurezza, usa una password forte e non condividerla.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          _buildPasswordField("Password Attuale", _obscureCurrent, () {
            setState(() => _obscureCurrent = !_obscureCurrent);
          }),
          const SizedBox(height: 16),
          _buildPasswordField("Nuova Password", _obscureNew, () {
            setState(() => _obscureNew = !_obscureNew);
          }),
          const SizedBox(height: 16),
          _buildPasswordField("Conferma Nuova Password", _obscureNew, () {
            setState(() => _obscureNew = !_obscureNew);
          }),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Logica cambio password
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0D1A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Aggiorna Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: "••••••••",
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}