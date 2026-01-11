import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/user_service.dart';
import '../../../../common/models/enums.dart';

class EditUserPopup extends StatefulWidget {
  final UserModel user; // Obbligatorio: qui si entra solo per modificare

  const EditUserPopup({
    super.key,
    required this.user,
  });

  @override
  State<EditUserPopup> createState() => _EditUserPopupState();
}

class _EditUserPopupState extends State<EditUserPopup> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  bool _isSaving = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Pre-popoliamo con i dati esistenti
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Si adatta al contenuto
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Modifica Utente", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- RUOLO (Sola Lettura) ---
              const Text("Ruolo Aziendale", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  widget.user.role.name.replaceAll('_', ' '),
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // --- CAMPI ANAGRAFICI ---
              Row(
                children: [
                  Expanded(child: _buildTextField("Nome", _firstNameController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Cognome", _lastNameController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController, isEmail: true),
              const SizedBox(height: 16),
              _buildTextField("Telefono", _phoneController),

              const SizedBox(height: 32),

              // --- BOTTONI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                    child: const Text("Annulla"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Salva Modifiche"),
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
          enabled: !_isSaving,
          validator: (value) {
            if (value == null || value.isEmpty) return "Campo obbligatorio";
            if (isEmail && !value.contains("@")) return "Email non valida";
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Manteniamo ID, Ruolo e altri dati invariati
    final updatedUser = UserModel(
      id: widget.user.id,
      username: widget.user.username,
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      role: widget.user.role, // Il ruolo vecchio viene reinviato ma ignorato o non modificato
      active: widget.user.active,
      // Campi opzionali preservati
      serialNumber: widget.user.serialNumber,
      hireDate: widget.user.hireDate,
      licenseNumber: widget.user.licenseNumber,
      status: widget.user.status,
      companyName: widget.user.companyName,
      vatNumber: widget.user.vatNumber,
      pec: widget.user.pec,
      address: widget.user.address,
    );

    final success = await _userService.updateInternalUser(updatedUser.id, updatedUser);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true); // Chiude ritornando TRUE (successo)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utente aggiornato con successo!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore durante l'aggiornamento"), backgroundColor: Colors.red));
      }
    }
  }
}