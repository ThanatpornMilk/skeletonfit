// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../widgets/button.dart';
// import '../../widgets/exercise_length_row.dart';
// import '../../widgets/radial_background.dart';
// import '../../data/workout_sets.dart';
// import 'design_custom_screen.dart';

// class ChooseLengthsScreen extends StatefulWidget {
//   final List<ExerciseInfo> selected;
//   const ChooseLengthsScreen({super.key, required this.selected});

//   @override
//   State<ChooseLengthsScreen> createState() => _ChooseLengthsScreenState();
// }

// class _ChooseLengthsScreenState extends State<ChooseLengthsScreen>
//     with TickerProviderStateMixin {
//   late List<Map<String, dynamic>> plans;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     plans = widget.selected
//         .map((ex) => {
//               'exercise': ex,
//               'sets': 3,
//               'reps': 12,
//             })
//         .toList();

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const bg = Color(0xFF181717);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: _buildAppBar(),
//       body: RadialBackground(
//         bg: bg,
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 _buildSectionHeader(),
//                 _buildExerciseList(),
//                 _buildBottomButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   AppBar _buildAppBar() {
//     const bg = Color(0xFF181717);
//     return AppBar(
//       backgroundColor: bg,
//       elevation: 0,
//       shadowColor: Colors.transparent,
//       surfaceTintColor: Colors.transparent,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarColor: bg,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       leadingWidth: 64,
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
//         child: Container(
//           width: 44,
//           height: 44,
//           decoration: BoxDecoration(
//             color: const Color(0xFFFFFFFF).withAlpha(15),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: const Color(0xFFFFFFFF).withAlpha(25),
//               width: 1,
//             ),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//       centerTitle: true,
//       title: const Text('Choose Lengths', style: TextStyle(color: Colors.white)),
//     );
//   }

//   Widget _buildSectionHeader() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 24,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF2E9265), Color(0xFF1E7A42)],
//               ),
//               borderRadius: BorderRadius.all(Radius.circular(2)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             'Exercise Details (${plans.length} exercises)',
//             style: const TextStyle(
//               color: Color.fromRGBO(255, 255, 255, 0.9),
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0.3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExerciseList() {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: ListView.separated(
//           physics: const BouncingScrollPhysics(),
//           itemCount: plans.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 12),
//           itemBuilder: (_, i) {
//             final ex = plans[i]['exercise'] as ExerciseInfo;
//             final sets = plans[i]['sets'] as int;
//             final reps = plans[i]['reps'] as int;

//             final start = (i * 0.1).clamp(0.0, 1.0).toDouble();
//             final end = ((i * 0.1) + 0.3).clamp(0.0, 1.0).toDouble();

//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(1, 0),
//                 end: Offset.zero,
//               ).animate(
//                 CurvedAnimation(
//                   parent: _animationController,
//                   curve: Interval(start, end, curve: Curves.easeOutBack),
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color.fromRGBO(255, 255, 255, 0.10),
//                       Color.fromRGBO(255, 255, 255, 0.03),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: const Color.fromRGBO(255, 255, 255, 0.15),
//                     width: 1,
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color.fromRGBO(0, 0, 0, 0.10),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ExerciseLengthRow(
//                   exercise: ex,
//                   sets: sets,
//                   reps: reps,
//                   onSetsChanged: (v) => setState(() => plans[i]['sets'] = v),
//                   onRepsChanged: (v) => setState(() => plans[i]['reps'] = v),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomButton() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color.fromRGBO(0, 0, 0, 0.0),
//             Color.fromRGBO(0, 0, 0, 0.10),
//           ],
//         ),
//       ),
//       child: Button(
//         onPressed: _goNext,
//         isEnabled: true,
//         buttonText: 'ถัดไป',
//       ),
//     );
//   }

//   void _goNext() {
//     HapticFeedback.selectionClick();
//     Navigator.push<WorkoutSet>(
//       context,
//       MaterialPageRoute(builder: (_) => DesignCustomScreen(plans: plans)),
//     ).then((set) {
//       if (!mounted) return;
//       if (set != null) {
//         Navigator.pop(context, set);
//       }
//     });
//   }
// }
