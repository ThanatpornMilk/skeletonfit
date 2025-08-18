import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/navbar.dart';
import '../widgets/workout_card.dart';
import '../screens/profile_screen.dart';
import '../services/api_service.dart';
import '../data/workout_sets.dart';

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
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

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
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FutureBuilder<List<WorkoutSet>>(
                          future: ApiService.fetchWorkoutSets(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildLoading();
                            } else if (snapshot.hasError) {
                              return _buildError(snapshot.error.toString());
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return _buildEmptyState();
                            }

                            final workoutSets = snapshot.data!;
                            return ListView(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildQuickStats(),
                                const SizedBox(height: 16),
                                ...workoutSets
                                    .asMap()
                                    .entries
                                    .map((entry) => _buildAnimatedWorkoutCard(entry.value, entry.key))
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }

  // Background
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

  // Header
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

  // Quick Stats
  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(20, 255, 255, 255), Color.fromARGB(8, 255, 255, 255)],
        ),
        border: Border.all(color: const Color.fromARGB(26, 255, 255, 255), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Workouts', '12', Icons.fitness_center),
          _buildStatDivider(),
          _buildStatItem('Streak', '5', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(51, 0, 212, 170),
                Color.fromARGB(26, 0, 166, 136),
              ],
            ),
          ),
          child: Icon(icon, color: const Color(0xFF00D4AA), size: 20),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Color.fromARGB(153, 255, 255, 255),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color.fromARGB(51, 255, 255, 255), Colors.transparent],
        ),
      ),
    );
  }

  // Workout List
  Widget _buildAnimatedWorkoutCard(WorkoutSet workout, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + index * 100),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: WorkoutCard(workoutSet: workout),
            ),
          ),
        );
      },
    );
  }

  // Loading / Error / Empty
  Widget _buildLoading() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                    colors: [Color(0xFF00D4AA), Color(0xFF00A688)]),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading your workouts...',
              style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  Widget _buildError(String message) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromRGBO(255, 0, 0, 0.1),
            border: Border.all(color: const Color.fromRGBO(255, 0, 0, 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Color.fromRGBO(255, 0, 0, 0.8), size: 48),
              const SizedBox(height: 16),
              const Text('Oops! Something went wrong',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 0, 0, 0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(message,
                  style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.6), fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.05),
                Color.fromRGBO(255, 255, 255, 0.02)
              ],
            ),
            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 212, 170, 0.2),
                      Color.fromRGBO(0, 166, 136, 0.1)
                    ],
                  ),
                ),
                child: const Icon(Icons.fitness_center,
                    size: 40, color: Color(0xFF00D4AA)),
              ),
              const SizedBox(height: 24),
              const Text('Ready to Start?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text(
                'No workout sets found. Create your first workout to get started!',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                    fontSize: 16,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
