import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/gradient_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const int selectedIndex = 1;

    return Scaffold(
      body: GradientBackground(
        child: const Center(
          child: Text(
            'Setting Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
