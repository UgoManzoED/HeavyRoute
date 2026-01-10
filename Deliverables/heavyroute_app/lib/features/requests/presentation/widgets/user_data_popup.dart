import 'package:flutter/material.dart';
import '../../../auth/models/user_dto.dart';
import '../../../auth/services/user_service.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart'; // Importa la schermata a schede

class UserDataPopup extends StatelessWidget {
  final UserDTO user;
  final UserService userService;
  final String role;
  final bool showDownload;

  const UserDataPopup({
    super.key,
    required this.user,
    required this.userService,
    required this.role,
    required this.showDownload
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con Titolo e X di chiusura
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profilo Utente", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("I tuoi dati personali e informazioni aziendali", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),

          const SizedBox(height: 24),

          // Avatar al centro
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, size: 50, color: Colors.white),
            ),
          ),

          const SizedBox(height: 32),

          // Campi Dati (Layout di sola lettura)
          _buildInfoRow("Nome Utente", "${user.firstName ?? ''} ${user.lastName ?? ''}".toUpperCase()),
          _buildInfoRow("Email", user.email ?? "-"),
          _buildInfoRow("Azienda", user.company?? "-"),
          _buildInfoRow("Telefono", user.phone ?? "-"),
          _buildInfoRow("Indirizzo", user.address ?? "Non specificato"),
          // Usa registrationDate se esiste nel DTO, altrimenti un placeholder
          _buildInfoRow("Data Registrazione", "15 Gennaio 2025"),

          const SizedBox(height: 40),

          // --- BOTTONI FOOTER ---
          // --- BOTTONI FOOTER CORRETTI ---
          Row(
            children: [
              // CASO A: C'è il tasto Scarica (Committente)
              if (showDownload)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text("Scarica Doc", style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                )
              // CASO B: NON c'è il tasto (Interno) -> Uso Spacer per spingere gli altri a destra
              else
                const Spacer(),

              const SizedBox(width: 12),

              // Tasto Chiudi
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text("Chiudi"),
              ),

              const SizedBox(width: 12),

              // Tasto Modifica
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        user: user,
                        userService: userService,
                        role: role,
                        isInternal: !showDownload, // Invertiamo la logica
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D0D1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                ),
                child: const Text("Modifica Profilo"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}