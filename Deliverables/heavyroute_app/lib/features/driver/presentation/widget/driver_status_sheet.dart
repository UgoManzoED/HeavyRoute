import 'package:flutter/material.dart';

class DriverStatusSheet extends StatefulWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const DriverStatusSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  State<DriverStatusSheet> createState() => _DriverStatusSheetState();
}

class _DriverStatusSheetState extends State<DriverStatusSheet> {
  // Lista degli stati possibili in ordine logico
  final List<String> _steps = [
    "Assegnato",
    "Inizio Viaggio",
    "Arrivo al Carico",
    "Carico Completato",
    "In Viaggio",
    "Arrivo allo Scarico",
    "Scarico Completato",
    "Fine Viaggio"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.75, // Occupa 75% dello schermo
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Aggiorna Stato", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Text("Seleziona lo stato attuale della spedizione", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Timeline Stati
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final bool isSelected = step == widget.currentStatus;
                final bool isPast = _steps.indexOf(widget.currentStatus) > index;

                return InkWell(
                  onTap: () {
                    widget.onStatusChanged(step);
                    Navigator.pop(context); // Chiude dopo la selezione
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D0D1A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Icona indicatore
                        Icon(
                          isSelected ? Icons.radio_button_checked : (isPast ? Icons.check_circle : Icons.radio_button_unchecked),
                          color: isSelected ? Colors.white : (isPast ? Colors.green : Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        // Testo
                        Text(
                          step,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                            child: const Text("ATTUALE", style: TextStyle(color: Colors.white, fontSize: 10)),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}