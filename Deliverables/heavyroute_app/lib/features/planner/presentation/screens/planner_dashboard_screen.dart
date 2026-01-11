import 'package:flutter/material.dart';
import '../../../../common/heavy_route_app_bar.dart';
import '../../../auth/services/user_service.dart';
import '../../../auth/models/user_model.dart';
import '../../../requests/presentation/widgets/user_data_popup.dart';
import '../widget/transport_requests_tab.dart';
import '../widget/registration_requests_tab.dart';
import '../widget/assignments_tab.dart';
import '../widget/fleet_tab.dart';
import '../widget/alerts_tab.dart';

class PlannerDashboardScreen extends StatefulWidget {
  const PlannerDashboardScreen({super.key});

  @override
  State<PlannerDashboardScreen> createState() => _PlannerDashboardScreenState();
}

class _PlannerDashboardScreenState extends State<PlannerDashboardScreen> {
  // 1. Inizializza il servizio utente
  final UserService _userService = UserService();

  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const TransportRequestsTab(),
    const RegistrationRequestsTab(),
    const FleetTab(),
    const AssignmentsTab(),
    const AlertsTab(),
  ];

  // 2. LOGICA APERTURA PROFILO
  Future<void> _openProfilePopup() async {
    // Spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // TIPO AGGIORNATO: UserModel
      final UserModel? user = await _userService.getCurrentUser();

      if (mounted) Navigator.pop(context); // Chiudi spinner

      if (user != null && mounted) {
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
                role: "Pianificatore",
                showDownload: false, // Utente interno, niente doc
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Errore profilo pianificatore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // APPBAR COLLEGATA
      appBar: HeavyRouteAppBar(
        subtitle: "Dashboard Pianificatore",
        isDashboard: true,
        onProfileTap: _openProfilePopup,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildCustomNavBar(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _tabs[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(0, "Richieste", Icons.inventory_2_outlined),
          _buildNavButton(1, "Registrazioni", Icons.person_add_outlined, badgeCount: 3),
          _buildNavButton(2, "Flotta", Icons.local_shipping_outlined),
          _buildNavButton(3, "Assegnazioni", Icons.near_me_outlined),
          _buildNavButton(4, "Avvisi", Icons.notifications_outlined, badgeCount: 3),
        ],
      ),
    );
  }

  Widget _buildNavButton(int index, String label, IconData icon, {int badgeCount = 0}) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Icon(icon, size: 20, color: isSelected ? Colors.black : Colors.grey[700]),
                  if (badgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 6, minHeight: 6),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[700],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}