import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;

class CommunityService {
  CommunityService._internal();
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;

  // Backend base URL (configure per environment)
  static const String _baseUrl = 'https://api.serenyx.com';

  Future<List<BestPetEntry>> fetchBestPetLeaderboard() async {
    final token = await _getIdToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/best-pet/leaderboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final entries = (data['entries'] as List)
          .map((e) => BestPetEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      return entries;
    }
    throw Exception('Failed to load leaderboard: ${response.statusCode}');
  }

  Future<bool> voteForPet(String petId) async {
    final token = await _getIdToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/best-pet/vote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'petId': petId}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<String> generateSoundscape({
    required String prompt,
    String voiceId = 'eleven_monolingual_v1',
  }) async {
    final token = await _getIdToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/soundscape/generate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'voiceId': voiceId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['audioUrl'] as String;
    }
    throw Exception('Failed to generate soundscape: ${response.statusCode}');
  }

  Future<String> _getIdToken() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return await user.getIdToken();
  }
}

class BestPetEntry {
  final String petId;
  final String name;
  final String type;
  final String breed;
  final String ownerId;
  final String? avatarUrl;
  final int votes;

  BestPetEntry({
    required this.petId,
    required this.name,
    required this.type,
    required this.breed,
    required this.ownerId,
    required this.votes,
    this.avatarUrl,
  });

  factory BestPetEntry.fromJson(Map<String, dynamic> json) {
    return BestPetEntry(
      petId: json['petId'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'Pet',
      breed: json['breed'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      votes: json['votes'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

