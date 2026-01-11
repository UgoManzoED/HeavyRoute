import 'package:flutter/material.dart';
import '../../../../features/requests/models/transport_request.dart';
import '../../../../features/requests/services/request_service.dart';
import '../../../../features/trips/services/trip_service.dart';

/**
 * Tab per la gestione delle richieste di trasporto.
 */
class TransportRequestsTab extends StatefulWidget {
  const TransportRequestsTab({super.key});

  @override
  State<TransportRequestsTab> createState() => _TransportRequestsTabState();
}

class _TransportRequestsTabState extends State<TransportRequestsTab> {
  /** Servizio per la gestione delle richieste di trasporto. */
  final RequestService _requestService = RequestService();

  /** Servizio per la gestione e creazione dei viaggi. */
  final TripService _tripService = TripService();

  // TIPO AGGIORNATO: Future<List<TransportRequest>>
  late Future<List<TransportRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /**
   * Innesca il caricamento delle richieste dal database.
   * <p>
   * Chiamato all'inizializzazione e durante il refresh manuale.
   * </p>
   */
  void _loadData() {
    setState(() {
      _requestsFuture = _requestService.getAllRequests();
    });
  }

  /**
   * Esegue l'approvazione di una richiesta specifica.
   * <p>
   * Invia l'ID al server tramite {@link TripService#approveRequest}.
   * In caso di successo, aggiorna la lista locale.
   * </p>
   * @param id Identificativo univoco della richiesta.
   */
  Future<void> _approveRequest(int id) async {
    final success = await _tripService.approveRequest(id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Richiesta Approvata con successo."),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Errore durante l'approvazione della richiesta."),
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
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<TransportRequest>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Errore nel caricamento dei dati: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessuna richiesta di trasporto trovata nel sistema."));
                }

                return _buildDataTable(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Costruisce l'header della sezione con titolo e pulsante di aggiornamento.
   */
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Richieste dal Database", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Elenco aggiornato in tempo reale delle richieste clienti", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _loadData,
          tooltip: "Sincronizza Dati",
        )
      ],
    );
  }

  Widget _buildDataTable(List<TransportRequest> requests) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 30,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Origine", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Destinazione", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Peso", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Data", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: requests.map((req) => _buildRow(req)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(TransportRequest req) {
    final status = req.requestStatus.name;
    final bool canApprove = status == "PENDING";

    final dateStr = req.pickupDate.toString().split(' ').first;
    final origin = req.originAddress.split(',').first;
    final dest = req.destinationAddress.split(',').first;

    return DataRow(cells: [
      DataCell(Text("#${req.id}", style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(req.customerName ?? "Cliente")),
      DataCell(SizedBox(width: 150, child: Text(origin, overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 150, child: Text(dest, overflow: TextOverflow.ellipsis))),
      DataCell(Text("${req.load.weightKg ?? '-'} kg")),
      DataCell(Text(dateStr)),
      DataCell(_buildStatusBadge(status)),
      DataCell(
        canApprove
            ? ElevatedButton(
          onPressed: () => _approveRequest(req.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D0D1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text("Approva"),
        )
            : const Text("Gestita", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      ),
    ]);
  }

  /**
   * Genera un badge colorato basato sullo stato della richiesta.
   * @param status Stringa rappresentante lo stato.
   */
  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == "APPROVED") color = Colors.green;
    if (status == "PENDING") color = Colors.orange;
    if (status == "REJECTED") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}