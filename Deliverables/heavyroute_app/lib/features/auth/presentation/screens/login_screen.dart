import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _doLogin() async {
    // 1. Validazione Locale
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci username e password")),
      );
      return;
    }

    // 2. Aggiornamento UI
    setState(() => _isLoading = true);

    // 3. Chiamata Asincrona al Service
    final success = await _authService.login(username, password);

    // 4. Ripristino UI
    setState(() => _isLoading = false);

    // 5. Gestione del Risultato
    if (success && mounted) {
      // Naviga alla dashboard (sostituisci con la tua rotta)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Riuscito! Token salvato.")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Credenziali non valide o errore server"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      // 1. Assegno il contenuto principale al parametro 'body'
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
          children: [
            // 2. Campo Username
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16), // Spazio tra i campi

            // 3. Campo Password
            TextField(
              controller: _passwordController,
              obscureText: true, // Nasconde il testo
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24), // Spazio prima del bottone

            // 4. Il tuo Bottone (corretto e inserito nella lista children)
            SizedBox(
              width: double.infinity, // Rende il bottone largo quanto lo schermo
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doLogin,
                child: _isLoading
                // È meglio dare una dimensione fissa allo spinner dentro un bottone
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text("ACCEDI"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}