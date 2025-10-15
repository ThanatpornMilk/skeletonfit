import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/radial_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await _secureStorage.read(key: 'email');
    final savedPassword = await _secureStorage.read(key: 'password');
    final remember = await _secureStorage.read(key: 'rememberMe');

    if (!mounted) return;

    if (remember == 'true' && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    if (_rememberMe) {
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
      await _secureStorage.write(key: 'rememberMe', value: 'true');
    } else {
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
      await _secureStorage.write(key: 'rememberMe', value: 'false');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndLogin() async {
    if (_isLoading) return;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool valid = true;

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _emailError = "Invalid email format";
      valid = false;
    }

    if (password.isEmpty) {
      _passwordError = "Password cannot be empty";
      valid = false;
    } 
    if (!valid) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("http://10.0.2.2:3000/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!mounted) return; // ป้องกัน context หลัง await

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        await _saveCredentials(email, password);

        if (!mounted) return; // เช็คอีกครั้ง

        final int userId = data['user']['user_id'];
        Provider.of<UserProvider>(context, listen: false).setUser(userId);

        debugPrint("Login success. user_id = $userId");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login successful")),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Login failed")),
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
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
        bg: const Color.fromRGBO(24, 23, 23, 1),
        child: SafeArea(
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(height: 20),
                      _buildLogo(),
                      const SizedBox(height: 30),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Login to your account",
                        style: TextStyle(
                          color: Color.fromRGBO(156, 163, 175, 1),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Email address",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() => _rememberMe = val ?? false);
                                },
                                activeColor: const Color(0xFF2E9265),
                              ),
                              const Text(
                                "Remember Me",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/reset'),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color.fromRGBO(46, 146, 101, 1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Button(
                        onPressed: _isLoading ? null : _validateAndLogin,
                        isEnabled: !_isLoading,
                        buttonText: _isLoading ? "Loading..." : "Login",
                      ),
                    ],
                  ),
                  Column(
                    children: const [
                      SizedBox(height: 30),
                      _Divider(),
                      SizedBox(height: 30),
                      _SignupText(),
                    ],
                  ),
                ],
              ),
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
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.lock_outline, color: Colors.white, size: 40),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color.fromRGBO(55, 65, 81, 1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "or",
            style: TextStyle(
              color: Color.fromRGBO(156, 163, 175, 1),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color.fromRGBO(55, 65, 81, 1))),
      ],
    );
  }
}

class _SignupText extends StatelessWidget {
  const _SignupText();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Color.fromRGBO(156, 163, 175, 1),
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/signup'),
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Color.fromRGBO(46, 146, 101, 1),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
