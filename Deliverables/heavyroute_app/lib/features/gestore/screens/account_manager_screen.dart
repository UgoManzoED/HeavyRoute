import 'package:flutter/material.dart';
import '../widgets/internal_user_list_section.dart';
import '../widgets/create_user_section.dart';

/**
 * Schermata principale per il Gestore Account.
 * <p>
 * Implementa una navigazione a tab personalizzata per switchare tra
 * la visualizzazione della lista utenti e il form di creazione.
 * </p>
 * @author Roman
 */
class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({super.key});

  @override
  State<AccountManagerScreen> createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> {
  /** Indice della sezione corrente: 0 per Lista, 1 per Creazione */
  int _activeSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
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

  /**
   * Costruisce la AppBar con logo e profilo utente.
   */
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Row(
        children: [
          const Icon(Icons.local_shipping, color: Color(0xFF1E293B)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('HeavyRoute', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Dashboard Gestore Account', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1E293B), size: 30),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  /**
   * Costruisce la barra dei menu (Tab) superiore.
   */
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
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.black : Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}