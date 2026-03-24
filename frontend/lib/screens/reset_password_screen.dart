import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/radial_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  int _resendCountdown = 0;
  Timer? _timer;

  final _passwordRegex = RegExp(
    r'''^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\|\~\\\-=`{}\[\]:";'<>?,./]).{8,}$'''
  );

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter email")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:3000/request-reset-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() => _isOtpSent = true);
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP sent successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Failed to send OTP")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Network error")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (otp.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
      return;
    }

    if (!_passwordRegex.hasMatch(newPassword)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password must be ≥8 chars and include upper, lower, number, special char")));
      return;
    }

    if (newPassword != confirm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:3000/reset-password-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data["message"])));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = data["error"] ?? "Failed to reset password";

        if (error == "New password must be different from the old one") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("New password must not be the same as the old one"),
          ));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Network error")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              children: [
                const CustomBackButton(),
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 30),
                const Text(
                  "Reset Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                if (_isOtpSent) ...[
                  CustomTextField(
                    controller: _otpController,
                    hintText: "Enter 6-digit OTP",
                    icon: Icons.lock_clock,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _newPasswordController,
                    hintText: "New Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscureNew,
                    onToggleVisibility: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: "Confirm Password",
                    icon: Icons.lock_reset,
                    isPassword: true,
                    obscureText: _obscureConfirm,
                    onToggleVisibility: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _resendCountdown == 0 ? _sendOtp : null,
                    child: Text(
                      _resendCountdown == 0
                          ? "Resend OTP"
                          : "Resend in $_resendCountdown s",
                      style: const TextStyle(
                          color: Color(0xFF2E9265),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Button(
                  onPressed: _isLoading
                      ? null
                      : _isOtpSent
                          ? _resetPassword
                          : _sendOtp,
                  isEnabled: !_isLoading,
                  buttonText: _isOtpSent ? "Confirm Reset" : "Send OTP",
                ),
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
        gradient:
            const LinearGradient(colors: [Color(0xFF2E9265), Color(0xFF1E7A42)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(46, 146, 101, 0.3),
              blurRadius: 20,
              offset: Offset(0, 10))
        ],
      ),
      child: const Icon(Icons.lock_reset, color: Colors.white, size: 40),
    );
  }
}
