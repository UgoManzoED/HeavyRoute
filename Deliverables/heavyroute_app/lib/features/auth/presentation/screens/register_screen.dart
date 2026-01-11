import 'package:flutter/material.dart';
import 'package:heavyroute_app/features/auth/presentation/screens/widgets/registration_form.dart';
import '../../models/dto/auth_requests.dart';
import '../../services/registration_service.dart';

/// Schermata principale per la registrazione di un nuovo cliente.
/// <p>
/// <b>Responsabilità:</b>
/// 1. Gestisce il ciclo di vita dei Controller di testo (Creazione/Distruzione).
/// 2. Orchestra la validazione ibrida (Client-side + Server-side).
/// 3. Gestisce lo stato della chiamata asincrona (Loading, Success, Error).
/// </p>
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registrationService = RegistrationService();
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERS ---
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _companyController = TextEditingController();
  final _vatController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pecController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;
  Map<String, String?> _serverErrors = {};

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _companyController.dispose();
    _vatController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pecController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Logica Core di Registrazione
  Future<void> _handleRegister() async {
    // 1. Reset degli errori precedenti
    setState(() => _serverErrors = {});

    // 2. Validazione Locale (Client-Side)
    if (!_formKey.currentState!.validate()) return;

    // 3. Validazioni Custom
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Devi accettare i termini.")));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le password non coincidono.")));
      return;
    }

    // 4. Inizio Chiamata di Rete
    setState(() => _isLoading = true);

    // Creazione del DTO
    final dto = CustomerRegistrationRequest(
      username: _usernameController.text.trim(),
      firstName: _nameController.text.trim(),
      lastName: _surnameController.text.trim(),
      companyName: _companyController.text.trim(),
      vatNumber: _vatController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      pec: _pecController.text.trim(),
      password: _passwordController.text,
    );

    // Chiamata al Service
    // Ritorna null se successo, oppure una Map<String, dynamic> se ci sono errori.
    final errors = await _registrationService.registerClient(dto);

    // Fine Chiamata
    setState(() => _isLoading = false);

    if (mounted) {
      if (errors == null) {
        // SUCCESSO: Mostra popup e naviga al login
        _showSuccessDialog();
      } else {
        // ERRORE BACKEND: Mapping degli errori
        print("ERRORI RICEVUTI DAL SERVICE: $errors");
        setState(() {
          // Convertiamo gli errori in stringhe per sicurezza e aggiorniamo lo stato.
          // Questo causerà il rebuild del widget 'RegistrationForm', che mostrerà
          // il testo rosso sotto i campi specifici (es. sotto la VAT o la Email).
          _serverErrors = errors.map((key, value) => MapEntry(key, value.toString()));
        });
        if (_serverErrors.containsKey('global')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_serverErrors['global']!), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Registrazione Inviata"),
        content: const Text("Account creato con successo!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            child: const Text("Torna al Login"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasto Indietro
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                      icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                      label: const Text("Torna alla Home", style: TextStyle(color: Colors.black87)),
                    ),
                    const SizedBox(height: 20),

                    // --- COMPONENTE FORM SEPARATO ---
                    RegistrationForm(
                      usernameCtrl: _usernameController,
                      nameCtrl: _nameController,
                      surnameCtrl: _surnameController,
                      companyCtrl: _companyController,
                      vatCtrl: _vatController,
                      emailCtrl: _emailController,
                      pecCtrl: _pecController,
                      phoneCtrl: _phoneController,
                      addressCtrl: _addressController,
                      passwordCtrl: _passwordController,
                      confirmPasswordCtrl: _confirmPasswordController,
                      serverErrors: _serverErrors,
                      acceptedTerms: _acceptedTerms,
                      onTermsChanged: (v) => setState(() => _acceptedTerms = v!),
                      onSubmit: _handleRegister,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}