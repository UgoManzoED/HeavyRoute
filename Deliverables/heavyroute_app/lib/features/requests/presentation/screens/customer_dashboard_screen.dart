import 'package:flutter/material.dart';
import '../../../../common/heavy_route_app_bar.dart';

import '../../models/transport_request.dart';
import '../../services/request_service.dart';
import '../../../auth/services/user_service.dart';
import '../../../auth/models/user_model.dart';
import '../widgets/add_order_header.dart';
import '../widgets/user_data_popup.dart';
import '../widgets/new_order_popup.dart';
import '../widgets/request_card.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<CustomerDashboardScreen> {
  final RequestService _requestService = RequestService();
  final UserService _userService = UserService();
  late Future<List<TransportRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRequests();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = _requestService.getMyRequests();
    });
  }

  void _openNewOrderDialog() {
    showDialog<bool>(
      context: context,
      builder: (context) => const Dialog(child: NewOrderPopup()),
    ).then((success) {
      if (success == true) _refreshRequests();
    });
  }

  // --- LOGICA MODIFICATA: APRE IL POPUP DATI UTENTE ---
  Future<void> _openProfilePopup() async {
    // 1. Mostra lo spinner di caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Recupera i dati aggiornati dell'utente
      // Nota: Uso getUserProfile() come definito nel fix del UserService
      final UserModel? user = await _userService.getCurrentUser();

      // Chiudi il caricamento
      if (mounted) Navigator.pop(context);

      if (user != null && mounted) {
        // 3. Mostra il Dialog con UserDataPopup (Stile immagine Dati-utente.jpg)
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent, // Sfondo trasparente per gestire i bordi nel child
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // Limita larghezza come da design
              child: UserDataPopup(
                user: user,
                userService: _userService,
                role: "COMMITTENTE",
                showDownload: true,
              ),
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossibile recuperare i dati utente")),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Chiudi caricamento in caso di errore
      print("Errore apertura profilo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: HeavyRouteAppBar(
        subtitle: 'Dashboard Committente',
        isDashboard: true,
        // COLLEGATO AL NUOVO METODO DEL POPUP
        onProfileTap: _openProfilePopup,
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

  Widget _buildOrdersSection() {
    return FutureBuilder<List<TransportRequest>>(
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