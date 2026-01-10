import 'package:flutter/material.dart';

/**
 * Sezione superiore della Dashboard per l'attivazione della creazione ordine.
 * @author Roman
 */
class AddOrderHeader extends StatelessWidget {
  final VoidCallback onAddTap;

  const AddOrderHeader({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddTap,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF0D0D1A), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Aggiungi Nuovo Ordine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Richiedi una nuova consegna speciale', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
        ],
      ),
    );
  }
}