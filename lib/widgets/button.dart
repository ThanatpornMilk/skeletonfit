import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final String buttonText;

  const Button({
    super.key,
    required this.onPressed,
    required this.isEnabled,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: _buttonDecoration(),
          child: _buildElevatedButton(),
        ),
      );

  BoxDecoration _buttonDecoration() => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E9265),
            Color(0xFF1E7A42),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 146, 101, 0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      );

  ElevatedButton _buildElevatedButton() => ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _buildContent(),
      );

  Widget _buildContent() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            buttonText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      );
}
