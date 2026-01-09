import 'package:flutter/material.dart';

class AssignmentsTab extends StatelessWidget {
  const AssignmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assegnazioni Attive", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Visualizza e gestisci le assegnazioni di viaggio", style: TextStyle(color: Colors.grey[500], fontSize: 14)),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.near_me_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Nessuna assegnazione attiva al momento", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("Le assegnazioni completate appariranno qui", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}