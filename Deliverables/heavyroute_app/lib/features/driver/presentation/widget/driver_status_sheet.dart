// In driver_status_sheet.dart
import 'package:flutter/material.dart';
import '../../service/drive_trip_service.dart'; // Assicurati che l'import sia corretto

class DriverStatusSheet extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const DriverStatusSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  final Map<String, String> _allStatusOptions = const {
    'Accetta Incarico': 'ACCEPTED',
    'In Viaggio': 'IN_TRANSIT',
    'In Pausa / Problema': 'PAUSED',
    'In Consegna': 'DELIVERING',
    'Consegnato': 'COMPLETED',
  };

  @override
  Widget build(BuildContext context) {
    // 1. Ottieni la lista degli stati validi futuri dal Service
    // Se lo stato corrente non esiste nella mappa, ritorna lista vuota (nessuna azione)
    final List<String> validNextStates = DriverTripService.allowedTransitions[currentStatus] ?? [];

    // 2. Filtra le opzioni visibili
    // Mostriamo solo le chiavi (Testo) il cui valore (Enum) è contenuto in validNextStates
    final visibleOptions = _allStatusOptions.entries
        .where((entry) => validNextStates.contains(entry.value))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Aggiorna Stato", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          if (visibleOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Nessuna azione disponibile per lo stato attuale."),
            )
          else
            ...visibleOptions.map((entry) {
              final label = entry.key;
              final enumValue = entry.value;

              return ListTile(
                title: Text(label),
                leading: const Icon(Icons.arrow_forward, color: Colors.blue), // Icona più sensata per "Azione"
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged(enumValue);
                },
              );
            }),
        ],
      ),
    );
  }
}