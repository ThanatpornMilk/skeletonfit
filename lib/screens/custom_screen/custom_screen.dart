import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/custom_workout_card.dart';
import '../../data/workout_sets.dart';
import 'add_custom_screen.dart';

class CustomScreen extends StatefulWidget {
  const CustomScreen({super.key});

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  final List<WorkoutSet> _customSets = [];

  void _navigateToAddCustom() async {
    final newSet = await Navigator.push<WorkoutSet>(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomScreen()),
    );
    if (newSet != null) {
      setState(() => _customSets.add(newSet));
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
        title: const Text('Custom', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _navigateToAddCustom,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white24,
            height: 1,
          ),
        ),
      ),
      body: _customSets.isEmpty
          ? const Center(
              child: Text(
                'เลือกท่าออกกำลังกายของคุณเอง',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: _customSets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return CustomWorkoutCard(workoutSet: _customSets[index]);
                },
              ),
            ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}
