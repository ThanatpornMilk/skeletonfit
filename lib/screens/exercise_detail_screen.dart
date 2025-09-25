import 'package:flutter/material.dart';
import '../data/exercises.dart';
import '../widgets/button.dart';
import 'camera_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseInfo exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final Color green = const Color(0xFF2E9265);
  late TextEditingController _setsController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: widget.exercise.sets);
    _repsController = TextEditingController(text: widget.exercise.reps);
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final bool isTimeBased =
        exercise.name.toLowerCase().contains("plank"); 

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF181717),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white24,
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: ListView(
              children: [
                _buildExerciseImage(exercise),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildExerciseInfo(exercise, isTimeBased),
                      if (exercise.muscles.isNotEmpty) _buildMuscleTags(exercise),
                      const SizedBox(height: 24),
                      if (exercise.steps.isNotEmpty)
                        _buildSection("คำแนะนำ", exercise.steps),
                      if (exercise.tips.isNotEmpty) _buildTips(exercise),
                      _buildBenefits(exercise),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Button(
              buttonText: "เริ่มออกกำลังกาย",
              isEnabled: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CameraScreen(exercise: widget.exercise.name),
                  ),
                );
              },
              icon: Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Exercise Image ----------------
  Widget _buildExerciseImage(ExerciseInfo exercise) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        image: exercise.image.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(exercise.image), fit: BoxFit.cover)
            : null,
        gradient: exercise.image.isEmpty
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(128, 0, 128, 0.3),
                  Color.fromRGBO(33, 150, 243, 0.5),
                  Color.fromRGBO(0, 188, 212, 0.3),
                ],
              )
            : null,
      ),
      child: exercise.image.isEmpty
          ? const Center(
              child: Icon(Icons.fitness_center,
                  color: Colors.white70, size: 64),
            )
          : null,
    );
  }

  // ---------------- Exercise Info ----------------
  Widget _buildExerciseInfo(ExerciseInfo exercise, bool isTimeBased) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(18, 18, 18, 0.8), Color.fromRGBO(33, 33, 33, 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(97, 97, 97, 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEditableStatCard("เซต", _setsController, Icons.repeat, green),
          Container(height: 30, width: 1, color: const Color.fromRGBO(158, 158, 158, 1)),
          if (isTimeBased)
            _buildEditableStatCard("เวลา (วินาที)", _repsController, Icons.timer, green)
          else
            _buildEditableStatCard("ครั้ง", _repsController, Icons.fitness_center, green),
        ],
      ),
    );
  }

  Widget _buildEditableStatCard(
      String label, TextEditingController controller, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconAdjustButton(
              icon: Icons.remove,
              onPressed: () {
                setState(() {
                  int value = int.tryParse(controller.text) ?? 1;
                  if (value > 1) {
                    value--;
                    controller.text = value.toString();
                  }
                });
              },
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                controller.text,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildIconAdjustButton(
              icon: Icons.add,
              onPressed: () {
                setState(() {
                  int value = int.tryParse(controller.text) ?? 1;
                  value++;
                  controller.text = value.toString();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildIconAdjustButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // ---------------- Muscle Tags ----------------
  Widget _buildMuscleTags(ExerciseInfo exercise) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: exercise.muscles.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                exercise.muscles[index],
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Sections ----------------
  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((e) {
          int i = e.key;
          String text = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(18, 18, 18, 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color.fromRGBO(97, 97, 97, 0.3), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text("${i + 1}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(text,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white, height: 1.4))),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTips(ExerciseInfo exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildSectionTitle("เคล็ดลับ"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(18, 18, 18, 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(97, 97, 97, 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...exercise.tips.split('\n').map((line) {
                line = line.trim();
                if (line.isEmpty) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Expanded(
                          child: Text(line,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.4))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBenefits(ExerciseInfo exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("ประโยชน์"),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(18, 18, 18, 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(97, 97, 97, 0.3), width: 1),
          ),
          child: Text(
            exercise.benefits,
            style: const TextStyle(
                fontSize: 16, color: Colors.white, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white));
}
