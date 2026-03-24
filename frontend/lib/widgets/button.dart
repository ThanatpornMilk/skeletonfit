import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Future<void> Function()? onPressed; 
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
          child: ElevatedButton(
            onPressed: isEnabled && onPressed != null ? () => onPressed!() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

  BoxDecoration _buttonDecoration() => BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E9265),
            Color(0xFF1E7A42),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 146, 101, 0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      );
}
