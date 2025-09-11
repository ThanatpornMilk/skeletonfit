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