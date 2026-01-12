import 'package:flutter/material.dart';

class DriverReportSheet extends StatefulWidget {
  const DriverReportSheet({super.key});

  @override
  State<DriverReportSheet> createState() => _DriverReportSheetState();
}

class _DriverReportSheetState extends State<DriverReportSheet> {
  String? _selectedIssue;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _issues = [
    "Traffico Intenso / Coda",
    "Incidente Stradale",
    "Guasto al Mezzo",
    "Problemi con il Carico",
    "Ritardo Cliente",
    "Meteo Avverso",
    "Altro"
  ];

  @override
  Widget build(BuildContext context) {
    // Gestione tastiera che copre i campi
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // Rimosso mainAxisSize da qui (era l'errore)
        child: Column(
          mainAxisSize: MainAxisSize.min, // <--- SPOSTATO QUI (CORRETTO)
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Rosso per attirare attenzione
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                ),
                const SizedBox(width: 16),
                const Text("Segnala Problema", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),

            // Dropdown Tipo Problema
            const Text("Tipologia *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIssue,
                  hint: const Text("Seleziona il tipo di problema"),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _issues.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _selectedIssue = val),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note aggiuntive
            const Text("Descrizione / Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Scrivi qui maggiori dettagli...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 24),

            // Bottone Invio
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Inviare segnalazione al backend
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Segnalazione inviata al coordinatore"), backgroundColor: Colors.red),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text("INVIA SEGNALAZIONE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F), // Rosso Material
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}