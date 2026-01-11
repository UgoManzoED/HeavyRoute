import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/user_service.dart';
import '../../../../common/models/enums.dart';

/**
 * Sezione per l'inserimento di un nuovo account per il personale interno.
 * <p>
 * Logica integrata con stile grafico preservato (Wrap, colori custom, info box).
 * </p>
 */
class CreateUserSection extends StatefulWidget {
  const CreateUserSection({super.key});

  @override
  State<CreateUserSection> createState() => _CreateUserSectionState();
}

class _CreateUserSectionState extends State<CreateUserSection> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  bool _isLoading = false;

  // Controllers per i campi
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  UserRole? _selectedRole;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Aggiungo una leggera ombra per staccare dal fondo (opzionale ma consigliato)
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            const Text('Crea Nuovo Utente Interno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Inserisci i dati per creare un nuovo account per il personale interno', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 32),
            const Text('Dati Anagrafici e di Contatto', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // --- FORM GRID (Wrap) ---
            _buildFormGrid(),

            const SizedBox(height: 32),

            // --- INFO BOX ---
            _buildInfoBox(),

            const Spacer(), // Spinge il bottone in basso se c'è spazio
            const SizedBox(height: 20), // Margine sicuro

            // --- BOTTONE AZIONE ---
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createNewUser,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.person_add),
                label: Text(_isLoading ? 'Creazione in corso...' : 'Crea Utente e Invia Credenziali'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64748B), // Colore originale preservato (Slate)
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFormGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        // Username
        _buildTextField(
            label: 'Username *',
            hint: 'es. m.rossi',
            controller: _usernameController
        ),

        // Ruolo (Dropdown Custom)
        _buildRoleDropdown(width: 300),

        // Nome
        _buildTextField(
            label: 'Nome *',
            hint: 'Mario',
            controller: _firstNameController
        ),

        // Cognome
        _buildTextField(
            label: 'Cognome *',
            hint: 'Rossi',
            controller: _lastNameController
        ),

        // Email
        _buildTextField(
            label: 'Email *',
            hint: 'mario.rossi@heavyroute.it',
            controller: _emailController,
            isEmail: true
        ),

        // Telefono
        _buildTextField(
            label: 'Telefono',
            hint: '+39 340 1234567',
            controller: _phoneController
        ),
      ],
    );
  }

  // Widget per i campi di testo normali
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isEmail = false,
    double width = 300
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo obbligatorio";
              if (isEmail && !value.contains("@")) return "Email non valida";
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF9FAFB), // Colore originale preservato
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Widget specifico per il Dropdown del Ruolo
  Widget _buildRoleDropdown({double width = 300}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ruolo *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            items: [
              UserRole.LOGISTIC_PLANNER,
              UserRole.TRAFFIC_COORDINATOR,
              UserRole.ACCOUNT_MANAGER,
              UserRole.DRIVER,
            ].map((role) => DropdownMenuItem(
              value: role,
              child: Text(
                role.toString().split('.').last.replaceAll('_', ' '),
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
            onChanged: (val) => setState(() => _selectedRole = val),
            validator: (val) => val == null ? "Seleziona un ruolo" : null,
            decoration: InputDecoration(
              hintText: 'Seleziona ruolo..',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: const Text(
              'Nota: Dopo la creazione, verranno inviate automaticamente le credenziali temporanee all\'indirizzo email specificato.',
              style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGICA DI SALVATAGGIO ---
  Future<void> _createNewUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newUser = UserModel(
      id: 0,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      active: true,
      role: _selectedRole!,
    );

    final success = await _userService.createInternalUser(newUser);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Reset totale del form
        _formKey.currentState!.reset();
        _usernameController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        setState(() => _selectedRole = null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utente creato con successo!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore: username o email già esistenti."), backgroundColor: Colors.red),
        );
      }
    }
  }
}