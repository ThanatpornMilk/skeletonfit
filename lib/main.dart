import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
// import 'screens/custom_screen/custom_screen.dart';
// import 'screens/custom_screen/add_custom_screen.dart';
import 'screens/profile_screen.dart';
// import 'screens/workout_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        // '/custom': (_) => const CustomScreen(),
        // '/addcustom': (_) => const AddCustomScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      // หน้าที่ต้องส่ง argument แบบพิเศษ ค่อยกำหนดที่นี่เป็นรายเคส
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/workout' && settings.arguments is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => WorkoutScreen(workoutName: settings.arguments as String),
      //     );
      //   }
      //   return null;
      // },
      theme: ThemeData(useMaterial3: true),
    );
  }
}
