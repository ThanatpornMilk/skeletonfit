import 'dart:async'; 
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../data/exercises.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

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
      throw Exception('Failed to load exercises - request timed out');
    } on SocketException {
      throw Exception('Failed to load exercises - cannot reach server (network)');
    } on FormatException catch (e) {
      throw Exception('Failed to load exercises - bad JSON (${e.message})');
    } on HttpException catch (e) {
      throw Exception('Failed to load exercises - http error (${e.message})');
    } catch (e) {
      throw Exception('Failed to load exercises - ${e.toString()}');
    }
  }
}
