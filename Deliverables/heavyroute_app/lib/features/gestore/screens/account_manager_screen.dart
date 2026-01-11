import 'package:flutter/material.dart';
import '../../../../common/heavy_route_app_bar.dart';
import '../../auth/services/user_service.dart';
import '../../auth/models/user_model.dart';
import '../../requests/presentation/widgets/user_data_popup.dart';
import '../widgets/internal_user_list_section.dart';
import '../widgets/create_user_section.dart';

class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({super.key});

  @override
  State<AccountManagerScreen> createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> {
  final UserService _userService = UserService();
  int _activeSectionIndex = 0;

  Future<void> _openProfilePopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = await _userService.getCurrentUser();

      if (mounted) Navigator.pop(context);

      if (user != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: UserDataPopup(
                user: user, // Passiamo l'oggetto modello direttamente
                userService: _userService,
                role: "Gestore Account",
                showDownload: false,
              ),
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossibile recuperare il profilo")),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Errore profilo manager: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: HeavyRouteAppBar(
        subtitle: 'Dashboard Gestore Account',
        isDashboard: true,
        onProfileTap: _openProfilePopup,
      ),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: _activeSectionIndex == 0
                ? const InternalUserListSection()
                : const CreateUserSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      color: const Color(0xFFE5E7EB),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(0, Icons.people_outline, 'Gestione Utenti Interni'),
          const SizedBox(width: 8),
          _buildTabItem(1, Icons.person_add_alt, 'Crea Nuovo Utente'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isActive = _activeSectionIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeSectionIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.black : Colors.grey),
              const SizedBox(width: 8),
              Text(
                  label,
                  style: TextStyle(
                      color: isActive ? Colors.black : Colors.grey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}