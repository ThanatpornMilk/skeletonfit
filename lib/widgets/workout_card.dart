// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../data/workout_sets.dart';
// import '../screens/workout_screen.dart';

// class WorkoutCard extends StatefulWidget {
//   final WorkoutSet workoutSet;
//   const WorkoutCard({super.key, required this.workoutSet});

//   @override
//   State<WorkoutCard> createState() => _WorkoutCardState();
// }

// class _WorkoutCardState extends State<WorkoutCard> {
//   bool _pressed = false;

//   void _navigate() {
//     HapticFeedback.lightImpact();
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, animation, __) =>
//             WorkoutScreen(workoutName: widget.workoutSet.name),
//         transitionsBuilder: (_, animation, __, child) {
//           const begin = Offset(0, 1);
//           const end = Offset.zero;
//           final tween = Tween(begin: begin, end: end)
//               .chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut));
//           return SlideTransition(
//             position: animation.drive(tween),
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 600),
//       ),
//     );
//   }

//   List<Color> get _gradient => const [Color(0xFF2E9265), Color(0xFF1A2732)];

//   @override
//   Widget build(BuildContext context) {
//     final shadowFactor = _pressed ? 0.5 : 1.0;

//     return GestureDetector(
//       onTapDown: (_) => setState(() => _pressed = true),
//       onTapCancel: () => setState(() => _pressed = false),
//       onTapUp: (_) {
//         setState(() => _pressed = false);
//         _navigate();
//       },
//       child: AnimatedScale(
//         scale: _pressed ? 0.98 : 1.0,
//         duration: const Duration(milliseconds: 150),
//         curve: Curves.easeInOut,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           curve: Curves.easeInOut,
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: _gradient,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color.fromARGB(77, 0, 0, 0), // ~0.3 opacity
//                 blurRadius: 10 * shadowFactor,
//                 offset: Offset(0, 4 * shadowFactor),
//               ),
//             ],
//           ),
//           child: _CardBody(set: widget.workoutSet),
//         ),
//       ),
//     );
//   }
// }

// class _CardBody extends StatelessWidget {
//   final WorkoutSet set;
//   const _CardBody({required this.set});

//   @override
//   Widget build(BuildContext context) {
//     final hasSubtitle = set.subtitle.trim().isNotEmpty;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (hasSubtitle) ...[
//           Text(
//             set.subtitle,
//             style: const TextStyle(
//               color: Color.fromARGB(200, 255, 255, 255),
//               fontWeight: FontWeight.w500,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//         Text(
//           set.name,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _ExerciseIcons(exercises: set.exercises),
//       ],
//     );
//   }
// }

// class _ExerciseIcons extends StatelessWidget {
//   final List<ExerciseInfo> exercises;
//   const _ExerciseIcons({required this.exercises});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: exercises.length,
//         itemBuilder: (_, i) {
//           final ex = exercises[i];
//           return Container(
//             width: 56,
//             height: 56,
//             margin: const EdgeInsets.only(right: 12),
//             decoration: const BoxDecoration(
//               color: Color.fromARGB(20, 255, 255, 255),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Color.fromARGB(25, 0, 0, 0),
//                   blurRadius: 8,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Image.asset(
//                 ex.image,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.fitness_center, color: Colors.white70),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
