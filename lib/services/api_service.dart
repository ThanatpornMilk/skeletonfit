import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../data/exercises.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // สำหรับ Emulator ใช้ 10.0.2.2 (แทน localhost)
  static const String baseUrl = 'http://10.0.2.2:3000';

  // =================== ดึงรายการท่าออกกำลังกาย ===================
  static Future<List<ExerciseInfo>> fetchExercises() async {
    try {
      final uri = Uri.parse('$baseUrl/exercises');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data
            .map((e) => ExerciseInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load exercises (HTTP ${response.statusCode})'
          '${response.body.isNotEmpty ? " - ${response.body}" : ""}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out while loading exercises');
    } on SocketException {
      throw Exception('Network error: cannot reach the server');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format (${e.message})');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // =================== ดึงค่าที่ผู้ใช้เคยตั้งไว้ ===================
  static Future<Map<String, dynamic>?> fetchUserExercise(
      int userId, int exerciseId) async {
    try {
      final uri = Uri.parse('$baseUrl/user_exercises/$userId/$exerciseId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.isNotEmpty) {
          return data;
        }
        return null; // ถ้ายังไม่มีข้อมูล user_exercise
      } else {
        throw Exception(
            'Failed to fetch user exercise (HTTP ${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Timeout: Cannot fetch user exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error fetching user exercise: $e');
    }
  }

  // =================== บันทึกค่าที่ผู้ใช้แก้ไข ===================
  static Future<void> saveUserExercise({
    required int userId,
    required int exerciseId,
    required String sets,
    String? reps,
    String? duration,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user_exercises');

      final Map<String, dynamic> body = {
        'user_id': userId,
        'exercise_id': exerciseId,
        'sets': sets,
        if (reps != null && reps.isNotEmpty) 'reps': reps,
        if (duration != null && duration.isNotEmpty) 'duration': duration,
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to save user exercise (HTTP ${response.statusCode}) — ${response.body}');
      }

      debugPrint('Saved user exercise successfully: $body');
    } on TimeoutException {
      throw Exception('Timeout: Failed to save user exercise');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error saving user exercise: $e');
    }
  }

  // =================== ดึงรายการทั้งหมดของ user ===================
  static Future<List<Map<String, dynamic>>> fetchAllUserExercises(
      int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/user_exercises/$userId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch user exercises');
      }
    } on TimeoutException {
      throw Exception('Timeout: Failed to fetch user exercises');
    } on SocketException {
      throw Exception('Network error: Cannot connect to server');
    } catch (e) {
      throw Exception('Error fetching user exercises: $e');
    }
  }
}
