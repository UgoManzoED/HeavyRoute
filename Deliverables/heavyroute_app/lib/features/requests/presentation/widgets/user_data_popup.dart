import 'package:flutter/material.dart';
import '../../../auth/services/user_service.dart';
import '../../../auth/models/user_dto.dart';

class UserDataPopup extends StatefulWidget {
  final UserService userService;
  const UserDataPopup({super.key, required this.userService});

  @override
  State<UserDataPopup> createState() => _UserDataPopupState();
}

class _UserDataPopupState extends State<UserDataPopup> {
  final _formKey = GlobalKey<FormState>();
  late Future<UserDTO?> _userFuture;

  // Variabili di stato
  bool _isEditing = false;
  bool _isSaving = false;
  UserDTO? _originalUser;

  // Controller
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = widget.userService.getCurrentUser();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await widget.userService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _originalUser = user;
        _firstNameCtrl.text = user.firstName ?? '';
        _lastNameCtrl.text = user.lastName ?? '';
        _emailCtrl.text = user.email ?? '';
        _phoneCtrl.text = user.phone ?? '';
        _companyCtrl.text = user.company ?? '';
        _addressCtrl.text = user.address ?? '';
      });
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Annulla modifiche e ripristina valori originali
      if (_originalUser != null) {
        _firstNameCtrl.text = _originalUser!.firstName ?? '';
        _lastNameCtrl.text = _originalUser!.lastName ?? '';
        _emailCtrl.text = _originalUser!.email ?? '';
        _phoneCtrl.text = _originalUser!.phone ?? '';
        _companyCtrl.text = _originalUser!.company ?? '';
        _addressCtrl.text = _originalUser!.address ?? '';
      }
    }
    setState(() => _isEditing = !_isEditing);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder<UserDTO?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Nessun dato utente trovato."));
          }

          final user = snapshot.data!;
          return _buildContent(user);
        },
      ),
    );
  }

  Widget _buildContent(UserDTO user) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dati Utente',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEditing ? 'Modifica i tuoi dati personali' : 'Visualizza e modifica le tue informazioni',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_isEditing)
                      IconButton(
                        onPressed: _isSaving ? null : _toggleEdit,
                        icon: const Icon(Icons.close),
                        tooltip: 'Annulla',
                      ),
                    IconButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Avatar
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

            // Sezione: Dati Personali
            _buildSection(
              title: 'Dati Personali',
              icon: Icons.person_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Nome',
                        value: user.firstName ?? '',
                        controller: _firstNameCtrl,
                        enabled: _isEditing,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        label: 'Cognome',
                        value: user.lastName ?? '',
                        controller: _lastNameCtrl,
                        enabled: _isEditing,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Email',
                  value: user.email ?? '',
                  controller: _emailCtrl,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Telefono',
                  value: user.phone ?? '',
                  controller: _phoneCtrl,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sezione: Dati Aziendali
            _buildSection(
              title: 'Dati Aziendali',
              icon: Icons.business_outlined,
              children: [
                _buildField(
                  label: 'Azienda',
                  value: user.company ?? '',
                  controller: _companyCtrl,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Indirizzo',
                  value: user.address ?? '',
                  controller: _addressCtrl,
                  enabled: _isEditing,
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Bottoni Footer
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : _toggleEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Text('Annulla', style: TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Salva Modifiche'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Chiudi'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _toggleEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modifica Dati'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF0D0D1A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D0D1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    if (!enabled && controller.text.isEmpty) {
      controller.text = value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: value.isEmpty ? 'Non specificato' : null,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: enabled ? const Color(0xFFF3F4F6) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) {
            if (label == 'Email' && v != null && v.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(v)) {
                return 'Inserisci un\'email valida';
              }
            }
            return null;
          },
        ),
      ],
    );
  }


  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userData = UserDTO(
      firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      company: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    );

    final success = await widget.userService.updateUser(userData);

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dati utente aggiornati con successo'),
            backgroundColor: Colors.green,
          ),
        );
        // Ricarica i dati aggiornati
        _userFuture = widget.userService.getCurrentUser();
        await _loadUserData();
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante l\'aggiornamento dei dati'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}