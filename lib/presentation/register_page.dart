import 'package:app_resepku/data/repository/user_repository.dart';
import 'package:app_resepku/data/usecase/request/register_request.dart';
import 'package:app_resepku/presentation/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtr = TextEditingController();
  final _usernameCtr = TextEditingController();
  final _passwordCtr = TextEditingController();

  final _repository = UserRepository();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFB8792F),
        elevation: 0,
        leadingWidth: 120,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage('assets/Logo_ResepKu.png'),
            ),
          ],
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _HeaderSection(),
              const SizedBox(height: 40),
              _RegisterCard(
                formKey: _formKey,
                emailCtr: _emailCtr,
                usernameCtr: _usernameCtr,
                passwordCtr: _passwordCtr,
                obscure: _obscure,
                onToggle: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
                onRegister: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await _repository.register(
          RegisterRequest(
            name: _usernameCtr.text,
            email: _emailCtr.text,
            password: _passwordCtr.text,
            passwordConfirmation: _passwordCtr.text,
          ),
        );

        print("Success: ${response.success}");
        print("Message: ${response.message}");

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registrasi berhasil, silakan login"),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(seconds: 2));

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// Header
class _HeaderSection extends StatelessWidget {
  static const Color primaryBrown = Color(0xFF8B5A2B);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Selamat Datang!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryBrown,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Silakan daftar untuk menggunakan aplikasi ResepKu",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

// Register Card
class _RegisterCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtr;
  final TextEditingController usernameCtr;
  final TextEditingController passwordCtr;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback onRegister;

  static const Color primaryBrown = Color(0xFF8B5A2B);

  const _RegisterCard({
    required this.formKey,
    required this.emailCtr,
    required this.usernameCtr,
    required this.passwordCtr,
    required this.obscure,
    required this.onToggle,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _InputField(
            controller: usernameCtr,
            label: "Username",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 15),
          _InputField(
            controller: emailCtr,
            label: "Email",
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 15),
          _PasswordField(
            controller: passwordCtr,
            obscure: obscure,
            onToggle: onToggle,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "DAFTAR",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Input
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (v) => v!.isEmpty ? "$label tidak boleh kosong" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// Password
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
      validator: (v) => v!.length < 8 ? "Password minimal 8 karakter" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
