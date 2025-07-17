import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/gradient_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: const Center(
          child: Text(
            'Setting Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, 
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(
        currentIndex: 1, 
      ),
    );
  }
}
