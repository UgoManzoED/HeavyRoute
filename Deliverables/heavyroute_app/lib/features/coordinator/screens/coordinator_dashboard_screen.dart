import 'package:flutter/material.dart';
import '../../../../common/heavy_route_app_bar.dart';
import '../../auth/services/user_service.dart';
import '../../auth/models/user_dto.dart';
import '../../requests/presentation/widgets/user_data_popup.dart';
import '../widgets/route_validation_tab.dart';
import '../widgets/documentation_tab.dart';
import '../widgets/technical_escort_tab.dart';
import '../widgets/road_constraints_tab.dart';

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() => _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState extends State<CoordinatorDashboardScreen> {
  // 1. Inizializzazione Servizio
  final UserService _userService = UserService();
  int _currentTabIndex = 0;

  // Lista delle schermate (Tab)
  final List<Widget> _tabs = const [
    RouteValidationTab(),
    DocumentationTab(),
    TechnicalEscortTab(),
    RoadConstraintsTab(),
  ];

  // 2. LOGICA PROFILO (Specifica per Coordinatore Traffico)
  Future<void> _openProfilePopup() async {
    // Spinner di caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Recupera i dati dal service
      final UserDTO? user = await _userService.getCurrentUser();

      if (mounted) Navigator.pop(context); // Chiudi spinner

      if (user != null && mounted) {
        // Mostra Popup Profilo
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: UserDataPopup(
                user: user,
                userService: _userService,
                role: "Traffic Coordinator", // Ruolo visualizzato
                showDownload: false, // FALSE: Utente Interno (niente doc/azienda)
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Errore profilo coordinator: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Sfondo grigio chiaro standard

      // --- HEADER / CORNICE ---
      appBar: HeavyRouteAppBar(
        subtitle: "Traffic Coordinator Dashboard",
        isDashboard: true,
        onProfileTap: _openProfilePopup, // Collegamento al metodo sopra
      ),
      // ------------------------

      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildCustomTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _tabs[_currentTabIndex],
            ),
          ),
        ],
      ),
    );
  }

  // --- BARRA DI NAVIGAZIONE TAB ---
  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB), // Grigio scuro della barra
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _buildTabButton(0, "Validazione Percorsi", Icons.location_on_outlined, badgeCount: 2),
          _buildTabButton(1, "Documentazione", Icons.description_outlined),
          _buildTabButton(2, "Scorta Tecnica", Icons.security_outlined),
          _buildTabButton(3, "Vincoli Viabilità", Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon, {int badgeCount = 0}) {
    bool isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icona
              Icon(icon, size: 18, color: isSelected ? Colors.black : Colors.grey[700]),
              const SizedBox(width: 8),

              // Testo (con gestione overflow per schermi piccoli)
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ),

              // Badge Notifica Rosso
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}