// import 'package:flutter/material.dart';
// import '../data/exercises.dart';

// class ExerciseGrid extends StatelessWidget {
//   final List<ExerciseInfo> items;
//   final List<ExerciseInfo> selected;
//   final void Function(ExerciseInfo) onToggle;

//   const ExerciseGrid({
//     super.key,
//     required this.items,
//     required this.selected,
//     required this.onToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: items.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8,
//       ),
//       itemBuilder: (_, i) {
//         final ex = items[i];
//         final selIndex = selected.indexWhere((e) => e.name == ex.name);
//         final isSelected = selIndex >= 0;
//         final order = selIndex + 1;

//         return GestureDetector(
//           onTap: () => onToggle(ex),
//           child: Column(
//             children: [
//               Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: isSelected ? Colors.greenAccent : Colors.transparent, width: 3,
//                       ),
//                     ),
//                     child: CircleAvatar(
//                       radius: 36,
//                       backgroundColor: Colors.white12,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Image.asset(
//                           ex.image,
//                           fit: BoxFit.contain,
//                           errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: Colors.white54),
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (isSelected)
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
//                       child: Text(
//                         '$order',
//                         style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 ex.name,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: isSelected ? Colors.greenAccent : Colors.white70, fontSize: 13),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
