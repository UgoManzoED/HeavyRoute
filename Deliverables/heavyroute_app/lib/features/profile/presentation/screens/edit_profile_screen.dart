import 'package:flutter/material.dart';
import '../../../auth/models/user_dto.dart';
import '../../../auth/services/user_service.dart';
import '../widget/personal_data_tab.dart';
import '../widget/company_data_tab.dart';
import '../widget/security_tab.dart';

class EditProfileScreen extends StatefulWidget {
  final UserDTO user;
  final UserService userService;
  final String? role;
  final bool isInternal;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.userService,
    required this.role,
    required this.isInternal,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // La lunghezza del controller deve corrispondere esattamente al numero di widget nella TabBar
    _tabController = TabController(
        length: widget.isInternal ? 2 : 3,
        vsync: this
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildCustomTabBar(),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PersonalDataTab(user: widget.user),
                // Se è interno, questo widget non viene proprio creato
                if (!widget.isInternal) CompanyDataTab(user: widget.user),
                const SecurityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- METODI HELPER UI ---

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      leadingWidth: 200,
      leading: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
        label: const Text("Torna alla Dashboard",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20)),
      ),
      actions: [
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
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D1A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${widget.user.firstName?[0] ?? ''}${widget.user.lastName?[0] ?? ''}".toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 24),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.role ?? "Utente",
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          // RIMOSSO 'const' qui perché la lista ora è dinamica
          tabs: [
            const _MyTabItem(icon: Icons.person_outline, label: "Personali"),
            // IL TOCCO MAGICO: Aggiunge il tab Aziendali solo se NON è interno
            if (!widget.isInternal)
              const _MyTabItem(icon: Icons.business, label: "Aziendali"),
            const _MyTabItem(icon: Icons.lock_outline, label: "Sicurezza"),
          ],
        ),
      ),
    );
  }
}

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