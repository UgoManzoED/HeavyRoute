import 'package:flutter/material.dart';
import '../../../common/widgets/heavy_route_app_bar.dart';
import '../../auth/services/user_service.dart';
import '../../auth/models/user_model.dart';
import '../../requests/presentation/widgets/user_data_popup.dart';
import '../../planner/presentation/service/planner_service.dart';
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
  final UserService _userService = UserService();
  final PlannerService _plannerService = PlannerService(); // Usiamo questo per i count (o CoordinatorService)

  int _currentTabIndex = 0;
  int _pendingValidationCount = 0; // Contatore dinamico

  final List<Widget> _tabs = const [
    RouteValidationTab(),
    DocumentationTab(),
    TechnicalEscortTab(),
    RoadConstraintsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _refreshCounts();
  }

  // Aggiorna il badge rosso
  Future<void> _refreshCounts() async {
    try {
      setState(() => _pendingValidationCount = 1);
    } catch (e) {
      debugPrint("Errore count: $e");
    }
  }

  Future<void> _openProfilePopup() async {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final UserModel? user = await _userService.getCurrentUser();
      if (mounted) Navigator.pop(context);

      if (user != null && mounted) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: UserDataPopup(
                user: user,
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: HeavyRouteAppBar(
          subtitle: "Traffic Coordinator Dashboard",
          onProfileTap: _openProfilePopup,
        ),
        body: Column(
          children: [
            const SizedBox(height: 24),
            _buildCustomTabBar(),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                // Usiamo IndexedStack per mantenere lo stato delle tab quando cambi
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: _tabs,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildTabButton(0, "Validazione Percorsi", Icons.map_outlined, badgeCount: _pendingValidationCount),
          _buildTabButton(1, "Documentazione", Icons.folder_open_outlined),
          _buildTabButton(2, "Scorta Tecnica", Icons.security_outlined),
          _buildTabButton(3, "Vincoli & Cantieri", Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon, {int badgeCount = 0}) {
    final bool isSelected = _currentTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D0D1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.redAccent : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.red[800],
                        fontSize: 11,
                        fontWeight: FontWeight.bold
                    ),
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