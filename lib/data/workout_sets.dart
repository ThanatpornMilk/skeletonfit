class WorkoutSet {
  final String name;        
  final String subtitle;    
  final List<ExerciseInfo> exercises;
  final List<String> muscles;

  WorkoutSet({
    required this.name,
    required this.subtitle,
    required this.exercises,
    this.muscles = const [],
  });
}

class ExerciseInfo {
  final String name;
  final String sets;
  final String reps;
  final String image;

  ExerciseInfo({
    required this.name,
    required this.sets,
    required this.reps,
    required this.image,
  });
}

final List<WorkoutSet> workoutSets = [
  WorkoutSet(
    name: 'Upper Body',
    subtitle: 'กล้ามเนื้อส่วนบน',
    exercises: [
      ExerciseInfo(
        name: 'Plank to Push-ups',
        sets: '3 เซต',
        reps: '8–10 ครั้ง/ข้าง',
        image: 'assets/images/ex1.png',
      ),
      ExerciseInfo(
        name: 'Push-ups',
        sets: '3 เซต',
        reps: '10–12 ครั้ง',
        image: 'assets/images/ex2.png',
      ),
      ExerciseInfo(
        name: 'Pike Push-ups',
        sets: '3 เซต',
        reps: '8–10 ครั้ง',
        image: 'assets/images/ex3.png',
      ),
      ExerciseInfo(
        name: 'Diamond Push-ups',
        sets: '2–3 เซต',
        reps: '8–10 ครั้ง',
        image: 'assets/images/ex3.png',
      ),
      ExerciseInfo(
        name: 'Crab Walks',
        sets: '3 เซต',
        reps: '10–12 ก้าว/ข้าง',
        image: 'assets/images/ex3.png',
      ),
      ExerciseInfo(
        name: 'Superman',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/ex3.png',
      ),
    ],
    muscles: [
      'หน้าอก (Pectoralis)',
      'หลัง (Latissimus)',
      'ไหล่ (Deltoid)',
      'แขน (Biceps & Triceps)',
    ],
  ),
  WorkoutSet(
    name: 'Lower Body',
    subtitle: 'กล้ามเนื้อส่วนล่าง',
    exercises: [
      ExerciseInfo(
        name: 'Bodyweight Squat',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/lower1.png',
      ),
      ExerciseInfo(
        name: 'Lunge',
        sets: '3 เซต',
        reps: '10–12 ครั้ง/ข้าง',
        image: 'assets/images/lower2.png',
      ),
      ExerciseInfo(
        name: 'Side Lying Leg Raise',
        sets: '2–3 เซต',
        reps: '12–15 ครั้ง/ข้าง',
        image: 'assets/images/lower3.png',
      ),
      ExerciseInfo(
        name: 'Glute Bridge',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/lower4.png',
      ),
      ExerciseInfo(
        name: 'Calf Raises',
        sets: '3 เซต',
        reps: '15–20 ครั้ง',
        image: 'assets/images/lower5.png',
      ),
      ExerciseInfo(
        name: 'Reverse Lunge',
        sets: '2–3 เซต',
        reps: '10–12 ครั้ง/ข้าง',
        image: 'assets/images/lower6.png',
      ),
    ],
    muscles: [
      'ต้นขาหน้า (Quadriceps)',
      'ต้นขาหลัง (Hamstrings)',
      'สะโพก (Gluteus)',
    ],
  ),
  WorkoutSet(
    name: 'Core',
    subtitle: 'กล้ามเนื้อแกนกลาง',
    exercises: [
      ExerciseInfo(
        name: 'Dead Bug',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/core1.png',
      ),
      ExerciseInfo(
        name: 'Plank',
        sets: '3 เซต',
        reps: '30–45 วินาที',
        image: 'assets/images/core2.png',
      ),
      ExerciseInfo(
        name: 'Sit-ups',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/core3.png',
      ),
      ExerciseInfo(
        name: 'Leg Raise',
        sets: '3 เซต',
        reps: '10–12 ครั้ง',
        image: 'assets/images/core4.png',
      ),
      ExerciseInfo(
        name: 'Russian Twist',
        sets: '2–3 เซต',
        reps: '12–15 ครั้ง/ข้าง',
        image: 'assets/images/core5.png',
      ),
      ExerciseInfo(
        name: 'Side Plank',
        sets: '2–3 เซต',
        reps: '20–30 วินาที/ข้าง',
        image: 'assets/images/core6.png',
      ),
    ],
    muscles: [
      'หน้าท้อง (Abdominis & Obliques)',
      'หลังส่วนล่าง (Erector Spinae)',
    ],
  ),
  WorkoutSet(
    name: 'Full Body',
    subtitle: 'กล้ามเนื้อทั้งตัว',
    exercises: [
      ExerciseInfo(
        name: 'Squat',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/full1.png',
      ),
      ExerciseInfo(
        name: 'Push-ups',
        sets: '3 เซต',
        reps: '10–12 ครั้ง',
        image: 'assets/images/ex1.png',
      ),
      ExerciseInfo(
        name: 'Glute Bridge',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/lower4.png',
      ),
      ExerciseInfo(
        name: 'Lunge',
        sets: '3 เซต',
        reps: '10–12 ครั้ง/ข้าง',
        image: 'assets/images/lower2.png',
      ),
      ExerciseInfo(
        name: 'Superman',
        sets: '3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/ex2.png',
      ),
      ExerciseInfo(
        name: 'Plank',
        sets: '3 เซต',
        reps: '30–45 วินาที',
        image: 'assets/images/core2.png',
      ),
      ExerciseInfo(
        name: 'Side Lunge',
        sets: '2–3 เซต',
        reps: '10–12 ครั้ง/ข้าง',
        image: 'assets/images/full2.png',
      ),
      ExerciseInfo(
        name: 'Reverse Snow Angel',
        sets: '2–3 เซต',
        reps: '12–15 ครั้ง',
        image: 'assets/images/full3.png',
      ),
    ],
    muscles: [
      'ครอบคลุมกล้ามเนื้อทุกส่วนของร่างกาย'
    ],
  ),
];
