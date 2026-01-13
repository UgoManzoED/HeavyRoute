import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';

class HeavyRouteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final bool isLanding;
  final VoidCallback? onProfileTap;

  // Nuova altezza personalizzata per far entrare il logo completo
  final double height = 90.0;

  const HeavyRouteAppBar({
    super.key,
    this.subtitle = "Soluzioni per la Logistica", // Testo corretto come da tua richiesta
    this.isLanding = false,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    // Rileviamo se siamo su mobile (meno di 800px) per nascondere il sottotitolo
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppBar(
      // Altezza aumentata
      toolbarHeight: height,

      // Rimuoviamo il leading standard e lo spazio riservato
      automaticallyImplyLeading: false,
      leading: null,
      leadingWidth: 0,

      // Spaziatura sinistra per non attaccare il logo al bordo
      titleSpacing: 24,

      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,

      // USIAMO IL TITLE PER IL LOGO COMPLETO
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. IL LOGO COMPLETO (Immagine + Scritta integrata nel file png)
          Image.asset(
            'assets/images/logo_progetto.png', // Assicurati che questo sia il file col logo intero
            height: 70, // Altezza generosa
            fit: BoxFit.contain,
          ),

          // 2. SOTTOTITOLO (Visibile SOLO se NON siamo su mobile)
          if (!isMobile) ...[
            Container(
              height: 40,
              width: 1,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        ],
      ),

      actions: [
        if (isLanding) ...[
          // --- LANDING PAGE: Tasto Accedi ---
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text("Accedi"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                side: const BorderSide(color: Colors.black),
              ),
            ),
          )
        ] else ...[
          // --- DASHBOARD: Logout e Profilo ---
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Esci",
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87, size: 32),
            onPressed: onProfileTap,
          ),
          const SizedBox(width: 24),
        ],
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Sei sicuro di voler uscire?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annulla")),
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}