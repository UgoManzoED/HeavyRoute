import 'package:flutter/material.dart';

class DocumentationTab extends StatelessWidget {
  const DocumentationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Documentazione e Permessi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Gestisci autorizzazioni, nulla osta e certificati", style: TextStyle(color: Colors.grey)),
            ]),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Nuovo Documento"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white),
            )
          ]),
          const SizedBox(height: 24),
          // Tabella semplificata (simile alla precedente ma con colonne diverse)
          // ... (Codice tabella analogo a sopra, cambiando solo i dati) ...
          const Center(child: Text("Tabella Documenti (da implementare con dati reali)", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}