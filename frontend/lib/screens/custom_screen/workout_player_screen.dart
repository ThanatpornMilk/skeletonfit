import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/exercises.dart';
import '../camera_screen.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final String title;
  final List<ExerciseInfo> exercises;
  final int initialIndex;

  const WorkoutPlayerScreen({
    super.key,
    required this.title,
    required this.exercises,
    this.initialIndex = 0,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.exercises.length - 1);
  }

  ExerciseInfo get current => widget.exercises[_index];

  void _next() {
    if (_index < widget.exercises.length - 1) {
      setState(() => _index++);
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  void _finish() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Workout complete!'),
        content: const Text('Great job'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  ImageProvider _imageProvider(String url) {
    final u = url.trim();
    if (u.isEmpty) return const AssetImage('assets/placeholder.png');
    if (u.startsWith('http://') || u.startsWith('https://')) return NetworkImage(u);
    return AssetImage(u);
  }

  Future<void> _openCamera() async {
    HapticFeedback.lightImpact();

    // map ค่า String -> int ให้ปลอดภัย
    final isTimeBased = current.name.toLowerCase().contains('plank');
    final int targetSets = int.tryParse(current.sets.isEmpty ? '1' : current.sets) ?? 1;
    final int targetRepsOrSecs = int.tryParse(
          (isTimeBased ? current.duration : current.reps).isEmpty
              ? (isTimeBased ? '30' : '10')
              : (isTimeBased ? current.duration : current.reps),
        ) ??
        (isTimeBased ? 30 : 10);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(
          exerciseId: current.id,      
          exercise: current.name,
          reps: targetRepsOrSecs,
          sets: targetSets,
        ),
      ),
    );

    // ถ้าต้องการให้ auto-next หลังกลับจากกล้อง
    // if (mounted) _next();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.exercises.length;
    final progress = (total <= 1) ? 1.0 : (_index + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Step ${_index + 1} / $total',
                style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF23303A),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E9265)),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2A33),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image(
                      image: _imageProvider(current.imageUrl),
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.fitness_center, color: Colors.white70, size: 64),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              current.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),
            Center(child: _CameraRoundButton(onTap: _openCamera)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2E9265)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _index == 0 ? null : _prev,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Prev'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E9265),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _next,
                    icon: Icon(_index < total - 1 ? Icons.chevron_right : Icons.flag),
                    label: Text(_index < total - 1 ? 'ถัดไป' : 'เสร็จสิ้น'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraRoundButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CameraRoundButton({required this.onTap});
  @override
  State<_CameraRoundButton> createState() => _CameraRoundButtonState();
}

class _CameraRoundButtonState extends State<_CameraRoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.96 : 1.0,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2E9265), Color(0xFF1E7A42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(46, 146, 101, 0.45),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Center(child: Icon(Icons.photo_camera, color: Colors.white, size: 30)),
        ),
      ),
    );
  }
}
