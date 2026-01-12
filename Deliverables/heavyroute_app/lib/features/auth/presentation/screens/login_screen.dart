import 'package:flutter/material.dart';
import 'package:heavyroute_app/features/gestore/screens/account_manager_screen.dart';
import '../../services/auth_service.dart';
import 'package:heavyroute_app/core/storage/token_storage.dart';
import 'package:heavyroute_app/features/requests/presentation/screens/customer_dashboard_screen.dart';
import 'package:heavyroute_app/features/auth/presentation/screens/register_screen.dart';
import 'package:heavyroute_app/features/planner/presentation/screens/planner_dashboard_screen.dart';
import 'package:heavyroute_app/features/coordinator/screens/coordinator_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller e Servizi
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Stato UI
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isHoveringRegister = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci email e password"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    // Chiamata al Service
    final result = await _authService.login(email, password);

    setState(() => _isLoading = false);

    print("🔵 Risultato AuthService: $result");

    if (result != null && result != false) {
      // Recuperiamo il ruolo dal TokenStorage
      final role = await TokenStorage.getRole();
      print("🔵 Ruolo recuperato dallo storage: $role");

      if (mounted) {
        String? routeName;

        // --- AGGIUNTA BLOCCO DRIVER QUI SOTTO ---
        if (role == 'DRIVER' || role == 'ROLE_DRIVER') {
          routeName = '/driver_dashboard';
        }
        // ----------------------------------------
        else if (role == 'LOGISTIC_PLANNER' || role == 'ROLE_LOGISTIC_PLANNER') {
          routeName = '/planner_dashboard';
        } else if (role == 'CUSTOMER' || role == 'ROLE_CUSTOMER') {
          routeName = '/customer_dashboard';
        } else if (role == 'ACCOUNT_MANAGER' || role == 'ROLE_ACCOUNT_MANAGER') {
          routeName = '/account_manager';
        } else if (role == 'TRAFFIC_COORDINATOR' || role == 'ROLE_TRAFFIC_COORDINATOR') {
          routeName = '/traffic_dashboard';
        }

        if (routeName != null) {
          print("🚀 Navigazione verso: $routeName");
          Navigator.pushNamedAndRemoveUntil(
              context,
              routeName,
                  (route) => false
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ruolo non riconosciuto: $role")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Fallito: Credenziali errate"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sfondo generale della pagina (Grigio chiaro/bluastro come da foto)
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container per limitare la larghezza su tablet/web
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tasto "Torna alla Home"
                      TextButton.icon(
                        onPressed: () {
                          // Sostituisce il Login con la Landing. Nessun "Indietro" possibile.
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                        label: const Text("Torna alla Home", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
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
                            // Logo (Ricostruito per essere simile alla foto)
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
                                      letterSpacing: 1.0
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Titoli
                            const Text(
                              "Accedi a HeavyRoute",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Inserisci le tue credenziali per accedere al tuo account",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                            ),

                            const SizedBox(height: 32),

                            // Campo Email
                            _buildInputLabel("Email"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: "nome@esempio.it",
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),

                            // Campo Password con link "Dimenticata?"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInputLabel("Password"),
                                GestureDetector(
                                  onTap: () {}, // TODO: Implementare recupero psw
                                  child: const Text(
                                    "Password dimenticata?",
                                    style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: "********",
                              isPassword: true,
                            ),

                            const SizedBox(height: 32),

                            // Bottone Accedi
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D0D1A), // Dark Navy
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Accedi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Non hai un account? ", style: TextStyle(color: Color(0xFF6B7280))),
                                MouseRegion(
                                  onEnter: (_) => setState(() => _isHoveringRegister = true),
                                  onExit: (_) => setState(() => _isHoveringRegister = false),
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                      );
                                    },
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        color: const Color(0xFF0D0D1A),
                                        fontWeight: FontWeight.bold,
                                        // Aggiunge la sottolineatura se il mouse è sopra (_isHoveringRegister è true)
                                        decoration: _isHoveringRegister ? TextDecoration.underline : TextDecoration.none,
                                      ),
                                      child: const Text("Registrati"),
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
                        child: Column(
                          children: [
                            Text("Problemi con l'accesso? Contattaci al +39 02 1234 5678",
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                            SizedBox(height: 4),
                          ],
                        ),
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

  // Widget Helper per Label
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151)),
      ),
    );
  }

  // Widget Helper per Input Fields (Sfondo grigio, no bordi visibili)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
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
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
      ),
    );
  }
}