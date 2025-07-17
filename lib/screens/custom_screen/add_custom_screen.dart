import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/workout_sets.dart';
import 'custom_screen.dart';
import '../../widgets/button.dart';

class AddCustomScreen extends StatefulWidget {
  const AddCustomScreen({super.key});

  @override
  State<AddCustomScreen> createState() => _AddCustomScreenState();
}

class _AddCustomScreenState extends State<AddCustomScreen> {
  final _searchController = TextEditingController();
  late final List<ExerciseInfo> _allExercises;
  late List<ExerciseInfo> _filtered;
  final _selected = <ExerciseInfo>[];

  @override
  void initState() {
    super.initState();
    final combined = workoutSets.expand((ws) => ws.exercises);
    final seenNames = <String>{};
    _allExercises = combined.where((ex) => seenNames.add(ex.name)).toList();
    _filtered = List.from(_allExercises);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
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
      if (_selected.contains(ex)) {
        _selected.remove(ex);
      } else {
        _selected.add(ex);
      }
    });
  }

  void _onNext() {
    // TODO: นำชุดท่าที่เลือกไปใช้งานต่อ
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF181717);
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
                  // จุดไล่สีที่ 1 (มุมล่างซ้าย)
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
                  // จุดไล่สีที่ 2 (มุมขวาบน)
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CustomScreen()),
                (route) => false,
              );
            },
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
            onTap: () {
              // TODO: เปิด dialog สำหรับ filter
            },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Button(
        onPressed: _onNext,
        isEnabled: _selected.isNotEmpty,
        buttonText: 'Next',
      ),
    );
  }
}
