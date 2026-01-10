import 'package:flutter/material.dart';
import '../../../features/auth/services/auth_service.dart';

class HeavyRouteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final bool isDashboard; // true: mostra Logout e Icona Profilo, false: mostra "Area Personale"

  const HeavyRouteAppBar({
    super.key,
    required this.subtitle,
    this.isDashboard = true, // Di default la usiamo per le dashboard
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleLogout(BuildContext context) {
    final AuthService authService = AuthService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma Logout"),
        content: const Text("Sei sicuro di voler uscire?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.logout();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Esci", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      // 1. SINISTRA: Freccia Logout solo se siamo in Dashboard
      leading: isDashboard
          ? IconButton(
        icon: const Icon(Icons.exit_to_app, color: Colors.red),
        onPressed: () => _handleLogout(context),
      )
          : null,
      title: Row(
        children: [
          const Icon(Icons.local_shipping_rounded, color: Color(0xFF0D0D1A)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("HeavyRoute", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isDashboard
          // 2. DESTRA DASHBOARD: Icona Profilo
              ? CircleAvatar(
            backgroundColor: const Color(0xFF0D0D1A),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 20),
              onPressed: () {}, // Qui andrà la logica profilo
            ),
          )
          // 3. DESTRA LANDING: Tasto Area Personale
              : TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF0D0D1A),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Area Personale", style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        )
      ],
    );
  }
}