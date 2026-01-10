import 'package:flutter/material.dart';
import '../../../../common/heavy_route_app_bar.dart';
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
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const TransportRequestsTab(),
    const RegistrationRequestsTab(),
    const FleetTab(),
    const AssignmentsTab(),
    const AlertsTab(),
  ];

  // NOTA: Ho rimosso _handleLogout() e _authService perché ora sono nel widget condiviso!

  Widget _buildMockWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // SPOSTA TUTTO QUI DENTRO
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Il colore deve stare dentro BoxDecoration
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                children: const [
                  TextSpan(text: "MODALITÀ DEMO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "I dati visualizzati sono mockup statici."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: const HeavyRouteAppBar(
        subtitle: "Dashboard Pianificatore",
        isDashboard: true, // <--- Questo attiva Logout e Profilo
      ),

      body: Column(
        children: [
          _buildMockWarning(),
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

  // ... (Mantieni _buildCustomNavBar e _buildNavButton identici a prima)
  Widget _buildCustomNavBar() {
    // ... codice identico a prima ...
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
          _buildNavButton(0, "Richieste di Trasporto", Icons.inventory_2_outlined),
          _buildNavButton(1, "Registrazioni", Icons.person_add_outlined, badgeCount: 3),
          _buildNavButton(2, "Flotta e Risorse", Icons.local_shipping_outlined),
          _buildNavButton(3, "Assegnazioni", Icons.near_me_outlined),
          _buildNavButton(4, "Segnalazioni", Icons.notifications_outlined, badgeCount: 3),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.black : Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(4),
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