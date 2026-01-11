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
    final users = await _userService.getInternalUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Container e Header rimangono uguali a prima)
    return Container(
      // ... stile ...
      child: Column(
        children: [
          // ... Titoli e Filtri ...
          const SizedBox(height: 20),
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

  // ... _buildFilters ...

  Widget _buildUserTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Table(
        // ... columnWidths ...
        children: [
          _buildHeaderRow(),
          ..._users.map((user) => _buildDataRow(context, user)).toList(),
        ],
      ),
    );
  }

  // ... _buildHeaderRow ...

  // --- PUNTO CRUCIALE: Mappatura del nuovo UserModel ---
  TableRow _buildDataRow(BuildContext context, UserModel user) {
    // Convertiamo l'Enum in stringa leggibile (es. UserRole.LOGISTIC_PLANNER -> "Logistic Planner")
    // O semplicemente usiamo user.role.name se ti va bene "LOGISTIC_PLANNER"
    String roleString = user.role.name.replaceAll('_', ' ');

    // Convertiamo il booleano active in testo
    String statusString = user.active ? 'Attivo' : 'Sospeso';

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user.id.toString())),
        // Usa il getter intelligente che hai creato nel modello
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user.fullName)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user.email)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _buildRoleChip(roleString)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _buildStatusChip(statusString)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note),
              // Passa l'intero oggetto UserModel al popup di modifica
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EditUserPopup(user: user)
              ),
            ),
            const Icon(Icons.block, color: Colors.red, size: 20),
          ],
        ),
      ],
    );
  }

// ... _buildRoleChip e _buildStatusChip rimangono uguali ...
}