import 'package:flutter/material.dart';
import '../../widgets/exercise_list_view.dart';
import '../../data/workout_sets.dart';
import '../../widgets/button.dart';  // นำเข้า Button widget

class CoreScreen extends StatelessWidget {
  const CoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkoutSet coreSet =
        workoutSets.firstWhere((set) => set.name == 'Core');

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181717),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF181717),
              Color(0xFF181717),
              Color(0xFF181717),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ชื่อชุดท่า (ภาษาอังกฤษ)
                          Text(
                            coreSet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          // ชื่อชุดท่า (ภาษาไทย)
                          Text(
                            coreSet.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E9265).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2E9265).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${coreSet.exercises.length} ท่า',
                        style: const TextStyle(
                          color: Color(0xFF2E9265),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // รายการท่าออกกำลังกาย
              Expanded(
                child: ExerciseListView(
                  exercises: coreSet.exercises,
                  muscles: coreSet.muscles,
                ),
              ),
              // ปุ่มเริ่มออกกำลังกาย ใช้ Button widget
              Button(
                onPressed: () {
                  // TODO: implement start logic
                },
                isEnabled: true,
                buttonText: 'เริ่มออกกำลังกาย',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
