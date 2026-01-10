import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers per i campi di testo
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _companyController = TextEditingController();
  final _vatController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Stato della checkbox
  bool _acceptedTerms = false;
  // Stato per il caricamento (futuro)
  bool _isLoading = false;
  bool _isHoveringLogin = false;

  @override
  void dispose() {
    // Pulizia dei controller
    _nameController.dispose();
    _surnameController.dispose();
    _companyController.dispose();
    _vatController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    // TODO: Implementare la logica di registrazione nel prossimo step
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Devi accettare i termini e condizioni per proseguire.")),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Simulazione
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Funzionalità di registrazione in sviluppo")));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sfondo generale della pagina (Grigio chiaro/bluastro come da login)
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container per limitare la larghezza
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550), // Leggermente più largo del login per i doppi campi
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      TextButton.icon(
                        onPressed: () {
                          // MODIFICA: Invece di Navigator.pop(context), usiamo questo:
                          // Rimuove tutte le rotte precedenti e va alla rotta base '/' (Landing Page)
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                        icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                        label: const Text(
                          "Torna alla Home",
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                      ),

                      const SizedBox(height: 20),

                      // Card Bianca Centrale
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Logo
                            Column(
                              children: [
                                Icon(Icons.local_shipping_rounded, size: 48, color: const Color(0xFF0D0D1A)),
                                const SizedBox(height: 4),
                                const Text(
                                  "HEAVY\nROUTE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      height: 0.9,
                                      color: Color(0xFF0D0D1A),
                                      letterSpacing: 1.0),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Titoli
                            const Text(
                              "Registrati su HeavyRoute",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Crea un account per richiedere consegne speciali e gestire le tue spedizioni",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                            ),

                            const SizedBox(height: 32),

                            // --- CAMPI DEL FORM ---
                            // Riga 1: Nome e Cognome
                            Row(
                              children: [
                                Expanded(child: _buildInputField("Nome *", _nameController, hint: "Mario")),
                                const SizedBox(width: 20),
                                Expanded(child: _buildInputField("Cognome *", _surnameController, hint: "Rossi")),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Riga 2: Azienda e Partita IVA
                            Row(
                              children: [
                                Expanded(child: _buildInputField("Azienda / Ragione Sociale *", _companyController, hint: "Nome della tua azienda")),
                                const SizedBox(width: 20),
                                Expanded(child: _buildInputField("Partita IVA *", _vatController, hint: "IT12345678901")),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Riga 3: Email e Telefono
                            Row(
                              children: [
                                Expanded(child: _buildInputField("Email *", _emailController, hint: "nome@esempio.it", keyboardType: TextInputType.emailAddress)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildInputField("Telefono *", _phoneController, hint: "+39 333 123 4567", keyboardType: TextInputType.phone)),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Riga 4: Password e Conferma
                            Row(
                              children: [
                                Expanded(child: _buildInputField("Password *", _passwordController, hint: "********", isPassword: true)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildInputField("Conferma Password *", _confirmPasswordController, hint: "********", isPassword: true)),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Checkbox Termini
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _acceptedTerms,
                                    activeColor: const Color(0xFF0D0D1A),
                                    onChanged: (v) => setState(() => _acceptedTerms = v!),
                                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                      children: [
                                        TextSpan(text: "Accetto i "),
                                        TextSpan(text: "termini e condizioni", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D0D1A))),
                                        TextSpan(text: " e la "),
                                        TextSpan(text: "privacy policy", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D0D1A))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Bottone Crea Account
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D0D1A), // Dark Navy
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Crea Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Link Accedi con effetto Hover
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Hai già un account? ", style: TextStyle(color: Color(0xFF6B7280))),
                                MouseRegion(
                                  onEnter: (_) => setState(() => _isHoveringLogin = true),
                                  onExit: (_) => setState(() => _isHoveringLogin = false),
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context), // Torna al login
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        color: const Color(0xFF0D0D1A),
                                        fontWeight: FontWeight.bold,
                                        // Sottolineatura dinamica
                                        decoration: _isHoveringLogin ? TextDecoration.underline : TextDecoration.none,
                                      ),
                                      child: const Text("Accedi"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer Contatti
                      const Center(
                        child: Text("Hai bisogno di aiuto? Contattaci al +39 02 1234 5678",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper per i campi di input (Label + TextField grigio)
  Widget _buildInputField(String label, TextEditingController ctrl, {String? hint, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F4F6), // Grigio chiaro input
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, // Nessun bordo
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}