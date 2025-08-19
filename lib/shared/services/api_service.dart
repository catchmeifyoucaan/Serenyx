import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/api_config.dart';
import '../models/pet.dart';
import '../models/auth_models.dart';
import '../models/social_models.dart';

class ApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // HTTP client with timeout
  static final http.Client _client = http.Client();
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Get authentication token
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Set authentication token
  Future<void> _setAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Clear authentication token
  Future<void> _clearAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Make authenticated HTTP request
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$_baseUrl$endpoint');
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    try {
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await _client.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: requestHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle authentication errors
      if (response.statusCode == 401) {
        await _clearAuthToken();
        throw Exception('Authentication failed. Please log in again.');
      }

      return response;
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error. Please check your connection.');
      }
      rethrow;
    }
  }

  /// Parse JSON response
  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'API request failed');
    }
  }

  // ==================== AUTHENTICATION ENDPOINTS ====================

  /// Get current user info
  Future<User> getCurrentUser() async {
    final response = await _makeRequest('GET', '/auth/me');
    final data = _parseResponse(response);
    return User.fromJson(data);
  }

  /// Create custom token
  Future<String> createCustomToken() async {
    final response = await _makeRequest('POST', '/auth/token');
    final data = _parseResponse(response);
    return data['token'];
  }

  // ==================== PETS ENDPOINTS ====================

  /// Get all pets for current user
  Future<List<Pet>> getPets() async {
    final response = await _makeRequest('GET', '/pets');
    final data = _parseResponse(response);
    return (data['pets'] as List)
        .map((petJson) => Pet.fromJson(petJson))
        .toList();
  }

  /// Get a specific pet
  Future<Pet> getPet(String petId) async {
    final response = await _makeRequest('GET', '/pets/$petId');
    final data = _parseResponse(response);
    return Pet.fromJson(data);
  }

  /// Create a new pet
  Future<Pet> createPet(Map<String, dynamic> petData) async {
    final response = await _makeRequest('POST', '/pets', body: petData);
    final data = _parseResponse(response);
    return Pet.fromJson(data);
  }

  /// Update a pet
  Future<Pet> updatePet(String petId, Map<String, dynamic> petData) async {
    final response = await _makeRequest('PUT', '/pets/$petId', body: petData);
    final data = _parseResponse(response);
    return Pet.fromJson(data);
  }

  /// Delete a pet
  Future<void> deletePet(String petId) async {
    await _makeRequest('DELETE', '/pets/$petId');
  }

  // ==================== VOTING ENDPOINTS ====================

  /// Get all best pet entries
  Future<List<BestPetEntry>> getBestPetEntries({
    String? category,
    String? timeFrame,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'all') {
      queryParams['category'] = category;
    }
    if (timeFrame != null) {
      queryParams['timeFrame'] = timeFrame;
    }

    final queryString = queryParams.isNotEmpty 
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';
    
    final response = await _makeRequest('GET', '/voting$queryString');
    final data = _parseResponse(response);
    
    return (data['entries'] as List)
        .map((entryJson) => BestPetEntry.fromJson(entryJson))
        .toList();
  }

  /// Submit a pet for the contest
  Future<BestPetEntry> submitPetForContest(Map<String, dynamic> submissionData) async {
    final response = await _makeRequest('POST', '/voting/submit', body: submissionData);
    final data = _parseResponse(response);
    return BestPetEntry.fromJson(data);
  }

  /// Vote for a pet
  Future<Map<String, dynamic>> voteForPet(Map<String, dynamic> voteData) async {
    final response = await _makeRequest('POST', '/voting/vote', body: voteData);
    return _parseResponse(response);
  }

  /// Get voting history
  Future<List<Map<String, dynamic>>> getVotingHistory() async {
    final response = await _makeRequest('GET', '/voting/history');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['votes']);
  }

  /// Get contest statistics
  Future<Map<String, dynamic>> getContestStats() async {
    final response = await _makeRequest('GET', '/voting/stats');
    return _parseResponse(response);
  }

  // ==================== SOUNDSCAPE ENDPOINTS ====================

  /// Get user's soundscapes
  Future<List<Map<String, dynamic>>> getUserSoundscapes() async {
    final response = await _makeRequest('GET', '/soundscape');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['soundscapes']);
  }

  /// Get public soundscapes
  Future<List<Map<String, dynamic>>> getPublicSoundscapes({
    String? category,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'all') {
      queryParams['category'] = category;
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    final queryString = queryParams.isNotEmpty 
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';
    
    final response = await _makeRequest('GET', '/soundscape/public$queryString');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['soundscapes']);
  }

  /// Create a new soundscape
  Future<Map<String, dynamic>> createSoundscape(Map<String, dynamic> soundscapeData) async {
    final response = await _makeRequest('POST', '/soundscape', body: soundscapeData);
    return _parseResponse(response);
  }

  /// Generate AI soundscape
  Future<Map<String, dynamic>> generateSoundscape(Map<String, dynamic> generationData) async {
    final response = await _makeRequest('POST', '/soundscape/generate', body: generationData);
    return _parseResponse(response);
  }

  /// Get available voices
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    final response = await _makeRequest('GET', '/soundscape/voices');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['voices']);
  }

  /// Update a soundscape
  Future<Map<String, dynamic>> updateSoundscape(String soundscapeId, Map<String, dynamic> soundscapeData) async {
    final response = await _makeRequest('PUT', '/soundscape/$soundscapeId', body: soundscapeData);
    return _parseResponse(response);
  }

  /// Delete a soundscape
  Future<void> deleteSoundscape(String soundscapeId) async {
    await _makeRequest('DELETE', '/soundscape/$soundscapeId');
  }

  // ==================== USER ENDPOINTS ====================

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _makeRequest('GET', '/users/profile');
    return _parseResponse(response);
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    final response = await _makeRequest('PUT', '/users/profile', body: profileData);
    return _parseResponse(response);
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _makeRequest('GET', '/users/stats');
    return _parseResponse(response);
  }

  /// Get user's pets
  Future<List<Pet>> getUserPets() async {
    final response = await _makeRequest('GET', '/users/pets');
    final data = _parseResponse(response);
    return (data['pets'] as List)
        .map((petJson) => Pet.fromJson(petJson))
        .toList();
  }

  /// Get user's soundscapes
  Future<List<Map<String, dynamic>>> getUserSoundscapesList() async {
    final response = await _makeRequest('GET', '/users/soundscapes');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['soundscapes']);
  }

  /// Get user's votes
  Future<List<Map<String, dynamic>>> getUserVotes() async {
    final response = await _makeRequest('GET', '/users/votes');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['votes']);
  }

  /// Delete user account
  Future<Map<String, dynamic>> deleteUserAccount() async {
    final response = await _makeRequest('DELETE', '/users/account');
    return _parseResponse(response);
  }

  // ==================== HEALTH ENDPOINTS ====================

  /// Get health status
  Future<Map<String, dynamic>> getHealthStatus() async {
    final response = await _makeRequest('GET', '/health');
    return _parseResponse(response);
  }

  /// Get detailed health status
  Future<Map<String, dynamic>> getDetailedHealthStatus() async {
    final response = await _makeRequest('GET', '/health/detailed');
    return _parseResponse(response);
  }

  // ==================== UTILITY METHODS ====================

  /// Set authentication token (called after login)
  Future<void> setAuthToken(String token) async {
    await _setAuthToken(token);
  }

  /// Clear authentication token (called after logout)
  Future<void> clearAuthToken() async {
    await _clearAuthToken();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null;
  }

  /// Dispose of HTTP client
  void dispose() {
    _client.close();
  }
}

// ==================== MODEL CLASSES ====================

class BestPetEntry {
  final String id;
  final Pet pet;
  final String ownerName;
  final String ownerAvatar;
  final String category;
  int votes;
  final String description;
  final List<String> achievements;
  final List<String> tags;
  final DateTime createdAt;

  BestPetEntry({
    required this.id,
    required this.pet,
    required this.ownerName,
    required this.ownerAvatar,
    required this.category,
    required this.votes,
    required this.description,
    required this.achievements,
    required this.tags,
    required this.createdAt,
  });

  factory BestPetEntry.fromJson(Map<String, dynamic> json) {
    return BestPetEntry(
      id: json['id'],
      pet: Pet.fromJson(json['pet']),
      ownerName: json['ownerName'],
      ownerAvatar: json['ownerAvatar'],
      category: json['category'],
      votes: json['votes'],
      description: json['description'],
      achievements: List<String>.from(json['achievements']),
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet': pet.toJson(),
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'category': category,
      'votes': votes,
      'description': description,
      'achievements': achievements,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}