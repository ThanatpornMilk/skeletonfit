import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/navbar.dart';
import '../data/workout_sets.dart';
import '../widgets/workout_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181717),  // พื้นหลังหลักเป็น #181717
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF181717), // เปลี่ยนทุกจุดให้ใช้ #181717
              Color(0xFF181717),
              Color(0xFF181717),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // --- EFFECTS ---
            Positioned(
              top: 120,
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      const Color(0xFF27AE60).withOpacity(0.01),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.06),
                      const Color(0xFF27AE60).withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // --- MAIN CONTENT ---
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: วันที่ + Profile
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // วันที่เป็นภาษาอังกฤษ
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('d MMMM')
                                  .format(DateTime.now())
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
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

                        // Profile
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Workout Cards (PageView)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: SizedBox(
                      height: 280,
                      child: PageView.builder(
                        itemCount: workoutSets.length,
                        controller: PageController(
                          viewportFraction: 0.9,
                          initialPage: 0,
                        ),
                        onPageChanged: (idx) => setState(() => pageIndex = idx),
                        itemBuilder: (context, idx) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: WorkoutCard(workoutSet: workoutSets[idx]),
                        ),
                      ),
                    ),
                  ),

                  // Page indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        workoutSets.length,
                        (idx) {
                          final bool isActive = idx == pageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xCCFFFFFF),
                                      ],
                                    )
                                  : null,
                              color: isActive
                                  ? null
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: currentIndex,
        onTap: (idx) => setState(() => currentIndex = idx),
      ),
    );
  }
}
