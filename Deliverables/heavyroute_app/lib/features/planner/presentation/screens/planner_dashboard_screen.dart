import 'package:flutter/material.dart';
import '../widget/transport_requests_tab.dart';
import '../widget/registration_requests_tab.dart';
import '../widget/assignments_tab.dart';
import '../widget/fleet_tab.dart';
import '../widget/alerts_tab.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/**
 * La Dashboard principale per il ruolo "LOGISTIC_PLANNER".
 * <p>
 * Questa schermata funge da container per le varie funzionalità operative.
 * Utilizza un pattern a "Tabs" per cambiare contenuto senza ricaricare l'intera pagina.
 * </p>
 */
class PlannerDashboardScreen extends StatefulWidget {
  const PlannerDashboardScreen({super.key});

  @override
  State<PlannerDashboardScreen> createState() => _PlannerDashboardScreenState();
}

class _PlannerDashboardScreenState extends State<PlannerDashboardScreen> {
  int _selectedIndex = 0;

  // Lista delle viste (Lazy Loading parziale).
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
      backgroundColor: const Color(0xFFF8F9FA),

      // HEADER: Branding e Profilo Utente
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
          // Bottone Profilo / Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0D0D1A),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 20), // Icona Logout
                tooltip: "Esci",
                onPressed: () async {
                  // 1. Cancella Token e Ruolo
                  await TokenStorage.deleteAll();

                  // 2. Torna al Login
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                },
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

  /**
   * Costruisce la barra di navigazione a segmenti.
   * Design ispirato alle dashboard web moderne (pill-shaped).
   */
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

  /**
   * Costruisce un singolo bottone della navbar.
   * Gestisce lo stato "Selezionato" vs "Non Selezionato" cambiando colore e stile.
   */
  Widget _buildNavButton(int index, String label, IconData icon, {int badgeCount = 0}) {
    bool isSelected = _selectedIndex == index;

    // Expanded assicura che ogni bottone abbia la stessa larghezza
    return Expanded(
      child: GestureDetector(
        // Al click, aggiorniamo l'indice e forziamo il redraw della UI con setState
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // Feedback visivo: Il tab attivo diventa Bianco con ombra, gli altri trasparenti
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

              // LOGICA DEL BADGE (Pallino Rosso)
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