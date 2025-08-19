import 'package:flutter/material.dart';
import '../data/workout_sets.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseInfo exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final Color green = const Color(0xFF2E9265);
  final ScrollController _scrollController = ScrollController();
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _offset = _scrollController.offset * 0.5);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Scaffold(
      backgroundColor: const Color(0xFF181717),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(exercise),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildExerciseInfo(exercise),
                      if (exercise.muscles.isNotEmpty) _buildMuscleTags(exercise),
                      const SizedBox(height: 24),
                      if (exercise.steps.isNotEmpty) _buildSection("คำแนะนำ", exercise.steps),
                      if (exercise.tips.isNotEmpty) _buildTips(exercise),
                      _buildBenefits(exercise),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ExerciseInfo exercise) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280,
      backgroundColor: const Color(0xFF181717),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, -_offset),
              child: exercise.image.isNotEmpty
                  ? Image.network(exercise.image, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(128, 0, 128, 0.3),
                            Color.fromRGBO(33, 150, 243, 0.5),
                            Color.fromRGBO(0, 188, 212, 0.3),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white70, size: 64),
                    ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromRGBO(0, 0, 0, 0.3), Color.fromRGBO(0, 0, 0, 0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildVideoButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(244, 67, 54, 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(244, 67, 54, 0.3), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            "วิดีโอท่าท่า",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo(ExerciseInfo exercise) {
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
      child: Column(
        children: [
          Text(exercise.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("เซต", exercise.sets, Icons.repeat, green),
              Container(height: 30, width: 1, color: const Color.fromRGBO(158, 158, 158, 1)),
              _buildStatCard("ครั้ง", exercise.reps, Icons.fitness_center, green),
            ],
          ),
        ],
      ),
    );
  }

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
                  child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.4))),
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
                      const Text("• ", style: TextStyle(color: Colors.white, fontSize: 18)),
                      Expanded(child: Text(line, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.4))),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(18, 18, 18, 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(97, 97, 97, 0.3), width: 1),
          ),
          child: Text(exercise.benefits, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white));

  Widget _buildCloseButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.6), borderRadius: BorderRadius.circular(24)),
        child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
      ),
    );
  }
}
