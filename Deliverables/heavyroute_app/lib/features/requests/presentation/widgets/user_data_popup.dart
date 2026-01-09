import 'package:flutter/material.dart';
import '../../../auth/services/user_service.dart';
import '../../../auth/models/user_dto.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';

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
        _firstNameCtrl.text = user.firstName ?? '';
        _lastNameCtrl.text = user.lastName ?? '';
        _emailCtrl.text = user.email ?? '';
        _phoneCtrl.text = user.phone ?? '';
        _companyCtrl.text = user.company ?? '';
        _addressCtrl.text = user.address ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (!snapshot.hasData) return const Text("Nessun dato utente trovato.");

          final user = snapshot.data!;

          // Se siamo in modalità modifica, mostriamo il form vecchio stile (o uno simile)
          if (_isEditing) {
            return _buildEditForm(user);
          }

          // Altrimenti mostriamo la VIEW MODE (Identica alla tua foto)
          return _buildViewMode(user);
        },
      ),
    );
  }

  // --- VISTA PROFILO (Come da foto) ---
  Widget _buildViewMode(UserDTO user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con Titolo e tasto X
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profilo Utente', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('I tuoi dati personali e informazioni aziendali',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Avatar Centrale
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D1A), // Dark Navy
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, size: 50, color: Colors.white),
          ),
        ),

        const SizedBox(height: 32),

        // Lista Dati
        _buildInfoLabel("Nome Utente", "${user.firstName} ${user.lastName}".toUpperCase()),
        _buildInfoLabel("Email", user.email ?? "-"),
        _buildInfoLabel("Azienda", user.company ?? "HeavyRoute S.r.l."), // Fallback se null
        _buildInfoLabel("Telefono", user.phone ?? "+39 --"),
        _buildInfoLabel("Indirizzo", user.address ?? "Via della Logistica 42, Milano"),

        // Campo fittizio o da aggiungere al DTO se serve
        _buildInfoLabel("Data Registrazione", "15 Gennaio 2025"),

        const SizedBox(height: 40),

        // Bottoni Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tasto Scarica Doc
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: const Text("Scarica Documentazione"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 12),

            // Tasto Chiudi
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Chiudi"),
            ),
            const SizedBox(width: 12),

            // Tasto Modifica
            ElevatedButton(
              onPressed: () {
                // 1. Chiudiamo il popup attuale
                Navigator.pop(context);

                // 2. Navighiamo verso la nuova schermata a schede
                // Passiamo l'oggetto 'user' che abbiamo già nel FutureBuilder
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: user, userService: widget.userService),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0D1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Modifica Profilo"),
            ),
          ],
        )
      ],
    );
  }

  // Widget helper per le righe di testo (Label grigia, Valore nero)
  Widget _buildInfoLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  // --- FORM DI MODIFICA (Logica esistente, layout semplificato) ---
  Widget _buildEditForm(UserDTO user) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Modifica Profilo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _isEditing = false), // Torna alla vista
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Campi Input
            Row(
              children: [
                Expanded(child: _buildInput("Nome", _firstNameCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildInput("Cognome", _lastNameCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput("Telefono", _phoneCtrl),
            const SizedBox(height: 16),
            _buildInput("Azienda", _companyCtrl),
            const SizedBox(height: 16),
            _buildInput("Indirizzo", _addressCtrl),

            const SizedBox(height: 32),

            // Bottoni Azione Edit
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text("Annulla", style: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0D1A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Crea oggetto DTO aggiornato
    final userData = UserDTO(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      phone: _phoneCtrl.text,
      company: _companyCtrl.text,
      address: _addressCtrl.text,
      // Manteniamo email originale
      email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
    );

    final success = await widget.userService.updateUser(userData);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        // Ricarica e torna alla vista
        await _loadUserData();
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profilo aggiornato!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore aggiornamento'), backgroundColor: Colors.red));
      }
    }
  }
}