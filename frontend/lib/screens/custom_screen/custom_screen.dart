import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';
import 'add_custom_screen.dart';
import '../../widgets/custom_workout_card.dart';
import '../../widgets/navbar.dart';
import '../../data/exercises.dart';

class CustomScreen extends StatefulWidget {
  const CustomScreen({super.key});

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  List<Map<String, dynamic>> _customWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      debugPrint('User not logged in');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await ApiService.fetchCustomWorkouts(userId);

      // เรียงใหม่ให้รายการล่าสุดอยู่บนสุด (ใช้ created_at ถ้ามี; ไม่มีก็ใช้ id)
      DateTime? pickDate(Map<String, dynamic> m) {
        final v = m['created_at'] ?? m['createdAt'];
        if (v == null) return null;
        try {
          return DateTime.parse(v.toString());
        } catch (_) {
          return null;
        }
      }

      int pickId(Map<String, dynamic> m) {
        return (m['id'] ?? m['workout_id'] ?? m['custom_workouts_id'] ?? 0) as int;
      }

      final sorted = [...data]..sort((a, b) {
        final da = pickDate(a);
        final db = pickDate(b);
        if (da != null && db != null) return db.compareTo(da);
        if (da != null && db == null) return -1;
        if (da == null && db != null) return 1;
        return pickId(b).compareTo(pickId(a));
      });

      setState(() {
        _customWorkouts = sorted;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching custom workouts: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text('Custom Workout', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCustomScreen()),
                );
                if (created == true) {
                  _loadWorkouts();
                }
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customWorkouts.isEmpty
              ? const Center(
                  child: Text(
                    'ยังไม่มี Custom Workout\nกด + เพื่อสร้าง Custom Workout',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: _customWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = _customWorkouts[index];
                      final exercisesJson = workout['exercises'] as List<dynamic>? ?? [];
                      final exercises =
                          exercisesJson.map((e) => ExerciseInfo.fromJson(e)).toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomWorkoutCard(
                          name: workout['workout_name'] ?? 'No name',
                          exercises: exercises,
                        ),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}
