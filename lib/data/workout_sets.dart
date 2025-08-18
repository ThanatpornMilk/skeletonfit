class WorkoutSet {
  final int id;
  final String name;
  final String subtitle;
  final List<String> muscles;
  final List<ExerciseInfo> exercises;

  WorkoutSet({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.muscles,
    required this.exercises,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'],
      muscles: List<String>.from(json['muscles'] ?? []),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseInfo.fromJson(e))
          .toList(),
    );
  }
}

class ExerciseInfo {
  final int id;
  final String name;
  final String sets;
  final String reps;
  final String image;
  final List<String> steps;
  final String tips;
  final String benefits;
  final List<String> muscles;

  ExerciseInfo({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.image,
    required this.steps,
    required this.tips,
    required this.benefits,
    required this.muscles,
  });

  factory ExerciseInfo.fromJson(Map<String, dynamic> json) {
    return ExerciseInfo(
      id: json['id'],
      name: json['name'],
      sets: json['sets'] ?? "",
      reps: json['reps'] ?? "",
      image: json['image'] ?? "",
      steps: List<String>.from(json['steps'] ?? []),
      tips: json['tips'] ?? "",
      benefits: json['benefits'] ?? "",
      muscles: List<String>.from(json['muscles'] ?? []),
    );
  }
}
