import 'package:flutter/material.dart';
import '../service/fleet_service.dart'; // Assicurati di aver creato questo file come discusso

class FleetTab extends StatefulWidget {
  const FleetTab({super.key});

  @override
  State<FleetTab> createState() => _FleetTabState();
}

class _FleetTabState extends State<FleetTab> {
  // Service per recuperare i dati dal backend
  final FleetService _fleetService = FleetService();

  // Future per gestire lo stato di caricamento
  late Future<List<dynamic>> _fleetDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Metodo per ricaricare i dati (utile per il tasto refresh)
  void _loadData() {
    setState(() {
      _fleetDataFuture = _fleetService.getFleetStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _fleetDataFuture,
          builder: (context, snapshot) {
            // 1. GESTIONE STATI DI CARICAMENTO
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text("Errore caricamento dati: ${snapshot.error}"),
                    TextButton(onPressed: _loadData, child: const Text("Riprova"))
                  ],
                ),
              ));
            }

            // Dati pronti (o lista vuota)
            final fleetData = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER CON REFRESH
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Monitoraggio Flotta", "Stato aggiornato in tempo reale"),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadData,
                      tooltip: "Aggiorna dati",
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- SEZIONE 1: GESTIONE MEZZI (Mockup Statico per ora) ---
                const Text("Gestione Mezzi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildVehiclesTable(), // Questa rimane statica come esempio

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 40),

                // --- SEZIONE 2: GESTIONE AUTISTI (DINAMICA) ---
                const Text("Gestione Autisti", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Visualizza lo stato operativo reale inviato dagli autisti", style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),

                // Passiamo i dati reali alla tabella
                _buildDriversTable(fleetData),

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 40),

                // --- SEZIONE 3: PARTNER ESTERNI (Mockup Statico) ---
                const Text("Partner Esterni", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPartnersTable(),
              ],
            );
          },
        ),
      ),
    );
  }




  // --- HELPER TITOLI ---
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
      ],
    );
  }

  // ===========================================================================
  // SEZIONE AUTISTI (Sistemata per vedere i dati reali)
  // ===========================================================================

  Widget _buildDriversTable(List<dynamic> data) {
    // 1. NON FILTRARE NULLA: Vediamo tutto quello che arriva dal backend
    // Se la lista è vuota, significa che il backend restituisce [] (0 elementi)
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200)
        ),
        child: const Column(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(height: 8),
            Text("Nessun viaggio trovato nel database."),
            Text("Assicurati di avere almeno un record nella tabella 'trips'.", style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text("ID Viaggio", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Autista Assegnato", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Stato Viaggio", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Veicolo", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: data.map((trip) => _buildDynamicDriverRow(trip)).toList(),
      ),
    );
  }

  DataRow _buildDynamicDriverRow(dynamic trip) {
    // 2. GESTIONE DEI DATI MANCANTI (NULL SAFETY)

    // ID Viaggio
    String tripId = "T-${trip['id']}";

    // Autista (Se null, mostriamo che manca)
    String driverInfo;
    bool hasDriver = trip['driverId'] != null;

    if (hasDriver) {
      String name = trip['driverName'] ?? "";
      String surname = trip['driverSurname'] ?? "";
      driverInfo = "$name $surname".trim();
      if (driverInfo.isEmpty) driverInfo = "Autista ID: ${trip['driverId']}";
    } else {
      driverInfo = "NON ASSEGNATO";
    }

    // Veicolo
    String vehicleInfo = trip['vehiclePlate'] ?? "-";

    // Stato
    String status = trip['status'] ?? "UNK";

    return DataRow(cells: [
      DataCell(Text(tripId, style: const TextStyle(fontWeight: FontWeight.bold))),

      // Cella Autista colorata se manca
      DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: hasDriver ? Colors.transparent : Colors.red.shade50,
                borderRadius: BorderRadius.circular(4)
            ),
            child: Row(
              children: [
                Icon(
                    hasDriver ? Icons.person : Icons.person_off,
                    size: 16,
                    color: hasDriver ? Colors.black54 : Colors.red
                ),
                const SizedBox(width: 8),
                Text(
                    driverInfo,
                    style: TextStyle(
                        fontWeight: hasDriver ? FontWeight.bold : FontWeight.normal,
                        color: hasDriver ? Colors.black : Colors.red
                    )
                ),
              ],
            ),
          )
      ),

      DataCell(_buildStatusBadge(status)),
      DataCell(Text(vehicleInfo)),
    ]);
  }
  // Badge Dinamico che colora in base allo stato ricevuto dall'API
  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey.shade200;
    Color text = Colors.black87;
    String label = status.replaceAll('_', ' ');

    // Logica colori sincronizzata con l'app Driver
    switch (status) {
      case "LIBERO":
      case "AVAILABLE":
        bg = const Color(0xFF0D0D1A);
        text = Colors.white;
        break;
      case "IN_VIAGGIO":
      case "IN_TRANSIT":
        bg = Colors.blue.shade100;
        text = Colors.blue.shade900;
        break;
      case "CARICO_COMPLETATO":
      case "ARRIVO_SCARICO":
        bg = Colors.orange.shade100;
        text = Colors.orange.shade900;
        break;
      case "SCARICO_COMPLETATO":
      case "COMPLETATO":
        bg = Colors.green.shade100;
        text = Colors.green.shade900;
        break;
      case "RIPOSO":
      case "MAINTENANCE":
        bg = Colors.red.shade100;
        text = Colors.red.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // ===========================================================================
  // SEZIONI STATICHE (Per completezza UI)
  // ===========================================================================

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
        ],
        rows: [
          _vehicleRow("VEH-001", "AB123CD", "Bilico 40 ton", "40 ton", "Libero"),
          _vehicleRow("VEH-002", "EF456GH", "Bisarca", "25 ton", "In Viaggio"),
          _vehicleRow("VEH-003", "IJ789KL", "Furgone", "5 ton", "Manutenzione"),
        ],
      ),
    );
  }

  DataRow _vehicleRow(String id, String plate, String type, String cap, String status) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(plate)),
      DataCell(Text(type)),
      DataCell(Text(cap)),
      DataCell(_buildStatusBadge(status.toUpperCase().replaceAll(' ', '_'))),
    ]);
  }

  Widget _buildPartnersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text("Azienda", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Referente", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Specializzazione", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          _partnerRow("Trasporti Veloci S.r.l.", "Marco Bianchi", "Carichi eccezionali", "4.5"),
          _partnerRow("Euro Transport Group", "Laura Verdi", "Merci pericolose", "4.8"),
        ],
      ),
    );
  }

  DataRow _partnerRow(String company, String ref, String spec, String rating) {
    return DataRow(cells: [
      DataCell(Row(children: [const Icon(Icons.business, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(company)])),
      DataCell(Text(ref)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
        child: Text(spec, style: const TextStyle(fontSize: 10)),
      )),
      DataCell(Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text(rating)])),
    ]);
  }
}