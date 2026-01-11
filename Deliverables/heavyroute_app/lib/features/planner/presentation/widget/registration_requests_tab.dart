import 'package:flutter/material.dart';
import '../../../auth/services/registration_service.dart';

/**
 * Tabella operativa per la gestione e l'approvazione delle nuove registrazioni.
 * <p>
 * Questo widget permette ai Planner e Account Manager di visualizzare gli utenti
 * con stato {@code active = false} e di approvarli o rifiutarli tramite API.
 * </p>
 * @author Roman
 * @version 1.1
 */
class RegistrationRequestsTab extends StatefulWidget {
  const RegistrationRequestsTab({super.key});

  @override
  State<RegistrationRequestsTab> createState() => _RegistrationRequestsTabState();
}

class _RegistrationRequestsTabState extends State<RegistrationRequestsTab> {
  /** Servizio per la comunicazione con gli endpoint amministrativi degli utenti. */
  final RegistrationService _service = RegistrationService();

  /** Future che gestisce il caricamento asincrono della lista utenti. */
  late Future<List<dynamic>> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /**
   * Inizializza o aggiorna il flusso di dati dalla sorgente backend.
   */
  void _loadData() {
    setState(() {
      _pendingRequests = _service.getPendingRegistrations();
    });
  }

  /**
   * Gestisce l'esito della decisione dell'amministratore su una registrazione.
   * <p>
   * In caso di approvazione, il flag {@code active} dell'utente viene impostato a true.
   * In caso di rifiuto, il record viene rimosso dal sistema.
   * </p>
   * @param id L'identificativo univoco dell'utente.
   * @param approve Indica se l'azione è di approvazione (true) o rifiuto (false).
   */
  Future<void> _handleAction(int id, bool approve) async {
    final bool success = approve
        ? await _service.approveUser(id)
        : await _service.rejectUser(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? "Utente approvato con successo" : "Richiesta eliminata"),
          backgroundColor: approve ? Colors.green : Colors.red,
        ),
      );
      _loadData(); // Effettua il refresh della tabella dopo l'azione
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'elaborazione della richiesta")),
      );
    }
  }

  Future<void> _handleApprove(int id) async {
    bool success = await _service.approveUser(id);

    if (success) {
      // 1. Messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utente Attivato!"), backgroundColor: Colors.green)
      );
      // 2. REFRESH: Fondamentale per far sparire l'utente approvato e vedere gli altri
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Richieste di Registrazione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Approva o rifiuta le richieste di registrazione dei nuovi utenti dal database",
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _pendingRequests,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessuna registrazione in attesa di approvazione"));
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
   * Costruisce la DataTable dinamica basata sui dati recuperati.
   * @param users La lista degli utenti pendenti (mappa JSON o DTO).
   */
  Widget _buildDataTable(List<dynamic> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 25,
        columns: const [
          DataColumn(label: Text("Nome e Cognome")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Azienda")),
          DataColumn(label: Text("Stato")),
          DataColumn(label: Text("Azioni")),
        ],
        rows: users.map((user) => _buildRow(user)).toList(),
      ),
    );
  }

  /**
   * Genera una singola riga della tabella per l'utente fornito.
   */
  DataRow _buildRow(dynamic user) {
    return DataRow(cells: [
      DataCell(Text("${user['firstName']} ${user['lastName']}", style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(user['email'])),
      DataCell(Text(user['companyName'] ?? "Privato")),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
          child: Text("IN ATTESA", style: TextStyle(fontSize: 10, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
        ),
      ),
      DataCell(Row(
        children: [
          ElevatedButton(
            onPressed: () => _handleAction(user['id'], true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white),
            child: const Text("Approva"),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _handleAction(user['id'], false),
            child: const Text("Rifiuta", style: TextStyle(color: Colors.red)),
          ),
        ],
      )),
    ]);
  }
}