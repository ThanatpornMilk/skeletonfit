// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../data/exercises.dart';

class ApiService {
  // -------- Smart Base URL (รองรับ Emulator/Simulator/Desktop/Web) --------
  static String get baseUrl => _baseUrl;
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android Emulator
      if (Platform.isIOS) return 'http://localhost:3000';     // iOS Simulator
      return 'http://localhost:3000';                         // Windows/Mac/Linux
    } catch (_) {
      return 'http://localhost:3000';
    }
  }

  // ---------- Utils ----------
  static Uri _withRange(
    String path, {
    required DateTime from,
    required DateTime to,
    Map<String, String>? extra,
  }) {
    final q = {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      ...?extra,
    };
    return Uri.parse('$_baseUrl$path').replace(queryParameters: q);
  }

  static Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ======= ใช้เฉพาะ endpoint ที่ต้องล็อกอิน (แนบ JWT) =======
  static Future<String?> Function()? tokenProvider;
  static Future<String?> Function()? emailProvider; // ดึงอีเมลผู้ใช้ปัจจุบัน

  // ตั้งค่าตอนบูตแอป เช่น:
  // ApiService.tokenProvider = () async => await MyAuthStore.instance.getJwt();
  // ApiService.emailProvider = () async => await MyAuthStore.instance.getEmail();

  // ===============================================================

  static bool _isOk(int code) => code == 200 || code == 201 || code == 204;

  // =================== Exercises ===================
  static Future<List<ExerciseInfo>> fetchExercises() async {
    final uri = Uri.parse('$_baseUrl/exercises');
    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => ExerciseInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Failed to load exercises (HTTP ${response.statusCode}) - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out while loading exercises');
    } on SocketException {
      throw Exception('Network error: cannot reach the server');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// เพิ่มท่าออกกำลังกาย (Admin)
  static Future<void> addExercise(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/exercises');
    try {
      final headers = _jsonHeaders; // เปลี่ยนเป็น await _authJsonHeaders() ถ้าต้อง auth
      final res = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      if (!_isOk(res.statusCode)) {
        throw HttpException(
          'Failed to add exercise (HTTP ${res.statusCode}) - ${res.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to add exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error adding exercise: $e');
    }
  }

  /// แก้ไขท่าออกกำลังกาย (Admin)
  static Future<void> updateExercise(int id, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/exercises/$id');
    try {
      final headers = _jsonHeaders; // เปลี่ยนเป็น await _authJsonHeaders() ถ้าต้อง auth
      final res = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      if (!_isOk(res.statusCode)) {
        throw HttpException(
          'Failed to update exercise (HTTP ${res.statusCode}) - ${res.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to update exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error updating exercise: $e');
    }
  }

  /// ลบท่าออกกำลังกาย (Admin)
  static Future<void> deleteExercise(int id) async {
    final uri = Uri.parse('$_baseUrl/exercises/$id');
    try {
      final headers = _jsonHeaders; // เปลี่ยนเป็น await _authJsonHeaders() ถ้าต้อง auth
      final res = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (!_isOk(res.statusCode)) {
        throw HttpException(
          'Failed to delete exercise (HTTP ${res.statusCode}) - ${res.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to delete exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error deleting exercise: $e');
    }
  }

  // =================== Muscles (ใหม่ เพิ่มเพื่อดึงชื่อไทย) ===================
  /// ดึงข้อมูลกล้ามเนื้อทั้งหมดจาก backend
  static Future<List<Map<String, dynamic>>> fetchMuscles() async {
    final uri = Uri.parse('$_baseUrl/muscles');
    final res = await http
        .get(uri, headers: _jsonHeaders)
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      throw const FormatException('Invalid muscles format');
    }
    throw HttpException('Failed to fetch muscles (${res.statusCode}) - ${res.body}');
  }

  /// สร้าง `Map<int,String>` : muscle_id -> name_th
  static Future<Map<int, String>> fetchMuscleThMap() async {
    final list = await fetchMuscles();
    return {
      for (final m in list)
        (m['muscle_id'] as num).toInt(): (m['name_th'] ?? '').toString(),
    };
  }

  /// สร้าง `Map<String,String>` : name_en(lowercase) -> name_th
  static Future<Map<String, String>> fetchMuscleEnToThMap() async {
    final list = await fetchMuscles();
    return {
      for (final m in list)
        (m['name_en'] ?? '').toString().toLowerCase():
            (m['name_th'] ?? '').toString(),
    };
  }

  // =================== User Exercise (single) ===================
  static Future<Map<String, dynamic>?> fetchUserExercise(
      int userId, int exerciseId) async {
    final uri = Uri.parse('$_baseUrl/user_exercises/$userId/$exerciseId');
    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          return decoded;
        }
        return null;
      } else if (response.statusCode == 404 || response.statusCode == 204) {
        return null;
      } else {
        throw HttpException(
          'Failed to fetch user exercise (HTTP ${response.statusCode}) - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Cannot fetch user exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error fetching user exercise: $e');
    }
  }

  // =================== Save User Exercise ===================
  static Future<void> saveUserExercise({
    required int userId,
    required int exerciseId,
    required String sets,  
    String? reps,           // null ได้ (ท่าแบบ time-based)
    String? duration,       // null ได้ (ท่าแบบ reps-based)
    int? customWorkoutsId,  // null ได้
    DateTime? completedAt,  // ไม่ส่งจะใช้ NOW() ฝั่ง server
  }) async {
    // ตรวจสอบให้ baseUrl ชี้ไปที่ server 
    // Emulator Android: http://10.0.2.2:3000
    final uri = Uri.parse('$_baseUrl/exercise_history'); // ใช้ $_baseUrl ให้ถูกต้อง

    int? toIntOrNull(String? s) {
      if (s == null) return null;
      final v = s.trim();
      if (v.isEmpty) return null;
      return int.tryParse(v);
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'exercise_id': exerciseId,
      'sets_done': toIntOrNull(sets),
      'reps_done': toIntOrNull(reps),
      'duration_done': toIntOrNull(duration),
      'completed_at': completedAt?.toIso8601String(),
      'custom_workouts_id': customWorkoutsId,
    }..removeWhere((k, v) => v == null); // ตัด key ที่เป็น null ออก

    try {
      final resp = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // ยอมรับทั้ง 201 และ 200
      if (resp.statusCode != 201 && resp.statusCode != 200) {
        debugPrint('[saveUserExercise] URI: $uri');
        debugPrint('[saveUserExercise] Payload: ${jsonEncode(payload)}');
        debugPrint('[saveUserExercise] Response: ${resp.statusCode} ${resp.body}');
        throw Exception('Save failed ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint('[saveUserExercise] Error: $e');
      rethrow;
    }
  }

  // =================== All User Exercises ===================
  static Future<List<Map<String, dynamic>>> fetchAllUserExercises(
      int userId) async {
    final uri = Uri.parse('$_baseUrl/user_exercises/$userId');
    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw const FormatException('Invalid response format');
        }
      } else {
        throw HttpException(
          'Failed to fetch user exercises (HTTP ${response.statusCode}) - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to fetch user exercises');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching user exercises: $e');
    }
  }

  // =================== Delete User Exercise ===================
  static Future<void> deleteUserExercise(int userId, int exerciseId) async {
    final uri = Uri.parse('$_baseUrl/user_exercises/$userId/$exerciseId');
    try {
      final response = await http
          .delete(uri, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 10));
      if (_isOk(response.statusCode) || response.statusCode == 404) {
        debugPrint(
            'Delete user exercise result: userId=$userId, exerciseId=$exerciseId, HTTP=${response.statusCode}');
      } else {
        throw HttpException(
          'Failed to delete user exercise (HTTP ${response.statusCode}) - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to delete user exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error deleting user exercise: $e');
    }
  }

  // =================== Custom Workouts ===================
  static Future<void> saveCustomWorkout({
    required int userId,
    required String name,
    required List<int> exerciseIds,
  }) async {
    final uri = Uri.parse('$_baseUrl/custom_workouts');
    try {
      final body = jsonEncode({
        'user_id': userId,
        'name': name,
        'exercises': exerciseIds,
      });

      final response = await http
          .post(uri, headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 10));

      if (!_isOk(response.statusCode)) {
        throw HttpException(
          'Failed to save custom workout (HTTP ${response.statusCode}) - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to save custom workout');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error saving custom workout: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCustomWorkouts(
      int userId) async {
    final uri = Uri.parse('$_baseUrl/custom_workouts/$userId');
    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw const FormatException('Invalid custom workout format');
        }
      } else {
        throw HttpException(
          'Failed to fetch custom workouts (HTTP ${response.statusCode}) - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to fetch custom workouts');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error fetching custom workouts: $e');
    }
  }

  // =================== Exercise History ===================
  static Future<List<Map<String, dynamic>>> fetchExerciseHistory({
    required int userId,
    required DateTime from,
    required DateTime to,
    int limit = 200,
    int offset = 0,
  }) async {
    final uri = _withRange(
      '/exercise_history/$userId',
      from: from,
      to: to,
      extra: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    try {
      final res =
          await http.get(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        throw const FormatException('Invalid exercise history format');
      } else {
        throw HttpException(
          'Failed to fetch exercise history (HTTP ${res.statusCode}) - ${res.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to fetch exercise history');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching exercise history: $e');
    }
  }

  // =================== Workout Sessions ===================
  static Future<List<Map<String, dynamic>>> fetchWorkoutSessions({
    required int userId,
    required DateTime from,
    required DateTime to,
    int limit = 200,
    int offset = 0,
  }) async {
    final uri = _withRange(
      '/workout_sessions/$userId',
      from: from,
      to: to,
      extra: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    try {
      final res =
          await http.get(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        throw const FormatException('Invalid workout sessions format');
      } else {
        throw HttpException(
          'Failed to fetch workout sessions (HTTP ${res.statusCode}) - ${res.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to fetch workout sessions');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error fetching workout sessions: $e');
    }
  }

  /// ====== INSERT -> ตาราง request (POST /requests) ======
  static Future<void> addExerciseRequestPg({
    required int userId,
    required String nameEn,
    required int sets,
    required int reps,
    required String benefits,
    required String tips,
    int? durationSeconds,  // duration in seconds, optional
    required int muscleId1,
    int? muscleId2,
    int? muscleId3,
    int? muscleId4,
    int? muscleId5,
    required List<String> exerciseStepsLines,
  }) async {
    final steps = exerciseStepsLines;

    // ตรวจสอบค่าของ duration_seconds หรือ reps ก่อน
    if (durationSeconds == null && reps <= 0) {
      throw Exception('กรุณากรอกเวลาหรือจำนวนครั้ง');
    }

    // สร้างตัวแปร body สำหรับส่งข้อมูล
    final body = {
      'user_id': userId,
      'name_en': nameEn,
      'sets': sets,
      'reps': reps,
      'benefits': benefits,
      'tips': tips,
      'duration_seconds': durationSeconds,  // ส่งค่า duration หรือ null ถ้าไม่มี
      'muscle_id1': muscleId1,
      'muscle_id2': muscleId2,
      'muscle_id3': muscleId3,
      'muscle_id4': muscleId4,
      'muscle_id5': muscleId5,
      'exercise_steps1': steps.isNotEmpty ? steps[0] : null,
      'exercise_steps2': steps.length > 1 ? steps[1] : null,
      'exercise_steps3': steps.length > 2 ? steps[2] : null,
      'exercise_steps4': steps.length > 3 ? steps[3] : null,
      'exercise_steps5': steps.length > 4 ? steps[4] : null,
    };

    final uri = Uri.parse('$_baseUrl/requests');

    try {
      // ทำการส่งข้อมูลไปยัง API
      final res = await http
          .post(uri, headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));

      // ตรวจสอบการตอบกลับจาก API
      if (!_isOk(res.statusCode)) {
        throw HttpException(
          'Failed to add exercise (HTTP ${res.statusCode}) - ${res.body}',
        );
      }
    } catch (e) {
      debugPrint('Error adding exercise: $e');
      throw Exception('Error adding exercise: $e');
    }
  }
}