import 'package:flutter/material.dart';

class RoadConstraintsTab extends StatelessWidget {
  const RoadConstraintsTab({super.key});

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
                  Text("Mappa Vincoli e Cantieri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Segnalazioni attive sulla rete viaria nazionale (ANAS / Autostrade)", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )
            ],
          ),

          const SizedBox(height: 24),

          // Intestazione
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text("TRATTA / LOCALITÀ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 2, child: Text("TIPOLOGIA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 2, child: Text("VALIDITÀ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 1, child: Text("IMPATTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                Expanded(flex: 1, child: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))), // Menu
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: ListView(
              children: [
                _buildConstraintRow(
                  location: "A1 Milano-Napoli (Tratto Appenninico)",
                  type: "Restringimento Carreggiata",
                  icon: Icons.compress,
                  date: "Fino al 30/03/2026",
                  impact: "ALTO",
                  impactColor: Colors.orange,
                ),
                _buildConstraintRow(
                  location: "SS45 bis Gardesana Occidentale",
                  type: "Limite Altezza 4.0m (Galleria)",
                  icon: Icons.vertical_align_center,
                  date: "Permanente",
                  impact: "CRITICO",
                  impactColor: Colors.red,
                ),
                _buildConstraintRow(
                  location: "SP 11 Padana Superiore",
                  type: "Lavori Asfaltatura",
                  icon: Icons.construction,
                  date: "15/01 - 18/01",
                  impact: "MEDIO",
                  impactColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintRow({
    required String location, required String type, required IconData icon, required String date,
    required String impact, required Color impactColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        // Indicatore laterale colorato
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: IntrinsicHeight( // Serve per la linea verticale decorativa
        child: Row(
          children: [
            Container(width: 4, color: impactColor, margin: const EdgeInsets.only(right: 12)),
            Expanded(flex: 3, child: Row(children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            ])),
            Expanded(flex: 2, child: Row(children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(type, style: const TextStyle(fontSize: 13)),
            ])),
            Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey))),

            Expanded(flex: 1, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: impactColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(impact, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: impactColor)),
            )),

            Expanded(flex: 1, child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey), onPressed: (){}),
            )),
          ],
        ),
      ),
    );
  }
}