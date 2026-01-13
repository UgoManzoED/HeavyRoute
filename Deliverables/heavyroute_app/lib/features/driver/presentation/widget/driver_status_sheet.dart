import 'package:flutter/material.dart';

class DriverStatusSheet extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const DriverStatusSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  // Mappa: Testo Visibile -> Valore Enum Backend
  final Map<String, String> _statusOptions = const {
    'Presa in Carico': 'ASSIGNED',
    'Al Ritiro': 'ARRIVED_PICKUP',
    'Carico Completato': 'LOADED',
    'In Viaggio': 'IN_TRANSIT',
    'Alla Consegna': 'ARRIVED_DESTINATION',
    'Consegnato': 'COMPLETED',
  };

  @override
  Widget build(BuildContext context) {
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

          // Genera la lista delle opzioni
          ..._statusOptions.entries.map((entry) {
            final label = entry.key;
            final enumValue = entry.value;
            final isSelected = currentStatus == enumValue;

            return ListTile(
              title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              onTap: () {
                Navigator.pop(context); // Chiude il foglio
                if (!isSelected) {
                  onStatusChanged(enumValue); // Passa il valore ENUM (es. IN_TRANSIT)
                }
              },
            );
          }),
        ],
      ),
    );
  }
}