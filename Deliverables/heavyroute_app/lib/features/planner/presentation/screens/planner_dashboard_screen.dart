import 'package:flutter/material.dart';
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

  // Lista delle schermate
  final List<Widget> _tabs = [
    const TransportRequestsTab(),
    const RegistrationRequestsTab(),
    const FleetTab(), // Placeholder
    const AssignmentsTab(),
    const AlertsTab(), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Sfondo grigio chiaro pagina
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Logo Simulato o Icona
            Icon(Icons.local_shipping_rounded, color: Color(0xFF0D0D1A)),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("HeavyRoute", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Dashboard Pianificatore", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0D0D1A),
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // BARRA DI NAVIGAZIONE PERSONALIZZATA
          _buildCustomNavBar(),
          const SizedBox(height: 20),
          // CONTENUTO DINAMICO
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
        color: const Color(0xFFE5E7EB), // Grigio sfondo barra
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
                    color: Colors.red, // Badge rosso
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