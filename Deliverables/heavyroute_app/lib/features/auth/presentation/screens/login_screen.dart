import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _doLogin() async {
    setState(() => _isLoading = true);

    // TODO: AuthService.login(...)
    // Per ora simuliamo:
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Se ok, vai alla dashboard
    if (mounted) {
      // Navigator.pushReplacement(...)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login simulato OK")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Per evitare overflow
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LOGO (Come PNG o SVG)
              // Image.asset('assets/images/logo.png', height: 100),
              const Icon(Icons.local_shipping, size: 80, color: Colors.blue),

              const SizedBox(height: 40),

              const Text(
                "Benvenuto in HeavyRoute",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              // CAMPI DI TESTO
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 24),

              // BOTTONE
              ElevatedButton(
                onPressed: _isLoading ? null : _doLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("ACCEDI"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}