// import 'package:flutter/material.dart';

// class MuscleCard extends StatelessWidget {
//   final List<String> muscles;
//   const MuscleCard({super.key, required this.muscles}); 

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white.withAlpha(18), 
//             Colors.white.withAlpha(8),  
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: Colors.white.withAlpha(28), 
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(46), 
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             'กล้ามเนื้อที่เกี่ยวข้อง',
//             style: TextStyle(
//               color: Colors.white.withAlpha(235), 
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               letterSpacing: -0.3,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             alignment: WrapAlignment.center,
//             spacing: 10,
//             runSpacing: 12,
//             children: muscles.map((e) => _buildMuscleTag(e)).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMuscleTag(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF299B57), Color(0xFF1E7A42)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF299B57).withAlpha(23), 
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     );
//   }
// }
