import 'package:flutter/material.dart';
import '../../../../common/heavy_route_app_bar.dart';
import '../../auth/services/user_service.dart';
import '../../auth/models/user_model.dart'; // CORRETTO: rimosso il punto finale
import '../../requests/presentation/widgets/user_data_popup.dart';

import '../widgets/route_validation_tab.dart';
import '../widgets/documentation_tab.dart';
import '../widgets/technical_escort_tab.dart';
import '../widgets/road_constraints_tab.dart';

/**
 * Dashboard principale per il Traffic Coordinator.
 * <p>
 * Gestisce la navigazione tra le tab operative: Validazione Percorsi, Documentazione,
 * Scorta Tecnica e Vincoli Viabilità.
 * </p>
 * @author Roman
 */
class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() => _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState extends State<CoordinatorDashboardScreen> {
  final UserService _userService = UserService();
  int _currentTabIndex = 0;

  final List<Widget> _tabs = const [
    RouteValidationTab(),
    DocumentationTab(),
    TechnicalEscortTab(),
    RoadConstraintsTab(),
  ];

  /**
   * Apre il popup con i dati dell'utente loggato.
   */
  Future<void> _openProfilePopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final UserModel? user = (await _userService.getCurrentUser()) as UserModel?;

      if (mounted) Navigator.pop(context);

      if (user != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: UserDataPopup(
                user: user, // CORRETTO: Aggiunta la variabile user
                userService: _userService,
                role: "Traffic Coordinator",
                showDownload: false,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: HeavyRouteAppBar(
        subtitle: "Traffic Coordinator Dashboard",
        isDashboard: true,
        onProfileTap: _openProfilePopup,
      ),
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

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _buildTabButton(0, "Validazione Percorsi", Icons.location_on_outlined),
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
              Icon(icon, size: 18, color: isSelected ? Colors.black : Colors.grey[700]),
              const SizedBox(width: 8),
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