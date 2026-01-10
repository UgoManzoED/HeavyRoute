import 'package:flutter/material.dart';

class RegistrationRequestsTab extends StatelessWidget {
  const RegistrationRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Richieste di Registrazione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Approva o rifiuta le richieste di registrazione dei nuovi utenti", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Nome e Cognome")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Azienda")),
                  DataColumn(label: Text("Telefono")),
                  DataColumn(label: Text("P.IVA / Stato")),
                  DataColumn(label: Text("Data Reg.")),
                  DataColumn(label: Text("Azioni")),
                ],
                rows: [
                  _buildRegRow("REG-001", "Mario Verdi", "mario@logistics.it", "Verdi Logistics", "+39 340 1234", "IT123... (Approvata)", "2025-10-24", true),
                  _buildRegRow("REG-002", "Laura Gialli", "laura@transp.it", "Gialli Transport", "+39 345 9876", "IT987... (In verifica)", "2025-10-24", false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRegRow(String id, String name, String email, String company, String phone, String piva, String date, bool isApproved) {
    return DataRow(cells: [
      DataCell(Text(id)),
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(email)),
      DataCell(Text(company)),
      DataCell(Text(phone)),
      DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(piva.split('(')[0].trim()),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: isApproved ? Colors.black : Colors.grey[200], borderRadius: BorderRadius.circular(4)),
          child: Text(piva.split('(')[1].replaceAll(')', ''), style: TextStyle(fontSize: 10, color: isApproved ? Colors.white : Colors.black)),
        )
      ])),
      DataCell(Text(date)),
      DataCell(Row(children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, size: 20)),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white), child: const Text("Approva")),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text("Rifiuta")),
      ])),
    ]);
  }
}