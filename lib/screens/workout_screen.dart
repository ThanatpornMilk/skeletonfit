// import 'package:flutter/material.dart';
// import '../widgets/exercise_list_view.dart';
// import '../services/api_service.dart';
// import '../data/workout_sets.dart'; 
// import '../widgets/button.dart';
// import 'camera_screen.dart';

// class WorkoutScreen extends StatelessWidget {
//   final String workoutName; 

//   const WorkoutScreen({super.key, required this.workoutName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: const Color(0xFF181717),
//       body: Container(
//         decoration: _backgroundGradient(),
//         child: SafeArea(
//           child: FutureBuilder<List<WorkoutSet>>(
//             future: ApiService.fetchWorkoutSets(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('No workout sets found'));
//               }

//               // หา WorkoutSet ตามชื่อ
//               final WorkoutSet set = snapshot.data!.firstWhere(
//                 (s) => s.name == workoutName,
//                 orElse: () => snapshot.data!.first,
//               );

//               // เรียงท่าสำหรับ Full Body
//               List<ExerciseInfo> sortedExercises = set.exercises;
//               if (set.name.toLowerCase() == "full body") {
//                 final List<int> customOrder = [7, 2, 10, 8, 6, 13, 19, 20];
//                 sortedExercises = List.from(set.exercises)
//                   ..sort((a, b) {
//                     int indexA = customOrder.indexOf(a.id);
//                     int indexB = customOrder.indexOf(b.id);
//                     if (indexA == -1) indexA = customOrder.length;
//                     if (indexB == -1) indexB = customOrder.length;
//                     return indexA.compareTo(indexB);
//                   });
//               }

//               return Column(
//                 children: [
//                   _buildAppBar(context, set),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: ExerciseListView(
//                       exercises: sortedExercises, // ส่ง list ที่เรียงแล้ว
//                       muscles: set.muscles,
//                     ),
//                   ),
//                   Button(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const CameraScreen()),
//                       );
//                     },
//                     isEnabled: true,
//                     buttonText: 'เริ่มออกกำลังกาย',
//                     icon: Icons.play_arrow,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   BoxDecoration _backgroundGradient() => const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFF181717),
//             Color(0xFF181717),
//             Color(0xFF181717),
//           ],
//           stops: [0.0, 0.5, 1.0],
//         ),
//       );

//   Widget _buildAppBar(BuildContext context, WorkoutSet set) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           _buildBackButton(context),
//           const SizedBox(width: 16),
//           Expanded(child: _buildTitleSection(set)),
//           _buildExerciseCount(set),
//         ],
//       ),
//     );
//   }

//   Widget _buildBackButton(BuildContext context) {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFFFF).withAlpha(15),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xFFFFFFFF).withAlpha(25),
//           width: 1,
//         ),
//       ),
//       child: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
//         onPressed: () => Navigator.pop(context),
//       ),
//     );
//   }

//   Widget _buildTitleSection(WorkoutSet set) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           set.name,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             letterSpacing: -0.5,
//           ),
//         ),
//         Text(
//           set.subtitle,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildExerciseCount(WorkoutSet set) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2E9265).withAlpha(38),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: const Color(0xFF2E9265).withAlpha(51),
//           width: 1,
//         ),
//       ),
//       child: Text(
//         '${set.exercises.length} ท่า',
//         style: const TextStyle(
//           color: Color(0xFF2E9265),
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
