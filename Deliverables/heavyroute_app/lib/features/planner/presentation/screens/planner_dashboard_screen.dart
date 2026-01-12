import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_app_bar.dart';
import '../../../../common/widgets/heavy_route_map.dart';
import '../../../auth/services/user_service.dart';
import '../../../auth/models/user_model.dart';
import '../../../requests/presentation/widgets/user_data_popup.dart';
import '../../../trips/models/route_model.dart';
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
  final UserService _userService = UserService();
  int _selectedIndex = 0;

  // 1. STATO PER LA MAPPA
  RouteModel? _selectedRoute;

  // 2. CALLBACK DI AGGIORNAMENTO
  void _onRouteSelected(RouteModel? route) {
    setState(() {
      _selectedRoute = route;
    });
  }

  // 3. LOGICA PROFILO UTENTE
  Future<void> _openProfilePopup() async {
    // Mostra Spinner caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
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
                showDownload: false,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Chiudi spinner in caso di errore
      debugPrint("Errore apertura profilo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. DEFINIZIONE DELLE TAB
    final List<Widget> tabs = [
      TransportRequestsTab(
        onRoutePreview: _onRouteSelected,
      ),
      // const RegistrationRequestsTab(),
      // const FleetTab(),
      // const AssignmentsTab(),
      // const AlertsTab(),

      // Mettiamo dei segnaposto vuoti per non rompere la navbar
      const Center(child: Text("Registrazioni DISABILITATO")),
      const Center(child: Text("Flotta DISABILITATO")),
      const Center(child: Text("Assegnazioni DISABILITATO")),
      const Center(child: Text("Avvisi DISABILITATO")),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: HeavyRouteAppBar(
          subtitle: "Dashboard Pianificatore",
          onProfileTap: _openProfilePopup,
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            _buildCustomNavBar(),
            const SizedBox(height: 20),

            // 5. LAYOUT MASTER-DETAIL (TABELLA + MAPPA)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LATO SINISTRO: Contenuto della Tab corrente
                  Expanded(
                    flex: (_selectedIndex == 0 && _selectedRoute != null) ? 3 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: tabs[_selectedIndex],
                    ),
                  ),

                  // LATO DESTRO: Mappa
                  if (_selectedIndex == 0 && _selectedRoute != null) ...[
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 24, bottom: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        // CLIP per arrotondare la mappa
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Widget Mappa Reale
                              HeavyRouteMap(route: _selectedRoute),

                              // Pulsante "X" per chiudere la mappa
                              Positioned(
                                top: 10,
                                right: 10,
                                child: FloatingActionButton.small(
                                  backgroundColor: Colors.white,
                                  elevation: 2,
                                  child: const Icon(Icons.close, color: Colors.black87),
                                  onPressed: () {
                                    setState(() {
                                      _selectedRoute = null; // Nasconde la mappa
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NAVBAR ---
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
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _selectedRoute = null;
          });
        },
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