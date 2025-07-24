import 'package:flutter/material.dart';
import '../data/workout_sets.dart';
import 'muscle_card.dart';

class ExerciseListView extends StatelessWidget {
  final List<ExerciseInfo> exercises;
  final List<String> muscles;

  const ExerciseListView({
    super.key,
    required this.exercises,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: exercises.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == 0) return MuscleCard(muscles: muscles);
        final ex = exercises[index - 1];
        return AnimatedExerciseCard(
          imagePath: ex.image,
          title: ex.name,
          sets: ex.sets,
          reps: ex.reps,
          delay: Duration(milliseconds: 100 * (index - 1)),
        );
      },
    );
  }
}

class AnimatedExerciseCard extends StatefulWidget {
  final String imagePath, title, sets, reps;
  final Duration delay;

  const AnimatedExerciseCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.sets,
    required this.reps,
    required this.delay,
  });

  @override
  State<AnimatedExerciseCard> createState() => _AnimatedExerciseCardState();
}

class _AnimatedExerciseCardState extends State<AnimatedExerciseCard> with TickerProviderStateMixin {
  late final AnimationController _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late final AnimationController _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  late final Animation<Offset> _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
    .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  late final Animation<double> _fadeAnim = Tween<double>(begin: 0, end: 1)
    .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInOut));
  late final Animation<double> _scaleAnim = Tween<double>(begin: 0.8, end: 1.0)
    .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));
  late final Animation<double> _hoverAnim = Tween<double>(begin: 1.0, end: 1.02)
    .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut));

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _hoverCtrl.dispose();
    super.dispose();
  }

  String get setsRepsText {
    if (widget.sets.isNotEmpty && widget.reps.isNotEmpty) {
      return '${widget.sets} | เซตละ ${widget.reps}';
    } else if (widget.sets.isNotEmpty) {
      return widget.sets;
    } else if (widget.reps.isNotEmpty) {
      return widget.reps;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: _buildAnimatedCard(),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: _hoverAnim,
      builder: (context, child) => Transform.scale(
        scale: _hoverAnim.value,
        child: _buildCardContainer(),
      ),
    );
  }

  Widget _buildCardContainer() {
    return Container(
      decoration: _cardDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          onHover: _handleHover,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildImageBox(),
                const SizedBox(width: 20),
                Expanded(child: _buildTextInfo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.1),
          Color.fromRGBO(255, 255, 255, 0.05),
        ],
      ),
      border: Border.all(
        color: _isHovered ? const Color.fromRGBO(78, 205, 196, 0.3) : const Color.fromRGBO(255, 255, 255, 0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: _isHovered ? const Color.fromRGBO(78, 205, 196, 0.2) : const Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: _isHovered ? 16 : 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    isHovered ? _hoverCtrl.forward() : _hoverCtrl.reverse();
  }

  Widget _buildImageBox() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF2E8B57)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(78, 205, 196, 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.fitness_center, color: Colors.grey, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFE0E0E0)],
          ).createShader(bounds),
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (setsRepsText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF2E8B57)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 6),
              Text(
                setsRepsText,
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
