import 'package:flutter/material.dart';
import '../core/storage/token_storage.dart';

class HeavyRouteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;

  // UNICO CAMBIAMENTO: Da isDashboard a isLanding
  final bool isLanding;

  final VoidCallback? onProfileTap;

  const HeavyRouteAppBar({
    super.key,
    this.subtitle = "Gestione Trasporti Eccezionali",
    this.isLanding = false, // false = Dashboard (Loggato), true = Landing
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,

      // SINISTRA: ICONA CAMION + TITOLO (INVARIATO)
      leadingWidth: 50,
      leading: const Icon(
        Icons.local_shipping,
        color: Colors.black,
        size: 28,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HEAVYROUTE",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),

      // DESTRA: LOGICA AGGIORNATA SU isLanding
      actions: [
        if (isLanding) ...[
          // CASO LANDING PAGE (Prima era !isDashboard)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text("Accedi"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
              ),
            ),
          )
        ] else ...[
          // CASO DASHBOARD (Prima era isDashboard)

          // 1. TASTO LOGOUT CON DIALOG (INVARIATO)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Esci",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Sei sicuro di voler uscire?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Annulla"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await TokenStorage.deleteAll();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => false);
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Esci"),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(width: 8),

          // 2. TASTO PROFILO (INVARIATO)
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87, size: 28),
            tooltip: "Area Personale",
            onPressed: onProfileTap,
          ),

          const SizedBox(width: 16),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}