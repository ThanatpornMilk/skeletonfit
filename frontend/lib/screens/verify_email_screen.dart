import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/radial_background.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/button.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:3000/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email, "code": code}),
      );

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Verified successfully")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Invalid or expired code")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:3000/resend-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP resent successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Failed to resend OTP")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RadialBackground(
        bg: const Color(0xFF181717),
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
                        "Verify Your Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "We’ve sent a 6-digit code to\n${widget.email}\nPlease enter it below to verify your account.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                        decoration: InputDecoration(
                          hintText: "Enter 6-digit code",
                          hintStyle: const TextStyle(color: Colors.grey),
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Button(
                        onPressed: _isLoading ? null : _verifyCode,
                        isEnabled: !_isLoading,
                        buttonText: _isLoading ? "Verifying..." : "Verify",
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _isResending ? null : _resendOtp,
                        child: Text(
                          _isResending ? "Resending..." : "Resend OTP",
                          style: const TextStyle(
                            color: Color(0xFF2E9265),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Code expires in 5 minutes.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
      child: const Icon(Icons.mark_email_read_rounded,
          color: Colors.white, size: 40),
    );
  }
}
