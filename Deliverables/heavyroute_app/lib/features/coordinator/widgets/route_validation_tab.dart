import 'package:flutter/material.dart';

class RouteValidationTab extends StatelessWidget {
  const RouteValidationTab({super.key});

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
          // Header Sezione
          const Text("Proposte di Percorso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Valida, approva o modifica i percorsi proposti dal Pianificatore",
              style: TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 24),

          // Intestazione Tabella
          _buildTableHeader(),
          const Divider(),

          // Lista Righe (Mockup statico per ora)
          Expanded(
            child: ListView(
              children: [
                _buildRouteRow(
                    id: "ROUTE-001", order: "ORD-045", planner: "Mario Bianchi",
                    origin: "Milano - Via Tortona 15", dest: "Roma - Via Appia Nuova 234",
                    route: "A1 Milano-Roma (via Bologna)", details: "575 km • 6h 30min",
                    type: "Carico eccezionale - Macchinario", status: "In Attesa",
                    isPending: true
                ),
                _buildRouteRow(
                    id: "ROUTE-002", order: "ORD-051", planner: "Mario Bianchi",
                    origin: "Torino - Corso Francia", dest: "Napoli - Via Argine",
                    route: "A21 Torino-Piacenza...", details: "760 km • 8h 15min",
                    type: "Materiale ADR", status: "In Attesa",
                    isPending: true
                ),
                _buildRouteRow(
                    id: "ROUTE-003", order: "ORD-038", planner: "Mario Bianchi",
                    origin: "Genova - Via Milano", dest: "Bari - SS 16 km 45",
                    route: "A26 Genova-Alessandria...", details: "890 km • 9h 45min",
                    type: "Container 40 piedi", status: "Approvato",
                    isPending: false
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Origine - Destinazione", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 3, child: Text("Percorso Proposto", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Tipologia", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 1, child: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildRouteRow({
    required String id, required String order, required String planner,
    required String origin, required String dest, required String route,
    required String details, required String type, required String status,
    required bool isPending,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFFBEB) : Colors.white, // Giallo paglierino se in attesa
        borderRadius: BorderRadius.circular(8),
        border: isPending ? Border.all(color: Colors.orange.shade100) : null,
      ),
      child: Row(
        children: [
          // ID e Planner
          Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(order, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Text(planner, style: const TextStyle(fontSize: 11)),
          ])),

          // Origine / Dest
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLocationRow(Icons.my_location, origin),
            const SizedBox(height: 4),
            _buildLocationRow(Icons.location_on, dest),
          ])),

          // Percorso
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(route, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(details, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),

          // Tipologia
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 13))),

          // Stato
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPending ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: isPending ? Border.all(color: Colors.grey.shade300) : null,
            ),
            child: Text(status,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.black : Colors.white
                )
            ),
          )),

          // Azioni
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: isPending ? [
              _buildActionButton("Valida", Colors.black, Colors.white, Icons.check_circle_outline),
              const SizedBox(width: 8),
              _buildActionButton("Rifiuta", Colors.red, Colors.white, Icons.cancel_outlined),
            ] : [
              const Text("Elaborato", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 12, color: Colors.grey),
      const SizedBox(width: 4),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))
    ]);
  }

  Widget _buildActionButton(String label, Color bg, Color fg, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14, color: fg),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}