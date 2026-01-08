import 'package:flutter/material.dart';
import '../../models/request_dto.dart';
import '../../services/request_service.dart';

/**
 * Schermata della Dashboard che visualizza la lista delle richieste effettuate.
 * Utilizza [RequestService] per il recupero dei dati e riflette la struttura
 * definita nei DTO del progetto.
 * * @author Roman
 * @version 1.1
 */
class DashboardScreen extends StatefulWidget {
  /**
   * Costruttore per DashboardScreen.
   * * @param key Chiave univoca del widget.
   */
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/**
 * Stato della DashboardScreen. Gestisce il caricamento asincrono delle richieste.
 */
class _DashboardScreenState extends State<DashboardScreen> {
  /** Istanza del servizio per le chiamate API */
  final RequestService _requestService = RequestService();

  /** Future per la gestione dello stato della richiesta HTTP */
  late Future<List<RequestCreationDTO>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    // Inizializzazione del caricamento dati
    _requestsFuture = _requestService.getMyRequests();
  }

  /**
   * Costruisce la UI della dashboard con una ListView condizionale.
   * * @param context Contesto di build.
   * @return Widget Scaffold con la lista delle richieste.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Mie Spedizioni'),
        elevation: 2,
      ),
      body: FutureBuilder<List<RequestCreationDTO>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessuna richiesta presente.'));
          }

          final requests = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = requests[index];
              return _buildRequestCard(item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-request'),
        label: const Text('Nuova Richiesta'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  /**
   * Genera una card per visualizzare i dettagli sintetici di una richiesta.
   * * @param request Il DTO della richiesta da visualizzare.
   * @return Un widget Card formattato.
   */
  Widget _buildRequestCard(RequestCreationDTO request) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.location_on_outlined, size: 20),
        ),
        title: Text(
          'Da: ${request.originAddress}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A: ${request.destinationAddress}'),
            const SizedBox(height: 4),
            Text(
              'Data: ${request.pickupDate} • Peso: ${request.weight}t',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Implementazione futura: dettaglio richiesta
        },
      ),
    );
  }

  /**
   * Crea un widget per visualizzare lo stato di errore.
   * * @param message Messaggio di errore da mostrare.
   * @return Widget centrato con messaggio di errore.
   */
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text('Errore: $message', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}