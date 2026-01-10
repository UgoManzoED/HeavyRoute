import 'package:flutter/material.dart';
import '../../models/request_detail_dto.dart';
import '../../services/request_service.dart';
import '../../../auth/services/user_service.dart';
import '../widgets/add_order_header.dart';
import '../widgets/user_data_popup.dart';
import '../widgets/new_order_popup.dart';
import '../widgets/request_card.dart';

/**
 * Schermata principale della Dashboard dedicata al Committente.
 * <p>
 * Agisce come controller di alto livello per la visualizzazione delle richieste,
 * il profilo utente e l'inserimento di nuovi ordini.
 * </p>
 * * @author Roman
 */
class CustomerDashboardScreen extends StatefulWidget {
  /**
   * Costruttore della classe {@link CustomerDashboardScreen}.
   * * @param key Chiave univoca del widget.
   */
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _DashboardScreenState();
}

/**
 * Stato della dashboard che gestisce la logica di business e l'interfaccia.
 * <p>
 * Si occupa di orchestrare i servizi {@link RequestService} e {@link UserService}
 * per popolare i widget della UI.
 * </p>
 */
class _DashboardScreenState extends State<CustomerDashboardScreen> {
  /** Servizio per il recupero e la gestione delle richieste/ordini. */
  final RequestService _requestService = RequestService();

  /** Servizio per la gestione del profilo e della sessione utente. */
  final UserService _userService = UserService();

  /** Future che contiene la lista dei dettagli delle richieste caricate. */
  late Future<List<RequestDetailDTO>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRequests();
  }

  /**
   * Gestisce il processo di logout dell'utente.
   * <p>
   * Mostra un dialog di conferma. Se l'utente conferma, invoca il metodo logout
   * di {@link UserService}, invalida il token e resetta la navigazione verso il login.
   * </p>
   */
  void _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Sei sicuro di voler uscire e invalidare la sessione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Esci', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  /**
   * Innesca il caricamento asincrono delle richieste dal server.
   * <p>
   * Aggiorna lo stato {@link _requestsFuture} per attivare il {@link FutureBuilder}.
   * </p>
   */
  void _refreshRequests() {
    setState(() {
      _requestsFuture = _requestService.getMyRequests();
    });
  }

  /**
   * Mostra il dialog per la creazione di un nuovo ordine.
   * <p>
   * In caso di chiusura con esito positivo, viene invocato {@link #_refreshRequests()}
   * per aggiornare la lista a schermo.
   * </p>
   */
  void _openNewOrderDialog() {
    showDialog<bool>(
      context: context,
      builder: (context) => const Dialog(child: NewOrderPopup()),
    ).then((success) {
      if (success == true) _refreshRequests();
    });
  }

  /**
   * Apre il popup per visualizzare e modificare i dati anagrafici dell'utente.
   * <p>
   * Fornisce al widget {@link UserDataPopup} l'istanza di {@link UserService}
   * necessaria per il recupero del profilo corrente.
   */
  void _openUserDataDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: UserDataPopup(userService: _userService),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard Committente'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          tooltip: 'Logout',
          onPressed: _handleLogout,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Color(0xFF374151)),
              tooltip: 'Dati Utente',
              onPressed: _openUserDataDialog,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshRequests(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              AddOrderHeader(onAddTap: _openNewOrderDialog),
              const SizedBox(height: 32),
              _buildOrdersSection(),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Costruisce la sezione relativa alla lista degli ordini esistenti.
   * <p>
   * Utilizza un {@link FutureBuilder} per gestire i diversi stati della
   * richiesta di rete (attesa, errore, dati pronti).
   * </p>
   * * @return Un Widget contenente la lista degli ordini o un indicatore di caricamento.
   */
  Widget _buildOrdersSection() {
    return FutureBuilder<List<RequestDetailDTO>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Nessun ordine trovato."));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => RequestCard(request: snapshot.data![index]),
        );
      },
    );
  }
}