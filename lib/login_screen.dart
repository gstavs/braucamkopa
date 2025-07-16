// lib/login_screen.dart
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Uncomment if you use Provider for Theme or other global state accessed here
import 'main.dart'; // To navigate to MyHomePage

// VERY IMPORTANT: Define the global variable HERE at the top level.
// This makes it accessible to any file that imports login_screen.dart (like main.dart).
String? currentUserEmailForTesting;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();

    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lūdzu, ievadiet e-pasta adresi.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Set the global variable based on the entered email
    currentUserEmailForTesting = email.toLowerCase(); // Use toLowerCase for consistency

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    });
  }

  void _loginAsGuest() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    currentUserEmailForTesting = "guest@test.com"; // Any non-admin email

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- MODIFIED PART ---
              Image.asset(
                'assets/images/logo.png', // <- CHANGE THIS PATH if your logo is elsewhere or named differently
                height: 80, // Adjust size as needed
                // width: 150, // You can also set a width if you prefer
              ),
              // --- END OF MODIFIED PART ---
              const SizedBox(height: 20),
              Text(
                'Laipni lūdzam!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Piesakieties, lai turpinātu',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-pasts',
                  hintText: 'user@test.com / admin@test.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Parole (jebkāda testam)',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Pieslēgties'),
              ),
              const SizedBox(height: 15),
              _isLoading
                  ? const SizedBox.shrink()
                  : TextButton(
                onPressed: _loginAsGuest,
                child: Text(
                  'Turpināt kā viesis',
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
