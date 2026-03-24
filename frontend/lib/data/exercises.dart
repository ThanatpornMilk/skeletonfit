class ExerciseInfo {
  final int id;
  final String name;
  final String nameTh;
  final String sets;
  final String reps;
  final String duration;
  final String imageUrl;
  final String videoUrl;
  final List<String> steps;
  final String tips;
  final String benefits;
  final List<String> muscles;

  ExerciseInfo({
    required this.id,
    required this.name,
    required this.nameTh,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.imageUrl,
    required this.videoUrl,
    required this.steps,
    required this.tips,
    required this.benefits,
    required this.muscles,
  });

  /// แปลง dynamic -> String ปลอดภัย
  static String _toSafeString(dynamic v) {
    if (v == null) return '';
    if (v is num) return v.toString();
    return v.toString();
  }

  /// แปลง dynamic -> int 
  static int _toSafeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  /// steps 
  static List<String> _parseSteps(dynamic raw) {
    if (raw is List) {
      return raw.map((e) {
        if (e is Map) {
          return _toSafeString(
              e['description'] ?? e['desc'] ?? e['text'] ?? e['step']);
        }
        return _toSafeString(e);
      }).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  /// muscles 
  static List<String> _parseMuscles(dynamic raw) {
    if (raw is List) {
      return raw.map((e) {
        if (e is Map) {
          return _toSafeString(e['name'] ?? e['name_en'] ?? e['name_th']);
        }
        return _toSafeString(e);
      }).where((s) => s.isNotEmpty).toList();
    }
    final single = _toSafeString(raw);
    return single.isNotEmpty ? [single] : const [];
  }

  factory ExerciseInfo.fromJson(Map<String, dynamic> json) {
    return ExerciseInfo(
      // รองรับทั้ง id/exercise_id (int, string, หรือ num)
      id: _toSafeInt(json['id'] ?? json['exercise_id']),

      // รองรับ name / name_en / exercise_name
      name: _toSafeString(
        json['name'] ?? json['name_en'] ?? json['exercise_name'],
      ),

      // ภาษาไทย ถ้าไม่มีให้ว่าง
      nameTh: _toSafeString(json['name_th']),

      // แปลงเป็น string เสมอ (บางครั้ง backend ส่งเป็น int)
      sets: _toSafeString(json['sets']),
      reps: _toSafeString(json['reps']),
      duration: _toSafeString(json['duration']),

      // รูปภาพ
      imageUrl: _toSafeString(json['image_url'] ?? json['image']),

      // วิดีโอ (ลิงก์ Google Drive/อื่น ๆ)
      videoUrl: _toSafeString(json['video_url'] ?? json['video']),

      // steps / muscles รองรับทั้ง array ของ string และ array ของ object
      steps: _parseSteps(json['steps']),
      tips: _toSafeString(json['tips']),
      benefits: _toSafeString(json['benefits']),
      muscles: _parseMuscles(json['muscles']),
    );
  }
}
