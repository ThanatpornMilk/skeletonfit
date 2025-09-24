// import 'package:flutter/material.dart';
// import '../data/workout_sets.dart';

// class CustomWorkoutCard extends StatefulWidget {
//   final WorkoutSet workoutSet;
//   const CustomWorkoutCard({super.key, required this.workoutSet});

//   @override
//   State<CustomWorkoutCard> createState() => _CustomWorkoutCardState();
// }

// class _CustomWorkoutCardState extends State<CustomWorkoutCard>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _animationController;
//   late final Animation<double> _scaleAnimation;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );
//     _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _animationController.forward(),
//       onTapUp: (_) => _animationController.reverse(),
//       onTapCancel: () => _animationController.reverse(),
//       child: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) => Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF2E9265),
//                     Color(0xFF1A2732),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withAlpha(102),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Custom Plan',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       widget.workoutSet.name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 26,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     Expanded(child: Center(child: _buildExerciseIcons())),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildExerciseIcons() {
//     return Wrap(
//       alignment: WrapAlignment.center,
//       spacing: 16,
//       runSpacing: 16,
//       children: widget.workoutSet.exercises.asMap().entries.map((entry) {
//         final idx = entry.key;
//         final ex = entry.value;
//         return TweenAnimationBuilder<double>(
//           duration: Duration(milliseconds: 200 + idx * 100),
//           tween: Tween(begin: 0.0, end: 1.0),
//           builder: (context, scale, child) => Transform.scale(
//             scale: scale,
//             child: Transform.translate(
//               offset: Offset(0, 20 * (1 - scale)),
//               child: Opacity(
//                 opacity: scale,
//                 child: Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withAlpha(13),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withAlpha(51),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Image.asset(
//                       ex.image,
//                       fit: BoxFit.contain,
//                       errorBuilder: (_, __, ___) => const Icon(
//                         Icons.fitness_center,
//                         color: Colors.white70,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
