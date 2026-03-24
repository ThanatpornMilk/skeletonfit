import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/radial_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/button.dart';
import 'verify_email_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  final _passwordRegex = RegExp(
    r'''^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\|\~\\\-=`{}\[\]:";'<>?,./]).{8,}$'''
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSignup() async {
    if (_isLoading) return;

    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    bool valid = true;

    // Validate name
    if (name.isEmpty || name.length < 3) {
      _nameError = "Username must be at least 3 characters";
      valid = false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _emailError = "Invalid email format";
      valid = false;
    }

    // Validate password
    if (!_passwordRegex.hasMatch(password)) {
      _passwordError =
          "Password must be ≥8 chars and include upper, lower, number, special char";
      valid = false;
    } else if (password == name) {
      _passwordError = "Password cannot be the same as username";
      valid = false;
    }

    // Confirm password
    if (password != confirm) {
      _confirmError = "Passwords do not match";
      valid = false;
    }

    if (!valid) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:3000/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": name,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Signup successful")),
        );

        if (data["needs_verification"] == true ||
            (data["message"]?.toString().toLowerCase().contains("verify") ?? false)) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyEmailScreen(email: email)),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Signup failed")),
        );
      }
    } catch (e) {
      debugPrint("Signup error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Network error")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RadialBackground(
        bg: const Color(0xFF181717),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomBackButton(),
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 30),
                const Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _nameController,
                  hintText: "Username",
                  icon: Icons.person_outline,
                  errorText: _nameError,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  errorText: _passwordError,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _confirmController,
                  hintText: "Confirm Password",
                  icon: Icons.lock_reset,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  onToggleVisibility: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  errorText: _confirmError,
                ),
                const SizedBox(height: 30),
                Button(
                  onPressed: _isLoading ? null : _validateAndSignup,
                  isEnabled: !_isLoading,
                  buttonText: _isLoading ? "Processing..." : "Sign Up",
                ),
                const SizedBox(height: 30),
                _LoginText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E9265), Color(0xFF1E7A42)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(46, 146, 101, 0.3),
              blurRadius: 20,
              offset: Offset(0, 10))
        ],
      ),
      child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 40),
    );
  }
}

class _LoginText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            "Login",
            style: TextStyle(
                color: Color(0xFF2E9265),
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ),
      ],
    );
  }
}
