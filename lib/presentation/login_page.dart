import 'package:app_resepku/data/repository/user_repository.dart';
import 'package:app_resepku/data/usecase/request/login_request.dart';
import 'package:app_resepku/presentation/register_page.dart';
import 'package:app_resepku/presentation/home_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtr = TextEditingController();
  final _passCtr = TextEditingController();
  final _repo = UserRepository();

  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await _repo.login(
      LoginRequest(email: _emailCtr.text, password: _passCtr.text),
    );

    if (response.status == 'success') {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(username: response.user.name),
          ),
          (_) => false,
        );
      }
    } else {
      _showMessage("Email atau password salah", Colors.red);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const _LogoSection(),
              const SizedBox(height: 20),
              const _WelcomeText(),
              const SizedBox(height: 40),
              _LoginCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Card
  Widget _LoginCard() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _EmailField(controller: _emailCtr),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _passCtr,
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 24),
          _SubmitButton(onPressed: _submit),
          const SizedBox(height: 16),
          _RegisterRedirect(),
        ],
      ),
    );
  }
}

// Logo
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/Logo_ResepKu.png', width: 220);
  }
}

// Text
class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "Selamat Datang di ResepKu!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB8792F),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Silakan login untuk melanjutkan ke aplikasi ResepKu.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

// Field
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (v) =>
          v == null || !v.contains('@') ? 'Email tidak valid' : null,
      decoration: _inputDecoration(label: "Email", icon: Icons.email_outlined),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (v) => v == null || v.length < 8 ? 'Minimal 8 karakter' : null,
      decoration: _inputDecoration(
        label: "Password",
        icon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// Button
class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFB8792F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "SUBMIT",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Register
class _RegisterRedirect extends StatelessWidget {
  const _RegisterRedirect();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Belum punya akun? ",
          style: TextStyle(color: Colors.black87),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterPage()),
            );
          },
          child: const Text(
            "Daftar di sini",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// Decoration
InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
