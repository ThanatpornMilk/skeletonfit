import 'package:flutter/material.dart';
import '../../widgets/exercise_list_view.dart';
import '../../data/workout_sets.dart';
import '../../widgets/button.dart';

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
              _buildAppBar(context, coreSet),
              const SizedBox(height: 10),
              Expanded(
                child: ExerciseListView(
                  exercises: coreSet.exercises,
                  muscles: coreSet.muscles,
                ),
              ),
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

  Widget _buildAppBar(BuildContext context, WorkoutSet set) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withAlpha(15), // 0.06 opacity
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withAlpha(25), // 0.1 opacity
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
                Text(
                  set.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  set.subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E9265).withAlpha(38), // 0.15 opacity
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2E9265).withAlpha(51), // 0.2 opacity
                width: 1,
              ),
            ),
            child: Text(
              '${set.exercises.length} ท่า',
              style: const TextStyle(
                color: Color(0xFF2E9265),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
