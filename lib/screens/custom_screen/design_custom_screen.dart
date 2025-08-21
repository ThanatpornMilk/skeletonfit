import 'package:flutter/material.dart';
import '../../widgets/button.dart';
import '../../data/workout_sets.dart';

class DesignCustomScreen extends StatefulWidget {
  /// [{'exercise': ExerciseInfo, 'sets': int, 'reps': int}]
  final List<Map<String, dynamic>> plans;
  const DesignCustomScreen({super.key, required this.plans});

  @override
  State<DesignCustomScreen> createState() => _DesignCustomScreenState();
}

class _DesignCustomScreenState extends State<DesignCustomScreen> {
  final _nameCtrl = TextEditingController(text: 'Custom Workout');

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF181717);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Design', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ตั้งชื่อแผน',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _summaryTile(),
              const SizedBox(height: 12),
              Expanded(child: _previewList()),
              Button(
                onPressed: _finish,
                isEnabled: true,
                buttonText: 'เสร็จสิ้น',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile() {
    final n = widget.plans.length;
    final subtitle = '$n ท่า (กำหนดเซต/ครั้งต่อท่าแล้ว)';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สรุปแผน', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _previewList() {
    return ListView.separated(
      itemCount: widget.plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final ex = widget.plans[i]['exercise'] as ExerciseInfo;
        final sets = widget.plans[i]['sets'] as int;
        final reps = widget.plans[i]['reps'] as int;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.white12,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                ex.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: Colors.white54),
              ),
            ),
          ),
          title: Text(ex.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text('$sets เซต × $reps ครั้ง', style: const TextStyle(color: Colors.white70)),
        );
      },
    );
  }

  void _finish() {
    final name = _nameCtrl.text.trim().isEmpty ? 'Custom Workout' : _nameCtrl.text.trim();
    final exercises = widget.plans.map((p) => p['exercise'] as ExerciseInfo).toList();

    final set = WorkoutSet(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      subtitle: '${exercises.length} ท่า (ดูรายละเอียดเซต/ครั้งในแผน)',
      muscles: exercises.expand((e) => e.muscles).toSet().toList(),
      exercises: exercises,
    );

    Navigator.pop(context, set);
  }
}
