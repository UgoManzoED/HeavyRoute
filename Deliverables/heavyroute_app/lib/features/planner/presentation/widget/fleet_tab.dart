import 'package:flutter/material.dart';

class FleetTab extends StatelessWidget {
  const FleetTab({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView principale per scorrere verticalmente le 3 sezioni
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEZIONE 1: GESTIONE MEZZI
            _buildSectionTitle("Gestione Mezzi", "Visualizza lo stato di tutti i mezzi della flotta"),
            const SizedBox(height: 16),
            _buildVehiclesTable(),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),

            // SEZIONE 2: GESTIONE AUTISTI
            _buildSectionTitle("Gestione Autisti", "Visualizza lo stato di tutti gli autisti disponibili"),
            const SizedBox(height: 16),
            _buildDriversTable(),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),

            // SEZIONE 3: PARTNER ESTERNI
            _buildSectionTitle("Partner Esterni", "Gestisci i partner di trasporto esterni e assegna risorse ai viaggi"),
            const SizedBox(height: 16),
            _buildPartnersTable(),
          ],
        ),
      ),
    );
  }

  // --- HELPER PER I TITOLI ---
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
      ],
    );
  }

  // --- TABELLA 1: MEZZI ---
  Widget _buildVehiclesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 30,
        headingRowColor: WidgetStateProperty.all(Colors.transparent),
        columns: const [
          DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Targa", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Capacità", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Posizione", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Ultimo Aggiornamento", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          _vehicleRow("VEH-001", "AB123CD", "Bilico 40 ton", "40 ton", "Libero", "Milano - Deposito Centrale", "10 min fa"),
          _vehicleRow("VEH-002", "EF456GH", "Bisarca", "25 ton", "In Viaggio", "A1 Milano-Bologna, km 127", "2 min fa"),
          _vehicleRow("VEH-003", "IJ789KL", "Furgone pesante", "5 ton", "Manutenzione", "Officina Partner - Torino", "1 ora fa"),
          _vehicleRow("VEH-004", "MN012OP", "Bilico 44 ton", "44 ton", "Libero", "Roma - Hub Sud", "5 min fa"),
        ],
      ),
    );
  }

  DataRow _vehicleRow(String id, String plate, String type, String cap, String status, String pos, String time) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(plate)),
      DataCell(Text(type)),
      DataCell(Text(cap)),
      DataCell(_buildStatusBadge(status)),
      DataCell(Row(children: [Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]), const SizedBox(width: 4), Text(pos)])),
      DataCell(Text(time, style: const TextStyle(color: Colors.blue))),
    ]);
  }

  // --- TABELLA 2: AUTISTI ---
  Widget _buildDriversTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 30,
        columns: const [
          DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Nome", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Cognome", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Abilitazioni", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Posizione", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Ore Guida", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          _driverRow("DRV-001", "Marco", "Rossi", ["ADR", "Carichi Eccezionali", "Merci Pericolose"], "Libero", "Milano - Deposito Centrale", "2h/9h"),
          _driverRow("DRV-002", "Giuseppe", "Bianchi", ["ADR", "Carichi Eccezionali"], "In Viaggio", "A1 Milano-Bologna, km 127", "6h/9h"),
          _driverRow("DRV-003", "Luca", "Verdi", ["Standard"], "Riposo", "Torino - Area Rest", "9h/9h"),
          _driverRow("DRV-004", "Andrea", "Neri", ["ADR", "Merci Pericolose"], "Libero", "Roma - Hub Sud", "1h/9h"),
        ],
      ),
    );
  }

  DataRow _driverRow(String id, String name, String surname, List<String> tags, String status, String pos, String hours) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(name)),
      DataCell(Text(surname)),
      DataCell(Row(children: tags.map((t) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
        child: Text(t, style: const TextStyle(fontSize: 10)),
      )).toList())),
      DataCell(_buildStatusBadge(status)),
      DataCell(Row(children: [Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]), const SizedBox(width: 4), Text(pos)])),
      DataCell(Row(children: [Icon(Icons.schedule, size: 16, color: Colors.grey[600]), const SizedBox(width: 4), Text(hours)])),
    ]);
  }

  // --- TABELLA 3: PARTNER ESTERNI ---
  Widget _buildPartnersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Nome Azienda", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Referente", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Contatti", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Specializzazione", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Flotta Disp.", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Valutazione", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          _partnerRow("EXT-001", "Trasporti Veloci S.r.l.", "Marco Bianchi", "+39 02 1234567", ["Carichi eccezionali", "ADR"], "8 mezzi", "4.5"),
          _partnerRow("EXT-002", "Euro Transport Group", "Laura Verdi", "+39 06 7654321", ["Merci pericolose", "Temp. controllata"], "15 mezzi", "4.8"),
          _partnerRow("EXT-003", "Nord-Sud Logistics", "Giuseppe Rossi", "+39 011 9876543", ["Standard", "Carichi eccezionali"], "12 mezzi", "4.2"),
          _partnerRow("EXT-004", "Mediterranean Freight", "Sofia Marini", "+39 081 5551234", ["Container", "Merci varie"], "6 mezzi", "4.0"),
        ],
      ),
    );
  }

  DataRow _partnerRow(String id, String company, String ref, String phone, List<String> specs, String fleet, String rating) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Row(children: [const Icon(Icons.business, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(company)])),
      DataCell(Text(ref)),
      DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [const Icon(Icons.phone, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(phone, style: const TextStyle(fontSize: 12))]),
        Row(children: [const Icon(Icons.email, size: 12, color: Colors.grey), const SizedBox(width: 4), Text("email@test.it", style: const TextStyle(fontSize: 12))]),
      ])),
      DataCell(Row(children: specs.take(2).map((t) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
        child: Text(t, style: const TextStyle(fontSize: 10)),
      )).toList())),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Text(fleet, style: const TextStyle(fontSize: 12)),
      )),
      DataCell(Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text("$rating/5")])),
      DataCell(OutlinedButton.icon(
        onPressed: (){},
        icon: const Icon(Icons.chat_bubble_outline, size: 14),
        label: const Text("Contatta", style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
      )),
    ]);
  }

  // --- HELPER COMUNE PER I BADGE DI STATO ---
  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey.shade200;
    Color text = Colors.black87;

    if (status == "Libero" || status == "Disponibile") {
      bg = const Color(0xFF0D0D1A);
      text = Colors.white;
    } else if (status == "Manutenzione" || status == "Riposo") {
      bg = const Color(0xFFDC2626); // Rosso
      text = Colors.white;
    } else if (status == "In Viaggio") {
      bg = const Color(0xFFE5E7EB);
      text = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}