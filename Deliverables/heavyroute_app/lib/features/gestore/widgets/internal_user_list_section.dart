import 'package:flutter/material.dart';
import '../../auth/services/user_service.dart';
import '../../auth/models/user_model.dart';
import '../../../../common/models/enums.dart';
import 'edit_user_popup.dart';

class InternalUserListSection extends StatefulWidget {
  const InternalUserListSection({super.key});

  @override
  State<InternalUserListSection> createState() => _InternalUserListSectionState();
}

class _InternalUserListSectionState extends State<InternalUserListSection> {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      // Recupera la lista reale dal backend
      final users = await _userService.getInternalUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Errore caricamento utenti: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Ombra leggera per dare profondità
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SEZIONE ---
          const Text('Utenti Interni', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Visualizza, modifica e gestisci tutti gli utenti interni del sistema', style: TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 20),

          // --- FILTRI ---
          _buildFilters(),

          const SizedBox(height: 20),

          // --- TABELLA DATI ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? const Center(child: Text("Nessun utente trovato."))
                : _buildUserTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cerca per username, nome, cognome o email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
            ),
            onChanged: (value) {
              // TODO: Implementare filtro locale sulla lista _users se necessario
            },
          ),
        ),
        const SizedBox(width: 12),
        _buildDropdownFilter('Tutti i ruoli'),
        const SizedBox(width: 12),
        _buildDropdownFilter('Tutti gli stati'),
      ],
    );
  }

  Widget _buildDropdownFilter(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16),
          const SizedBox(width: 8),
          Text(label),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildUserTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),   // ID
          1: FlexColumnWidth(2),   // Nome
          2: FlexColumnWidth(2),   // Email
          3: FlexColumnWidth(1.5), // Ruolo
          4: FlexColumnWidth(1.5), // Stato
          5: FixedColumnWidth(100),// Azioni
        },
        children: [
          _buildHeaderRow(),
          // Mappatura dinamica: per ogni utente nella lista, crea una riga
          ..._users.map((user) => _buildDataRow(context, user)).toList(),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Nome Completo', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Ruolo', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Stato', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Azioni', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildDataRow(BuildContext context, UserModel user) {
    // 1. Gestione Ruolo: Trasforma l'Enum in stringa leggibile
    // Es. UserRole.LOGISTIC_PLANNER -> "LOGISTIC PLANNER"
    String roleString = user.role.name.replaceAll('_', ' ');

    // 2. Gestione Stato: Trasforma il booleano 'active' in testo
    String statusString = user.active ? 'Attivo' : 'Sospeso';

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user.id.toString())),
        // Usa il getter fullName del UserModel
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user.fullName)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user.email)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _buildRoleChip(roleString)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _buildStatusChip(statusString)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditUserPopup(user: user),
              ),
            ),
            // TODO: Implementare logica di disabilitazione
            const Icon(Icons.block, color: Colors.red, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
      child: Text(role, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Attivo' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}