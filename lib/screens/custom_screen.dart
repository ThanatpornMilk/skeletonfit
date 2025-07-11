import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/workout_sets.dart';
import 'home_screen.dart';
import '../widgets/button.dart';  

class CustomScreen extends StatefulWidget {
  const CustomScreen({Key? key}) : super(key: key);

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  final _searchController = TextEditingController();
  late final List<ExerciseInfo> _allExercises;
  late List<ExerciseInfo> _filtered;
  final _selected = <ExerciseInfo>{};

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
      if (_selected.contains(ex))
        _selected.remove(ex);
      else
        _selected.add(ex);
    });
  }

  void _onNext() {
    // TODO: นำชุดท่าที่เลือกไปใช้งานต่อ
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF181717);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: bg,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: const Text('Custom', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white54),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.filter_list, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Filter Area',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (ctx, i) {
                  final ex = _filtered[i];
                  final sel = _selected.contains(ex);
                  return GestureDetector(
                    onTap: () => _toggle(ex),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  sel ? Colors.greenAccent : Colors.transparent,
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
                                errorBuilder: (_, __, ___) =>
                                    const Icon(
                                  Icons.fitness_center,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
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
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Button(
                onPressed: _onNext,                       
                isEnabled: _selected.isNotEmpty,          
                buttonText: 'Next',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
