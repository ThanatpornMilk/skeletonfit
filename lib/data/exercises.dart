class ExerciseInfo {
  final int id;
  final String name;
  final String sets;
  final String reps;
  final String duration;
  final String imageUrl; 
  final List<String> steps;
  final String tips;
  final String benefits;
  final List<String> muscles;

  ExerciseInfo({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.imageUrl,
    required this.steps,
    required this.tips,
    required this.benefits,
    required this.muscles,
  });

  factory ExerciseInfo.fromJson(Map<String, dynamic> json) {
    return ExerciseInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      sets: json['sets'] ?? "",
      reps: json['reps'] ?? "",
      duration: json['duration'] ?? "",
      imageUrl: json['image_url'] ?? json['image'] ?? "", 
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      tips: json['tips'] ?? "",
      benefits: json['benefits'] ?? "",
      muscles: (json['muscles'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
