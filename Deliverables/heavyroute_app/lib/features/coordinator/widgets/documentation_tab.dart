import 'package:flutter/material.dart';

class DocumentationTab extends StatelessWidget {
  const DocumentationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Documentazione e Permessi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Archivio digitale autorizzazioni, nulla osta e schede tecniche", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text("Carica Documento"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D0D1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Griglia di documenti recenti
          const Text("Documenti Recenti", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.count(
              crossAxisCount: 4, // 4 colonne
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5, // Rettangolari
              children: [
                _buildDocCard("Nulla Osta ANAS", "T-2026-0001", "PDF", Colors.red),
                _buildDocCard("Scheda Tecnica Veicolo", "VE-001-AB", "PDF", Colors.red),
                _buildDocCard("Piano di Viaggio", "T-2026-0001", "DOCX", Colors.blue),
                _buildDocCard("Assicurazione Carico", "Hitachi Rail", "PDF", Colors.red),
                _buildDocCard("Permesso Transito", "Prov. Bologna", "PDF", Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(String title, String subtitle, String ext, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(ext, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
              ),
              const Icon(Icons.more_vert, size: 16, color: Colors.grey),
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}