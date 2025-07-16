import 'package:flutter/material.dart';
import '../screens/custom_screen.dart'; 

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1), 
            blurRadius: 6,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomScreen()),
            );
          }
        },
        iconSize: 28,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Custom',
          ),
        ],
      ),
    );
  }
}
