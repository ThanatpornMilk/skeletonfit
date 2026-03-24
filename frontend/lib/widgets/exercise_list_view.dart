import 'package:flutter/material.dart';
import '../data/exercises.dart';
import '../screens/exercise_detail_screen.dart';

class ExerciseListView extends StatelessWidget {
  final List<ExerciseInfo> exercises;
  /// ใช้บอกว่ามาจาก Custom Workout หรือไม่
  final bool isCustomWorkout;
  /// callback เมื่อแตะรายการท่า (ถ้าไม่ส่ง จะ fallback เปิด ExerciseDetailScreen ให้เอง)
  final void Function(ExerciseInfo)? onTap;

  const ExerciseListView({
    super.key,
    required this.exercises,
    this.isCustomWorkout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final ex = exercises[index];
        return RepaintBoundary(
          child: _ExerciseCard(
            exercise: ex,
            isCustomWorkout: isCustomWorkout,
            onTap: onTap,
          ),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseInfo exercise;
  final bool isCustomWorkout;
  final void Function(ExerciseInfo)? onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isCustomWorkout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (onTap != null) {
              onTap!(exercise);
            } else {
              // Fallback: เปิดหน้า ExerciseDetailScreen โดยอัตโนมัติ
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(
                    exercise: exercise,
                    isCustomWorkout: isCustomWorkout,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _thumb(exercise.imageUrl),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumb(String? url) {
    final hasImage = (url ?? '').trim().isNotEmpty;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF2E8B57)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.hardEdge,
        child: hasImage
            ? Image.network(url!, fit: BoxFit.contain)
            : const Icon(Icons.fitness_center, color: Colors.grey),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.1),
          Color.fromRGBO(255, 255, 255, 0.05),
        ],
      ),
      border: Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.08),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
