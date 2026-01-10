import 'package:flutter/material.dart';

class RoadConstraintsTab extends StatelessWidget {
  const RoadConstraintsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  Text("Mappa Vincoli e Cantieri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Segnalazioni attive sulla rete viaria nazionale", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_alert, size: 16),
                label: const Text("Nuova Segnalazione"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
              )
            ],
          ),

          const SizedBox(height: 24),

          // Intestazione
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("Tratta / Località", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text("Tipologia Vincolo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text("Validità", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text("Impatto", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text("", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), // Menu
              ],
            ),
          ),
          const Divider(),

          // Lista
          Expanded(
            child: ListView(
              children: [
                _buildConstraintRow(
                  location: "A14 Bologna-Taranto (km 150-155)",
                  type: "Restringimento Carreggiata",
                  date: "Fino al 30/03/2025",
                  impact: "Alto",
                  impactColor: Colors.red,
                ),
                _buildConstraintRow(
                  location: "SS45 bis Gardesana Occidentale",
                  type: "Limite Altezza 4.0m (Galleria)",
                  date: "Permanente",
                  impact: "Critico",
                  impactColor: Colors.purple,
                ),
                _buildConstraintRow(
                  location: "SP 11 Padana Superiore",
                  type: "Lavori Asfaltatura",
                  date: "15/01 - 18/01",
                  impact: "Medio",
                  impactColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintRow({
    required String location, required String type, required String date,
    required String impact, required Color impactColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: impactColor, width: 4)), // Bordo colorato a sinistra
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ])),
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey))),

          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: impactColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(impact,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          )),

          Expanded(flex: 1, child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.more_vert, size: 20, color: Colors.grey[400]),
          )),
        ],
      ),
    );
  }
}