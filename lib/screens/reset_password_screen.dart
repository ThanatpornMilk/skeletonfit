import 'package:flutter/material.dart';
import '../widgets/radial_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_back_button.dart'; 

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color.fromRGBO(46, 146, 101, 1);
    const darkGreen = Color.fromRGBO(30, 122, 66, 1);

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
                  // Header
                  Column(
                    children: [
                      const CustomBackButton(), 
                      const SizedBox(height: 20),
                      _buildLogo(green, darkGreen),
                      const SizedBox(height: 30),
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Enter your email and new password",
                        style: TextStyle(
                          color: Color.fromRGBO(156, 163, 175, 1),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),

                  // Form
                  Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _newPasswordController,
                        hintText: "New Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscureText: _obscureNew,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNew = !_obscureNew;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: "Confirm Password",
                        icon: Icons.lock_reset,
                        isPassword: true,
                        obscureText: _obscureConfirm,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildResetButton(green, darkGreen),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Remember your password? ",
                        style: TextStyle(
                          color: Color.fromRGBO(156, 163, 175, 1),
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color.fromRGBO(46, 146, 101, 1),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
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

  Widget _buildLogo(Color green, Color darkGreen) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [green, darkGreen]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.lock_reset, color: Colors.white, size: 40),
    );
  }

  Widget _buildResetButton(Color green, Color darkGreen) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [green, darkGreen]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          final email = _emailController.text.trim();
          final newPassword = _newPasswordController.text.trim();
          final confirm = _confirmPasswordController.text.trim();

          if (newPassword != confirm) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Passwords do not match")),
            );
            return;
          }

          debugPrint("Reset for $email with $newPassword");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
