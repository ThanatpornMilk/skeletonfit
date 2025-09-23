// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../data/workout_sets.dart';
// import '../../widgets/button.dart';
// import '../../widgets/radial_background.dart';

// class DesignCustomScreen extends StatefulWidget {
//   /// [{'exercise': ExerciseInfo, 'sets': int, 'reps': int}]
//   final List<Map<String, dynamic>> plans;
//   const DesignCustomScreen({super.key, required this.plans});

//   @override
//   State<DesignCustomScreen> createState() => _DesignCustomScreenState();
// }

// class _DesignCustomScreenState extends State<DesignCustomScreen>
//     with TickerProviderStateMixin {
//   final _nameCtrl = TextEditingController(text: 'Custom Workout');
//   late final AnimationController _slideController;
//   late final AnimationController _fadeController;
//   late final Animation<Offset> _slideAnimation;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
//         .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

//     _slideController.forward();
//     _fadeController.forward();
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _slideController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const bg = Color(0xFF181717);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: _buildAppBar(),
//       body: SafeArea(
//         child: RadialBackground(
//           bg: bg,
//           child: Column(
//             children: [
//               Expanded(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           _buildNameInput(),
//                           const SizedBox(height: 20),
//                           _buildExercisesSection(),
//                           const SizedBox(height: 12),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _buildBottomButton(),
//             ],
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
//             border: Border.all(color: const Color(0xFFFFFFFF).withAlpha(25), width: 1),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//       centerTitle: true,
//       title: const Text('Design Workout', style: TextStyle(color: Colors.white)),
//     );
//   }

//   Widget _buildNameInput() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           colors: [
//             Color.fromRGBO(255, 255, 255, 0.10),
//             Color.fromRGBO(255, 255, 255, 0.05),
//           ],
//         ),
//         border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.20)),
//       ),
//       child: TextField(
//         controller: _nameCtrl,
//         style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
//         decoration: const InputDecoration(
//           labelText: 'ตั้งชื่อแผนการออกกำลังกาย',
//           labelStyle: TextStyle(
//             color: Color.fromRGBO(105, 240, 174, 0.80),
//             fontSize: 20,
//           ),
//           prefixIcon: Icon(
//             Icons.edit_note,
//             color: Color.fromRGBO(105, 240, 174, 0.80),
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           floatingLabelBehavior: FloatingLabelBehavior.auto,
//         ),
//       ),
//     );
//   }

//   /// ลิสต์ท่าออกกำลังกาย (เพิ่มชิปจำนวนท่ามุมขวาบน)
//   Widget _buildExercisesSection() {
//     final count = widget.plans.length;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(255, 255, 255, 0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.10)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color.fromRGBO(255, 255, 255, 0.10),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.list_alt, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'รายการท่าออกกำลังกาย',
//                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 const Spacer(),
//                 _countChip(count),
//               ],
//             ),
//           ),
//           ListView.separated(
//             padding: const EdgeInsets.all(12),
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: count,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (_, i) {
//               final ex = widget.plans[i]['exercise'] as ExerciseInfo;
//               final sets = widget.plans[i]['sets'] as int;
//               final reps = widget.plans[i]['reps'] as int;

//               return AnimatedContainer(
//                 duration: Duration(milliseconds: 300 + (i * 100)),
//                 curve: Curves.easeOutBack,
//                 child: _ExerciseTile(ex: ex, sets: sets, reps: reps),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _countChip(int count) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(105, 240, 174, 0.15),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: const Color.fromRGBO(105, 240, 174, 0.35)),
//       ),
//       child: Text(
//         '$count ท่า',
//         style: const TextStyle(
//           color: Color.fromRGBO(105, 240, 174, 1.0),
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 0.2,
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
//         onPressed: _finish,
//         isEnabled: true,
//         buttonText: 'เสร็จสิ้น',
//       ),
//     );
//   }

//   void _finish() {
//     HapticFeedback.lightImpact();
//     final name = _nameCtrl.text.trim().isEmpty ? 'Custom Workout' : _nameCtrl.text.trim();
//     final exercises = widget.plans.map((p) => p['exercise'] as ExerciseInfo).toList();

//     final set = WorkoutSet(
//       id: DateTime.now().millisecondsSinceEpoch,
//       name: name,
//       subtitle: '',
//       muscles: exercises.expand((e) => e.muscles).toSet().toList(),
//       exercises: exercises,
//     );

//     Navigator.pop(context, set);
//   }
// }

// /// ---------- ไอเท็มในลิสต์ ----------
// class _ExerciseTile extends StatelessWidget {
//   final ExerciseInfo ex;
//   final int sets;
//   final int reps;

//   const _ExerciseTile({
//     required this.ex,
//     required this.sets,
//     required this.reps,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color.fromRGBO(255, 255, 255, 0.10),
//             Color.fromRGBO(255, 255, 255, 0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.20)),
//       ),
//       child: Row(
//         children: [
//           _thumb(),
//           const SizedBox(width: 16),
//           Expanded(child: _title()),
//           const SizedBox(width: 12),
//           _setRepPill(),
//         ],
//       ),
//     );
//   }

//   Widget _thumb() {
//     return Container(
//       width: 60,
//       height: 60,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color.fromRGBO(105, 240, 174, 0.30),
//             Color.fromRGBO(105, 240, 174, 0.10),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color.fromRGBO(105, 240, 174, 0.30)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Image.asset(
//           ex.image,
//           fit: BoxFit.contain,
//           errorBuilder: (_, __, ___) =>
//               const Icon(Icons.fitness_center, color: Colors.greenAccent, size: 30),
//         ),
//       ),
//     );
//   }

//   Widget _title() {
//     return Text(
//       ex.name,
//       style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//     );
//   }

//   Widget _setRepPill() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color.fromRGBO(105, 240, 174, 0.20),
//             Color.fromRGBO(105, 240, 174, 0.10),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color.fromRGBO(105, 240, 174, 0.30)),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 2),
//           Text(
//             '$sets × $reps',
//             style: const TextStyle(
//               color: Colors.greenAccent,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Text(
//             'เซต × ครั้ง',
//             style: TextStyle(
//               color: Color.fromRGBO(255, 255, 255, 0.60),
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
