import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/custom_screen/custom_screen.dart';
import 'screens/custom_screen/add_custom_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/workout_screen.dart';
// import 'screens/exercise_screen/upper_screen.dart';
// import 'screens/exercise_screen/lower_screen.dart';
// import 'screens/exercise_screen/core_screen.dart';
// import 'screens/exercise_screen/full_screen.dart';
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/custom':
            return MaterialPageRoute(builder: (_) => const CustomScreen());
          case '/addcustom':
            return MaterialPageRoute(builder: (_) => const AddCustomScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/workout':
            final workoutName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => WorkoutScreen(workoutName: workoutName),
            );
          default:
            return null;
        }
      },
    );
  }
}
