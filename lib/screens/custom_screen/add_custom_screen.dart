// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../widgets/button.dart';
// import '../../widgets/search_filter_bar.dart';
// import '../../widgets/muscle_filter_dialog.dart';
// import '../../widgets/exercise_grid.dart';
// import '../../widgets/radial_background.dart'; 
// import '../../data/workout_sets.dart';
// import '../../services/api_service.dart';
// import 'choose_lengths_screen.dart';

// class AddCustomScreen extends StatefulWidget {
//   const AddCustomScreen({super.key});

//   @override
//   State<AddCustomScreen> createState() => _AddCustomScreenState();
// }

// class _AddCustomScreenState extends State<AddCustomScreen> {
//   final _searchController = TextEditingController();

//   List<ExerciseInfo> _allExercises = [];
//   List<ExerciseInfo> _filtered = [];
//   final List<ExerciseInfo> _selected = [];

//   bool _isLoading = true;
//   String? _error;

//   Set<String> _selectedMuscles = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchExercises();
//     _searchController.addListener(_onSearch);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchExercises() async {
//     try {
//       final sets = await ApiService.fetchWorkoutSets();
//       final combined = sets.expand((ws) => ws.exercises).toList();
//       final seen = <String>{};
//       _allExercises = combined.where((ex) => seen.add(ex.name)).toList();
//       _filtered = List.from(_allExercises);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _onSearch() {
//     final q = _searchController.text.trim().toLowerCase();
//     setState(() {
//       final base = _selectedMuscles.isEmpty
//           ? _allExercises
//           : _allExercises
//               .where((ex) => ex.muscles.any(_selectedMuscles.contains))
//               .toList();

//       _filtered = q.isEmpty
//           ? List.from(base)
//           : base.where((ex) => ex.name.toLowerCase().contains(q)).toList();
//     });
//   }

//   void _toggle(ExerciseInfo ex) {
//     setState(() {
//       final idx = _selected.indexWhere((e) => e.name == ex.name);
//       if (idx >= 0) {
//         _selected.removeAt(idx);
//       } else {
//         _selected.add(ex);
//       }
//     });
//   }

//   Future<void> _onNext() async {
//     if (_selected.isEmpty) return;

//     final set = await Navigator.push<WorkoutSet>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChooseLengthsScreen(selected: List.from(_selected)),
//       ),
//     );

//     if (!mounted) return;
//     if (set != null) {
//       // ส่ง WorkoutSet ตรง ๆ กลับไป CustomScreen
//       Navigator.pop(context, set);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const bg = Color(0xFF181717);

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: bg,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_error != null) {
//       return const Scaffold(
//         backgroundColor: bg,
//         body: Center(
//           child: Text(
//             'เกิดข้อผิดพลาดในการโหลดข้อมูล',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: _buildAppBar(),
//       body: SafeArea(
//         child: RadialBackground( 
//           bg: bg,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 child: SearchFilterBar(
//                   controller: _searchController,
//                   hint: 'ค้นหาท่าออกกำลังกาย',
//                   onTapFilter: _showFilterDialog,
//                 ),
//               ),
//               Expanded(
//                 child: ExerciseGrid(
//                   items: _filtered,
//                   selected: _selected,
//                   onToggle: _toggle,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 child: Button(
//                   onPressed: _onNext,
//                   isEnabled: _selected.isNotEmpty,
//                   buttonText: 'ถัดไป',
//                 ),
//               ),
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
//       title: const Text('Choose Your Exercise', style: TextStyle(color: Colors.white)),
//     );
//   }

//   Future<void> _showFilterDialog() async {
//     final allMuscles = _allExercises.expand((e) => e.muscles).toSet().toList()..sort();
//     final res = await MuscleFilterDialog.show(
//       context,
//       allMuscles: allMuscles,
//       initialSelected: _selectedMuscles,
//     );
//     if (res != null) {
//       setState(() => _selectedMuscles = res);
//       _onSearch();
//     }
//   }
// }
