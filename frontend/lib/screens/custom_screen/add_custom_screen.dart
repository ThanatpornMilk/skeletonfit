import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/exercises.dart';
import '../../services/api_service.dart';
import '../../widgets/button.dart';
import '../../widgets/radial_background.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/muscle_filter_dialog.dart';
import '../../providers/user_provider.dart';
import '../../widgets/input_dialog.dart';

class AddCustomScreen extends StatefulWidget {
  const AddCustomScreen({super.key});

  @override
  State<AddCustomScreen> createState() => _AddCustomScreenState();
}

class _AddCustomScreenState extends State<AddCustomScreen> {
  final _searchController = TextEditingController();
  late List<ExerciseInfo> _allExercises;
  late List<ExerciseInfo> _filtered;
  final _selectedExercises = <ExerciseInfo>[];
  Set<String> _selectedMuscles = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    try {
      final exercises = await ApiService.fetchExercises();
      if (!mounted) return;
      setState(() {
        _allExercises = exercises;
        _filtered = List.from(_allExercises);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_allExercises)
          : _allExercises
              .where((ex) => ex.name.toLowerCase().startsWith(q))
              .toList();
    });
  }

  void _toggle(ExerciseInfo ex) {
    setState(() {
      if (_selectedExercises.contains(ex)) {
        _selectedExercises.remove(ex);
      } else {
        _selectedExercises.add(ex);
      }
    });
  }

  Future<void> _saveCustomWorkout() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนสร้าง workout")),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกท่าออกกำลังกาย")),
      );
      return;
    }

    final name = await InputDialog.show(
      context,
      title: 'ตั้งชื่อ Custom Workout',
      hintText: 'เช่น Full Body Routine',
      confirmText: 'บันทึก',
      cancelText: 'ยกเลิก',
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      await ApiService.saveCustomWorkout(
        userId: userId,
        name: name.trim(),
        exerciseIds: _selectedExercises.map((e) => e.id).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("บันทึก Custom Workout สำเร็จ")),
      );

      // แจ้งหน้าก่อนหน้าว่า “สร้างสำเร็จ” เพื่อให้รีเฟรช
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint("Error saving custom workout: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  Future<void> _openMuscleFilter() async {
    final allMuscles = _getAllMusclesFromExercises();
    final selectedMuscles = await MuscleFilterDialog.show(
      context,
      allMuscles: allMuscles,
      initialSelected: _selectedMuscles,
    );

    if (selectedMuscles != null) {
      setState(() {
        _selectedMuscles = selectedMuscles;
        _filterExercisesByMuscles();
      });
    }
  }

  void _filterExercisesByMuscles() {
    setState(() {
      _filtered = _allExercises.where((exercise) {
        return exercise.muscles.any((m) => _selectedMuscles.contains(m));
      }).toList();
    });
  }

  List<String> _getAllMusclesFromExercises() {
    final muscles = <String>{};
    for (var exercise in _allExercises) {
      muscles.addAll(exercise.muscles);
    }
    return muscles.toList();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF181717);

    if (_loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E9265)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RadialBackground(
          bg: bg,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchFilterBar(
                  controller: _searchController,
                  onTapFilter: _openMuscleFilter,
                  onChanged: (_) => _onSearch(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildExerciseGrid(bg)),
              const SizedBox(height: 16),
              _buildNextButton(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: const Color(0xFF181717),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Choose Your Exercise',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          color: Colors.white24,
          height: 1,
          thickness: 1,
        ),
      ),
    );
  }

  Widget _buildExerciseGrid(Color bgColor) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (ctx, i) {
        final ex = _filtered[i];
        final sel = _selectedExercises.contains(ex);
        final indexInSelected = _selectedExercises.indexOf(ex) + 1;

        return GestureDetector(
          onTap: () => _toggle(ex),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: sel ? Colors.greenAccent : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white12,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          ex.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fitness_center,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (sel)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                      ),
                      child: Text(
                        '$indexInSelected',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ex.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sel ? Colors.greenAccent : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Button(
        onPressed: _saveCustomWorkout,
        isEnabled: _selectedExercises.isNotEmpty,
        buttonText: 'บันทึก Custom Workout',
      ),
    );
  }
}
