import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart'; // <--- Assicurati che l'import sia corretto
import '../../../../common/models/enums.dart';    // Per i ruoli se servono

class EditUserPopup extends StatefulWidget {
  // 1. Aggiungiamo il parametro 'user'.
  // Lo rendiamo opzionale (?) così possiamo usare questo stesso popup
  // sia per CREARE (user = null) che per MODIFICARE (user = oggetto).
  final UserModel? user;

  const EditUserPopup({
    super.key,
    this.user,
  });

  @override
  State<EditUserPopup> createState() => _EditUserPopupState();
}

class _EditUserPopupState extends State<EditUserPopup> {
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di testo
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // 2. Pre-compiliamo i campi se stiamo modificando un utente esistente
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capiamo se stiamo modificando o creando
    final isEditing = widget.user != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500, // Larghezza fissa per desktop/web
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TITOLO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Modifica Utente" : "Nuovo Utente",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- CAMPI ---
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Nome", _firstNameController),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField("Cognome", _lastNameController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController, isEmail: true),
              const SizedBox(height: 16),
              _buildTextField("Telefono", _phoneController),

              const SizedBox(height: 32),

              // --- BOTTONI AZIONE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                    child: const Text("Annulla"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                    child: Text(isEditing ? "Salva Modifiche" : "Crea Utente"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) return "Campo obbligatorio";
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementare la chiamata al Service per aggiornare (PUT) o creare (POST)

      // Esempio logica:
      // final updatedUser = UserModel(
      //   id: widget.user?.id ?? 0,
      //   firstName: _firstNameController.text,
      //   ...
      // );
      // _userService.updateUser(updatedUser);

      Navigator.pop(context); // Chiude il popup

      // Feedback utente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Operazione salvata (Mock)")),
      );
    }
  }
}