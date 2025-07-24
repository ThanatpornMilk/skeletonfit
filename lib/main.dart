import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/custom_screen/custom_screen.dart';
import 'screens/custom_screen/add_custom_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/exercise_screen/upper_screen.dart';
import 'screens/exercise_screen/lower_screen.dart';
import 'screens/exercise_screen/core_screen.dart';
import 'screens/exercise_screen/full_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/custom' : (context) => const CustomScreen(),
        '/addcustom' : (context) => const AddCustomScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/upper': (context) => const UpperBodyScreen(),
        '/lower': (context) => const LowerBodyScreen(),
        '/core': (context) => const CoreScreen(),
        '/full': (context) => const FullBodyScreen(),

      },
    );
  }
}
