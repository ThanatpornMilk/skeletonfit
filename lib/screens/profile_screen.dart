import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/gradient_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: const Center(
          child: Text(
            'Profile Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, 
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(
        currentIndex: 2, 
      ),
    );
  }
}
