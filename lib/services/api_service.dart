import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/workout_sets.dart'; 

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<List<WorkoutSet>> fetchWorkoutSets() async {
    final response = await http.get(Uri.parse('$baseUrl/workout_sets'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => WorkoutSet.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load workout sets');
    }
  }
}
