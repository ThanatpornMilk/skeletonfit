import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/navbar.dart';
import '../widgets/exercise_list_view.dart';
import '../screens/profile_screen.dart';
import '../services/api_service.dart';
import '../data/exercises.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181717),
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: Stack(
          children: [
            _buildBackgroundEffects(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildExerciseList()), 
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }

  Widget _buildExerciseList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: FutureBuilder<List<ExerciseInfo>>(
          future: ApiService.fetchExercises(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }
            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }
            return ExerciseListView(exercises: snapshot.data!);
          },
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF181717), Color(0xFF181717)],
        ),
      );

  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        Positioned(
          top: 120,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.08),
                  Color.fromRGBO(39, 174, 96, 0.01),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.06),
                  Color.fromRGBO(39, 174, 96, 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMMM').format(DateTime.now()).toUpperCase(),
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromRGBO(255, 255, 255, 0.24),
                child: Icon(
                  Icons.person,
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D4AA)),
      );

  Widget _buildError(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );

  Widget _buildEmptyState() => const Center(
        child: Text(
          'No exercises available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
}
