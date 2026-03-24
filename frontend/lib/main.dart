import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/admin_manage_exercises_screen.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/reset': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(),
        '/history': (_) => const HistoryScreen(),
        '/admin_exercises': (_) => const AdminManageExercisesScreen(),
      },
      theme: ThemeData(useMaterial3: true),
    );
  }
}
