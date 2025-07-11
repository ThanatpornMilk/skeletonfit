import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        body: Container(
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
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // พื้นหลังบนสุด
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 275,
                  color: const Color(0xFF383838),
                ),

                // วงกลม
                Positioned(
                  top: 100,
                  child: Container(
                    width: 420,
                    height: 420,
                    decoration: const BoxDecoration(
                      color: Color(0xFF383838),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // โลโก้
                Positioned(
                  top: 90,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 350,
                    height: 350,
                  ),
                ),

                // ข้อความ
                const Positioned(
                  top: 550,
                  child: Column(
                    children: [
                      Text(
                        'WELCOME',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'press any to start',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
