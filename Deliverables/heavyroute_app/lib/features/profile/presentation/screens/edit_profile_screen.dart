import 'package:flutter/material.dart';
import '../../../auth/models/user_dto.dart';
// Importa i tre tab che abbiamo appena creato (o assicurati che siano visibili)
import '../../../auth/services/user_service.dart';
import '../widget/personal_data_tab.dart';
import '../widget/company_data_tab.dart';
import '../widget/security_tab.dart';

class EditProfileScreen extends StatefulWidget {
  final UserDTO user; // Passiamo l'utente per mostrare avatar e nome nell'header
  final UserService userService;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.userService,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller per 3 schede
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usiamo Scaffold bianco per coprire tutto lo schermo
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Grigio chiarissimo di sfondo
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          // 1. HEADER PROFILO (Avatar, Nome, Ruolo)
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // 2. TAB BAR (Menu di navigazione a pillola)
          _buildCustomTabBar(),

          const SizedBox(height: 24),

          // 3. CONTENUTO DELLE SCHEDE (Dinamico)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Qui inseriamo i moduli che riempiremo dopo
                PersonalDataTab(),
                CompanyDataTab(),
                SecurityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS UI ---

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      leadingWidth: 200, // Spazio per il testo "Torna alla dashboard"
      leading: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
        label: const Text("Torna alla Dashboard", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20)),
      ),
      actions: [
        // Logo piccolo a destra (placeholder)
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(Icons.local_shipping, color: Colors.blue[900], size: 28),
        )
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D1A), // Dark Navy
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                // Iniziali (es. Mario Rossi -> MR)
                "${widget.user.firstName?[0] ?? ''}${widget.user.lastName?[0] ?? ''}".toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Info Testuali
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.user.firstName} ${widget.user.lastName}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.email ?? "",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              // Badge Ruolo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Committente", // Questo potresti prenderlo dinamicamente
                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600, fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Center(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Sfondo grigio della barra
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: TabBar(
          controller: _tabController,
          // Stile dell'indicatore (la pillola bianca che si muove)
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          labelColor: Colors.black87, // Testo selezionato
          unselectedLabelColor: Colors.grey[600], // Testo non selezionato
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent, // Rimuove la linea sotto classica
          tabs: const [
            _MyTabItem(icon: Icons.person_outline, label: "Personali"),
            _MyTabItem(icon: Icons.business, label: "Aziendali"),
            _MyTabItem(icon: Icons.lock_outline, label: "Sicurezza"),
          ],
        ),
      ),
    );
  }
}

// Widget helper per creare i singoli tab con icona e testo
class _MyTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MyTabItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}