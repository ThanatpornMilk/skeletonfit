// import 'package:flutter/material.dart';
// import '../data/exercises.dart';

// const double kControlWidth = 132;       
// const double kLabelSlotWidth = 32;      
// const double kNumberSlotWidth = 28;    

// class ExerciseLengthRow extends StatefulWidget {
//   final ExerciseInfo exercise;
//   final int sets;
//   final int reps;
//   final ValueChanged<int> onSetsChanged;
//   final ValueChanged<int> onRepsChanged;

//   const ExerciseLengthRow({
//     super.key,
//     required this.exercise,
//     required this.sets,
//     required this.reps,
//     required this.onSetsChanged,
//     required this.onRepsChanged,
//   });

//   @override
//   State<ExerciseLengthRow> createState() => _ExerciseLengthRowState();
// }

// class _ExerciseLengthRowState extends State<ExerciseLengthRow> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color.fromRGBO(255, 255, 255, 0.12),
//             Color.fromRGBO(255, 255, 255, 0.04),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: const Color.fromRGBO(255, 255, 255, 0.20),
//           width: 1.5,
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Color.fromRGBO(0, 0, 0, 0.15),
//             blurRadius: 15,
//             offset: Offset(0, 6),
//           ),
//           BoxShadow(
//             color: Color.fromRGBO(255, 255, 255, 0.05),
//             blurRadius: 1,
//             offset: Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 26,
//             backgroundColor: Colors.white12,
//             child: Padding(
//               padding: const EdgeInsets.all(6),
//               child: Image.asset(
//                 widget.exercise.image,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.fitness_center, color: Colors.white54),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               widget.exercise.name,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: kControlWidth,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _ControlBox(
//                   label: 'เซต',
//                   value: widget.sets,
//                   onChanged: widget.onSetsChanged,
//                 ),
//                 const SizedBox(height: 8),
//                 _ControlBox(
//                   label: 'ครั้ง',
//                   value: widget.reps,
//                   onChanged: widget.onRepsChanged,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ControlBox extends StatelessWidget {
//   final String label;
//   final int value;
//   final ValueChanged<int> onChanged;

//   const _ControlBox({
//     required this.label,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: kControlWidth,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//         decoration: BoxDecoration(
//           color: const Color.fromRGBO(0, 0, 0, 0.26),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.24)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: kLabelSlotWidth,
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   color: Color.fromRGBO(255, 255, 255, 0.7),
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 4),
//             _TinySquareButton(
//               icon: Icons.remove,
//               onTap: () => onChanged(value > 1 ? value - 1 : 1),
//             ),
//             SizedBox(
//               width: kNumberSlotWidth,
//               child: Text(
//                 '$value',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             _TinySquareButton(
//               icon: Icons.add,
//               onTap: () => onChanged(value + 1),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TinySquareButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _TinySquareButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 24,
//       height: 24,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(6),
//           child: Center(
//             child: Icon(icon, size: 16, color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }
