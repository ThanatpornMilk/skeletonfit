import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/exercises.dart';
import '../../services/api_service.dart';
import '../../widgets/button.dart';
import '../../providers/user_provider.dart';

import 'workout_player_screen.dart';
import '../exercise_detail_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String title;                   
  final List<ExerciseInfo>? exercises;   

  const WorkoutDetailScreen({
    super.key,
    required this.title,
    this.exercises,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Future<List<ExerciseInfo>> _futureAll; // ใช้เมื่อไม่มี incoming

  // ค่าจาก DB ของผู้ใช้: exerciseId(string) -> {'sets','reps','duration'} (string ทั้งหมด)
  Map<String, Map<String, String>> _userVals = {};

  // videoUrl จาก DB: exerciseId(string) -> videoUrl(string)
  Map<String, String> _videoById = {};

  @override
  void initState() {
    super.initState();
    _futureAll = widget.exercises == null
        ? ApiService.fetchExercises()
        : Future<List<ExerciseInfo>>.value(const <ExerciseInfo>[]);

    // โหลดวิดีโอของทุกท่าไว้ก่อน (เอาไว้เติมให้ท่าที่ videoUrl ว่าง)
    _preloadVideoUrls();
  }

  Future<void> _preloadVideoUrls() async {
    try {
      final list = await ApiService.fetchExercises();
      if (!mounted) return;
      setState(() {
        _videoById = {
          for (final e in list) e.id.toString(): (e.videoUrl).toString(),
        };
      });
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final incoming = widget.exercises ?? const <ExerciseInfo>[];
    final hasIncoming = incoming.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: ColoredBox(color: Colors.white24, child: SizedBox(height: 1)),
        ),
      ),

      body: hasIncoming
          ? _buildBodyWithDb(incoming)
          : FutureBuilder<List<ExerciseInfo>>(
              future: _futureAll,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: Color(0xFF00D4AA)),
                    ),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error: ${snap.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }
                final data = snap.data ?? const <ExerciseInfo>[];
                if (data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No exercises available.',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  );
                }
                return _buildBodyWithDb(data);
              },
            ),

      // ปุ่ม Start แสดงเฉพาะตอนเข้ามาจากการ์ด Custom
      bottomNavigationBar: hasIncoming
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Button(
                buttonText: "เริ่มออกกำลังกาย",
                isEnabled: true,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutPlayerScreen(
                        title: widget.title,
                        exercises: incoming,
                      ),
                    ),
                  );
                  if (mounted) setState(() {}); // refresh ค่าจาก DB หลังกลับมา
                },
              ),
            )
          : null,
    );
  }

  /// โหลดค่า sets/reps/duration ของผู้ใช้จาก DB ให้ทุกท่าในลิสต์นี้
  Future<Map<String, Map<String, String>>> _loadUserValues(
      List<ExerciseInfo> items) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return {};

    final Map<String, Map<String, String>> out = {};
    await Future.wait(items.map((ex) async {
      try {
        final data = await ApiService.fetchUserExercise(userId, ex.id);
        if (data != null) {
          out[ex.id.toString()] = {
            'sets'    : (data['sets'] ?? '').toString(),
            'reps'    : (data['reps'] ?? '').toString(),
            'duration': (data['duration'] ?? '').toString(),
          };
        }
      } catch (_) {}
    }));
    return out;
  }

  /// คืน ExerciseInfo ที่เติม videoUrl จาก DB ถ้าของเดิมว่าง
  ExerciseInfo _mergeVideoUrl(ExerciseInfo ex) {
    final original = (ex.videoUrl).toString().trim();
    if (original.isNotEmpty) return ex;

    final fromDb = (_videoById[ex.id.toString()] ?? '').trim();
    if (fromDb.isEmpty) return ex;

    return ExerciseInfo(
      id: ex.id,
      name: ex.name,
      nameTh: ex.nameTh, 
      imageUrl: ex.imageUrl,
      sets: ex.sets,
      reps: ex.reps,
      duration: ex.duration,
      muscles: ex.muscles,
      tips: ex.tips,
      benefits: ex.benefits,
      steps: ex.steps,
      videoUrl: fromDb,
    );
  }


  Widget _buildBodyWithDb(List<ExerciseInfo> data) {
    return FutureBuilder<Map<String, Map<String, String>>>(
      future: _loadUserValues(data),
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        if (snap.hasData) _userVals = snap.data!;

        return Column(
          children: [
            if (loading)
              const LinearProgressIndicator(minHeight: 2, color: Color(0xFF00D4AA)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${data.length} exercises',
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // รายการท่า + ค่าจาก DB ใต้ชื่อ
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        children: data.map((ex) {
                          final v = _userVals[ex.id.toString()];
                          final isTimeBased =
                              ex.name.toLowerCase().contains('plank');

                          final setsDb = (v?['sets'] ?? '').trim();
                          final repsDb = (v?['reps'] ?? '').trim();
                          final durDb  = (v?['duration'] ?? '').trim();

                          final sets = setsDb.isNotEmpty ? setsDb : ex.sets;
                          final repsOrDur = isTimeBased
                              ? (durDb.isNotEmpty ? durDb : ex.duration)
                              : (repsDb.isNotEmpty ? repsDb : ex.reps);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20), 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24), 
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0.12),
                                  Color.fromRGBO(255, 255, 255, 0.06),
                                ],
                              ),
                              border: Border.all(
                                color: const Color.fromRGBO(255, 255, 255, 0.12),
                                width: 1.2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () async {
                                  final merged = _mergeVideoUrl(ex);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseDetailScreen(
                                        exercise: merged,
                                        isCustomWorkout: true,
                                      ),
                                    ),
                                  );
                                  if (mounted) setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20), 
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      _thumbLarge(ex.imageUrl), 
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ex.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.5, 
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _pill('เซต: $sets'),
                                                const SizedBox(width: 10),
                                                _pill(isTimeBased
                                                    ? 'เวลา: $repsOrDur วิ'
                                                    : 'ครั้ง: $repsOrDur'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.white70, size: 28), // ✅ ใหญ่ขึ้น
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _thumbLarge(String? url) {
    final has = (url ?? '').trim().isNotEmpty;
    return Container(
      width: 72, 
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF2E8B57)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        child: has
            ? Image.network(url!, fit: BoxFit.contain)
            : const Icon(Icons.fitness_center, color: Colors.grey, size: 34),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E9265),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
