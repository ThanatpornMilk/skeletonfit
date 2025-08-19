import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/button.dart';
import '../../data/workout_sets.dart';
import '../../services/api_service.dart';

class AddCustomScreen extends StatefulWidget {
  const AddCustomScreen({super.key});

  @override
  State<AddCustomScreen> createState() => _AddCustomScreenState();
}

class _AddCustomScreenState extends State<AddCustomScreen> {
  final _searchController = TextEditingController();
  List<ExerciseInfo> _allExercises = [];
  List<ExerciseInfo> _filtered = [];
  final _selected = <ExerciseInfo>[];
  bool _isLoading = true;
  String? _error;

  Set<String> _selectedMuscles = {}; // เก็บกล้ามเนื้อที่เลือก

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _searchController.addListener(_onSearch);
  }

  Future<void> _fetchExercises() async {
    try {
      final sets = await ApiService.fetchWorkoutSets();
      final combined = sets.expand((ws) => ws.exercises).toList();
      final seenNames = <String>{};
      _allExercises = combined.where((ex) => seenNames.add(ex.name)).toList();
      _filtered = List.from(_allExercises);
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_allExercises)
          : _allExercises
              .where((ex) => ex.name.toLowerCase().contains(q))
              .toList();
    });
  }

  void _toggle(ExerciseInfo ex) {
    setState(() {
      if (_selected.contains(ex)) {
        _selected.remove(ex);
      } else {
        _selected.add(ex);
      }
    });
  }

  void _onNext() {
    if (_selected.isNotEmpty) {
      final customSet = WorkoutSet(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'Custom Workout',
        subtitle: '${_selected.length} ท่า',
        muscles: _selected.expand((e) => e.muscles).toSet().toList(),
        exercises: List.from(_selected),
      );
      Navigator.pop(context, customSet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF181717);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF181717),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(bg),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomLeft,
                        radius: 1.2,
                        colors: [
                          Color.fromRGBO(46, 146, 101, 0.05),
                          Color(0xFF181717),
                          Color(0xFF181717),
                        ],
                        stops: [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.0,
                        colors: [
                          Color.fromRGBO(46, 146, 101, 0.08),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  _buildExerciseGrid(bg),
                ],
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(Color bg) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF181717),
        statusBarIconBrightness: Brightness.light,
      ),
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withAlpha(25),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'Choose Your Exercise',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white12,
                hintText: 'ค้นหาท่าออกกำลังกาย',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.filter_list, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Filter Area', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() async {
    final allMuscles = _allExercises.expand((e) => e.muscles).toSet().toList()..sort();
    final tempSelected = Set<String>.from(_selectedMuscles);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181717),
          title: const Text('เลือกกล้ามเนื้อ', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allMuscles.length,
              itemBuilder: (ctx, i) {
                final muscle = allMuscles[i];
                final isSelected = tempSelected.contains(muscle);
                return StatefulBuilder(
                  builder: (ctx2, setState2) {
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(muscle, style: const TextStyle(color: Colors.white)),
                      activeColor: Colors.greenAccent,
                      onChanged: (val) {
                        setState2(() {
                          if (val == true) {
                            tempSelected.add(muscle);
                          } else {
                            tempSelected.remove(muscle);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedMuscles = tempSelected;
                  if (_selectedMuscles.isEmpty) {
                    _filtered = List.from(_allExercises);
                  } else {
                    _filtered = _allExercises
                        .where((ex) => ex.muscles.any((m) => _selectedMuscles.contains(m)))
                        .toList();
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('ตกลง', style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseGrid(Color bgColor) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (ctx, i) {
        final ex = _filtered[i];
        final sel = _selected.contains(ex);
        final indexInSelected = _selected.indexOf(ex) + 1;

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
                      radius: 36,
                      backgroundColor: Colors.white12,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          ex.image,
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
              const SizedBox(height: 8),
              Text(
                ex.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sel ? Colors.greenAccent : Colors.white70,
                  fontSize: 13, // ขนาดชื่อท่าเพิ่มขึ้น
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Button(
        onPressed: _onNext,
        isEnabled: _selected.isNotEmpty,
        buttonText: 'ถัดไป',
      ),
    );
  }
}
