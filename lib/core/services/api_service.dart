import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Use your development machine's IP for physical device
  static const String baseUrl = 'http://10.52.1.199:3000';

  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  ApiService._internal();

  /// Helper to get the authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('User not logged in');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Create a new appointment securely via Backend
  Future<void> createAppointment({
    required String childId,
    required String doctorId,
    required String title,
    required DateTime date,
    required String description,
    required String doctorName,
  }) async {
    final url = Uri.parse('$baseUrl/appointments');
    final headers = await _getHeaders();

    final body = jsonEncode({
      'childId': childId,
      'doctorId':
          doctorId, // You might want to handle doctor logic on backend too
      'doctorName': doctorName,
      'title': title,
      'description': description,
      'date': date.toIso8601String(), // Send full ISO string
      'time':
          "${date.hour}:${date.minute.toString().padLeft(2, '0')}", // Simple time format expected by backend
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print('✅ Appointment created via Backend: ${response.body}');
      } else {
        print('❌ Backend Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create appointment: ${response.body}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
      throw Exception('Failed to connect to backend: $e');
    }
  }

  /// Fetch appointments (Example)
  Future<List<dynamic>> getAppointments() async {
    final url = Uri.parse('$baseUrl/appointments');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch appointments: ${response.body}');
    }
  }
}
