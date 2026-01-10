import 'package:flutter/material.dart';
import '../../../../features/requests/models/request_detail_dto.dart';
import '../../../../features/requests/services/request_service.dart';
import '../../../../features/trips/services/trip_service.dart';

/**
 * Tabella interattiva per la gestione delle Richieste di Trasporto.
 * <p>
 * Questa vista permette al Pianificatore di:
 * 1. Vedere tutte le richieste (PENDING, APPROVED, REJECTED).
 * 2. Approvare una richiesta PENDING (creando un Trip).
 * </p>
 */
class TransportRequestsTab extends StatefulWidget {
  const TransportRequestsTab({super.key});

  @override
  State<TransportRequestsTab> createState() => _TransportRequestsTabState();
}

class _TransportRequestsTabState extends State<TransportRequestsTab> {
  // Dependency Injection: Istanziamo i servizi necessari
  final RequestService _requestService = RequestService();
  final TripService _tripService = TripService();

  // Variabile di stato per il FutureBuilder.
  late Future<List<RequestDetailDTO>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadData(); // Primo caricamento all'apertura del tab
  }

  /// Inizializza o Ricarica i dati dal backend.
  /// Chiamare setState qui forza il FutureBuilder a ripartire dallo stato 'waiting'.
  void _loadData() {
    setState(() {
      _requestsFuture = _requestService.getAllRequests();
    });
  }

  /// Logica di Approvazione (Command).
  ///
  /// @param id L'ID della richiesta da approvare.
  Future<void> _approveRequest(int id) async {
    // 1. Chiamata al Service (Operazione bloccante asincrona)
    final success = await _tripService.approveRequest(id);

    // 2. Controllo 'mounted'
    if (!mounted) return;

    if (success) {
      // 3. Feedback Positivo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Richiesta Approvata! Viaggio creato."),
          backgroundColor: Colors.green,
        ),
      );
      // 4. Refresh: Ricarichiamo la tabella per mostrare lo stato aggiornato (da PENDING a APPROVED)
      _loadData();
    } else {
      // Feedback Negativo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Errore durante l'approvazione."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              // HEADER: Titolo e Bottone Refresh manuale
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gestione Richieste", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Visualizza e gestisci le richieste in arrivo", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData, // Collega il bottone alla funzione di ricarica
                tooltip: "Aggiorna lista",
              )
            ],
          ),
          const SizedBox(height: 24),

          // TABELLA DATI
          Expanded(
            child: FutureBuilder<List<RequestDetailDTO>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                // STATO 1: Caricamento
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // STATO 2: Errore
                else if (snapshot.hasError) {
                  return Center(child: Text("Errore caricamento: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }
                // STATO 3: Dati vuoti
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessuna richiesta presente."));
                }

                // STATO 4: Successo -> Rendering Tabella
                final requests = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 30,
                      headingRowColor: MaterialStateProperty.all(Colors.transparent),
                      columns: const [
                        DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Committente", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Origine", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Destinazione", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Peso (kg)", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Data Ritiro", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      // Mapping: Trasforma ogni DTO in una DataRow
                      rows: requests.map((req) => _buildRow(req)).toList(),
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

  /// Costruisce una singola riga della tabella.
  /// Contiene la logica condizionale per i bottoni (Approva vs In Pianificazione).
  DataRow _buildRow(RequestDetailDTO req) {
    // Normalizzazione dello stato (da Enum o Stringa)
    final statusString = req.status.toString().split('.').last.toUpperCase();
    final isPending = statusString == "PENDING";
    final isApproved = statusString == "APPROVED";

    return DataRow(cells: [
      DataCell(Text("#${req.id}", style: const TextStyle(fontWeight: FontWeight.w500))),
      // Gestione Null-Safety: Se manca il nome, mostra l'ID o un testo di default
      DataCell(Text(req.clientFullName ?? "ID: ${req.clientId}")),

      // Troncatura testi lunghi (Ellipsis) per non rompere il layout
      DataCell(SizedBox(width: 150, child: Text(req.originAddress, overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 150, child: Text(req.destinationAddress, overflow: TextOverflow.ellipsis))),

      DataCell(Text(req.weight.toString())),
      DataCell(Text(req.pickupDate)),
      DataCell(_buildStatusBadge(statusString, isApproved)),

      // LOGICA AZIONI
      DataCell(Row(
        children: [
          if (isPending) ...[
            // Caso PENDING: Mostra bottone "Approva"
            ElevatedButton(
              onPressed: () => _approveRequest(req.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0D1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text("Approva"),
            ),
            const SizedBox(width: 8),
            // Bottone Rifiuta
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              child: const Text("Rifiuta"),
            ),
          ] else if (isApproved) ...[
            // Caso APPROVED: Non si può ri-approvare, mostra stato informativo
            const Text("In Pianificazione", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ] else ...[
            Text(statusString, style: const TextStyle(color: Colors.grey)),
          ]
        ],
      )),
    ]);
  }

  /// Widget di utilità per creare le "pillole" colorate dello stato.
  Widget _buildStatusBadge(String text, bool approved) {
    Color bgColor = Colors.grey[100]!;
    Color txtColor = Colors.black87;

    // Logica colori semantica
    if (text == "APPROVED") {
      bgColor = Colors.green.withOpacity(0.1);
      txtColor = Colors.green[800]!;
    } else if (text == "PENDING") {
      bgColor = Colors.orange.withOpacity(0.1);
      txtColor = Colors.orange[800]!;
    } else if (text == "REJECTED") {
      bgColor = Colors.red.withOpacity(0.1);
      txtColor = Colors.red[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent)
      ),
      child: Text(text, style: TextStyle(color: txtColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}