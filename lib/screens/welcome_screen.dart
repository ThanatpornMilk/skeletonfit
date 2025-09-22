import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBackground(context),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E9265),
            Color(0xFFFFFFFF),
          ],
          stops: [0.5, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildTopBar(context),
          _buildCircle(),
          _buildLogo(),
          _buildMainContent(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 275,
      color: const Color(0xFF383838),
    );
  }

  Widget _buildCircle() {
    return Positioned(
      top: 100,
      child: Container(
        width: 420,
        height: 420,
        decoration: const BoxDecoration(
          color: Color(0xFF383838),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Positioned(
      top: 90,
      child: Image.asset(
        'assets/logo.png',
        width: 350,
        height: 350,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Start your exercise today',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(0, 0, 0, 0.7), 
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 40),

            _buildAnimatedButton(
              context: context,
              text: "Login",
              isPrimary: true,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            const SizedBox(height: 20),

            _buildAnimatedButton(
              context: context,
              text: "Sign Up",
              isPrimary: false,
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required BuildContext context,
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 300,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color.fromRGBO(0, 0, 0, 0.2)   
                : const Color.fromRGBO(158, 158, 158, 0.2), 
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.black : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
