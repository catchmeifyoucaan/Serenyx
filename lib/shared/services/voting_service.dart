import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:http/http.dart' as http;

class VotingService {
  static final VotingService _instance = VotingService._internal();
  factory VotingService() => _instance;
  VotingService._internal();

  static const String _baseUrl = String.fromEnvironment(
    'SERENYX_API_BASE_URL',
    defaultValue: 'https://api.serenyx.com',
  );

  Future<String> _getIdToken() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return await user.getIdToken();
  }

  Future<List<Map<String, dynamic>>> listCandidates({int page = 1, int limit = 20}) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$_baseUrl/api/vote/candidates?page=$page&limit=$limit');
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode != 200) throw Exception('Failed to fetch candidates');
    final data = jsonDecode(res.body);
    return (data['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> voteForPet({required String candidateId}) async {
    final token = await _getIdToken();
    final res = await http.post(
      Uri.parse('$_baseUrl/api/vote/$candidateId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) throw Exception('Vote failed');
  }
}

