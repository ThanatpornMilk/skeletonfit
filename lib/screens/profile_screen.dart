import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 2;

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Text(
            'Profile Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
