import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:http/http.dart' as http;

class SoundscapeService {
  static final SoundscapeService _instance = SoundscapeService._internal();
  factory SoundscapeService() => _instance;
  SoundscapeService._internal();

  // Configure via env or remote config
  static const String _baseUrl = String.fromEnvironment(
    'SERENYX_API_BASE_URL',
    defaultValue: 'https://api.serenyx.com',
  );

  Future<String> _getIdToken() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return await user.getIdToken();
  }

  Future<Map<String, dynamic>> generateSoundscape({
    required String title,
    required String style,
    required List<String> favoritePetSounds,
    double durationSeconds = 60,
  }) async {
    final token = await _getIdToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/soundscape/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'style': style,
        'favoritePetSounds': favoritePetSounds,
        'durationSeconds': durationSeconds,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to generate soundscape: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listSoundscapes() async {
    final token = await _getIdToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/soundscape'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to list soundscapes: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return (data['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> deleteSoundscape({required String soundscapeId}) async {
    final token = await _getIdToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/soundscape/$soundscapeId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete soundscape: ${response.statusCode}');
    }
  }
}

