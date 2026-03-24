import 'package:flutter/material.dart';
import '../data/exercises.dart';
import '../screens/custom_screen/workout_detail_screen.dart';

class CustomWorkoutCard extends StatelessWidget {
  final String name;
  final List<ExerciseInfo> exercises;

  const CustomWorkoutCard({
    super.key,
    required this.name,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // เปิดหน้ารายละเอียดท่าออกกำลังกาย
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(
              title: name,
              exercises: exercises,
            ),
          ),
        );
      },
      child: AnimatedScale(
        scale: 1.0, 
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(77, 0, 0, 0),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E9265), Color(0xFF1A2732)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name.isNotEmpty) ...[
                    Text(
                      name,  
                      style: const TextStyle(
                        color: Colors.white,  
                        fontWeight: FontWeight.bold,  
                        fontSize: 26, 
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 14),  

                  if (exercises.isEmpty)
                    const Text('No exercises available', style: TextStyle(color: Colors.white70))
                  else
                    SizedBox(
                      height: 56,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: exercises.length,
                        itemBuilder: (_, i) {
                          final ex = exercises[i];
                          return Container(
                            width: 52,
                            height: 52,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(20, 255, 255, 255),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.network(
                                  ex.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fitness_center,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
