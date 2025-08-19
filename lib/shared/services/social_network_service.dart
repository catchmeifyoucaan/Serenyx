import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/social_models.dart';
import '../models/auth_models.dart';
import '../models/pet.dart';

class SocialNetworkService {
  static final SocialNetworkService _instance = SocialNetworkService._internal();
  factory SocialNetworkService() => _instance;
  SocialNetworkService._internal();

  // Real API endpoints - replace with your actual backend URLs
  static const String _baseUrl = 'https://api.serenyx.com';
  static const String _apiKey = 'YOUR_SERENYX_API_KEY'; // Replace with real key

  Future<SocialPost> createPost({
    required String userId,
    required String content,
    required PostType type,
    List<String> hashtags = const [],
    List<String> mediaUrls = const [],
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'content': content,
          'type': type.name,
          'hashtags': hashtags,
          'mediaUrls': mediaUrls,
          'location': location,
          'metadata': metadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SocialPost.fromJson(data);
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<List<SocialPost>> getSocialFeed({
    String? userId,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (userId != null) queryParams['userId'] = userId;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl/api/social/feed').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = data['posts'] as List;
        return posts.map((post) => SocialPost.fromJson(post)).toList();
      } else {
        throw Exception('Failed to fetch social feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch social feed: $e');
    }
  }

  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'content': content,
          'parentCommentId': parentCommentId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<bool> sharePost({
    required String postId,
    required String userId,
    required SocialPlatform platform,
    String? customMessage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/posts/$postId/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'platform': platform.name,
          'customMessage': customMessage,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  Future<CommunityGroup> createGroup({
    required String name,
    required String description,
    required String creatorId,
    List<String> tags = const [],
    String? location,
    GroupPrivacy privacy = GroupPrivacy.public,
    List<String> rules = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'creatorId': creatorId,
          'tags': tags,
          'location': location,
          'privacy': privacy.name,
          'rules': rules,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CommunityGroup.fromJson(data);
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  Future<List<CommunityGroup>> getGroups({
    String? category,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;

      final uri = Uri.parse('$_baseUrl/api/social/groups').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final groups = data['groups'] as List;
        return groups.map((group) => CommunityGroup.fromJson(group)).toList();
      } else {
        throw Exception('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch groups: $e');
    }
  }

  Future<bool> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/groups/$groupId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/social/groups/$groupId/members/$userId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  Future<CommunityEvent> createEvent({
    required String name,
    required String description,
    required String organizerId,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    List<String> tags = const [],
    int maxParticipants,
    String? groupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'organizerId': organizerId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'location': location,
          'tags': tags,
          'maxParticipants': maxParticipants,
          'groupId': groupId,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CommunityEvent.fromJson(data);
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<CommunityEvent>> getEvents({
    String? category,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$_baseUrl/api/social/events').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['events'] as List;
        return events.map((event) => CommunityEvent.fromJson(event)).toList();
      } else {
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<bool> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/events/$eventId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to join event: $e');
    }
  }

  Future<bool> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/social/events/$eventId/participants/$userId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to leave event: $e');
    }
  }

  Future<List<ExpertProfile>> getExperts({
    String? specialization,
    String? location,
    bool? isVerified,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (specialization != null) queryParams['specialization'] = specialization;
      if (location != null) queryParams['location'] = location;
      if (isVerified != null) queryParams['isVerified'] = isVerified.toString();

      final uri = Uri.parse('$_baseUrl/api/social/experts').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final experts = data['experts'] as List;
        return experts.map((expert) => ExpertProfile.fromJson(expert)).toList();
      } else {
        throw Exception('Failed to fetch experts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch experts: $e');
    }
  }

  Future<bool> verifyExpert({
    required String expertId,
    required String verifierId,
    required String verificationMethod,
    Map<String, dynamic>? verificationData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/social/experts/$expertId/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'verifierId': verifierId,
          'verificationMethod': verificationMethod,
          'verificationData': verificationData ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to verify expert: $e');
    }
  }

  Future<List<String>> getTrendingHashtags({
    String? category,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl/api/social/hashtags/trending').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hashtags = data['hashtags'] as List;
        return hashtags.map((tag) => tag['name'] as String).toList();
      } else {
        throw Exception('Failed to fetch trending hashtags: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch trending hashtags: $e');
    }
  }

  Future<SocialSearchResult> searchSocialContent({
    required String query,
    String? category,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;

      final uri = Uri.parse('$_baseUrl/api/social/search').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SocialSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }

  // Helper method to extract hashtags from text
  List<String> extractHashtags(String text) {
    final hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  // Helper method to validate post content
  bool validatePostContent(String content) {
    if (content.trim().isEmpty) return false;
    if (content.length > 1000) return false; // Max 1000 characters
    return true;
  }

  // Helper method to sanitize hashtags
  List<String> sanitizeHashtags(List<String> hashtags) {
    return hashtags
        .map((tag) => tag.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), ''))
        .where((tag) => tag.isNotEmpty)
        .take(10) // Max 10 hashtags
        .toList();
  }

  // Helper method to calculate engagement score
  double calculateEngagementScore(SocialPost post) {
    final likes = post.likeCount.toDouble();
    final comments = post.commentCount.toDouble();
    final shares = post.shareCount.toDouble();
    
    // Weighted engagement formula
    return (likes * 1.0) + (comments * 2.0) + (shares * 3.0);
  }

  // Helper method to check if user can post
  bool canUserPost(User user) {
    // Check if user is suspended or has posting restrictions
    if (user.isSuspended ?? false) return false;
    if (user.postingRestricted ?? false) return false;
    
    // Check daily posting limit
    final today = DateTime.now();
    final userPostsToday = user.dailyPostCount ?? 0;
    final maxPostsPerDay = user.maxPostsPerDay ?? 10;
    
    return userPostsToday < maxPostsPerDay;
  }

  // Helper method to get user's posting statistics
  Map<String, dynamic> getUserPostingStats(String userId) {
    // This would typically come from a database
    // For now, return a basic structure
    return {
      'totalPosts': 0,
      'totalLikes': 0,
      'totalComments': 0,
      'totalShares': 0,
      'averageEngagement': 0.0,
      'topPerformingPost': null,
      'postingStreak': 0,
    };
  }

  // Helper method to moderate content
  bool moderateContent(String content) {
    // Basic content moderation
    final inappropriateWords = [
      'spam', 'scam', 'inappropriate', 'offensive',
      // Add more words as needed
    ];
    
    final lowerContent = content.toLowerCase();
    for (final word in inappropriateWords) {
      if (lowerContent.contains(word)) {
        return false; // Content flagged for moderation
      }
    }
    
    return true; // Content passes moderation
  }

  // Helper method to generate post recommendations
  List<String> generatePostRecommendations(User user, List<SocialPost> recentPosts) {
    final recommendations = <String>[];
    
    // Analyze user's posting patterns
    final postTypes = recentPosts.map((post) => post.type).toSet();
    
    if (!postTypes.contains(PostType.petPhoto)) {
      recommendations.add('Share a photo of your pet');
    }
    
    if (!postTypes.contains(PostType.healthUpdate)) {
      recommendations.add('Update on your pet\'s health journey');
    }
    
    if (!postTypes.contains(PostType.trainingProgress)) {
      recommendations.add('Share your training achievements');
    }
    
    if (!postTypes.contains(PostType.communityQuestion)) {
      recommendations.add('Ask the community for advice');
    }
    
    return recommendations;
  }

  // Helper method to calculate trending score
  double calculateTrendingScore(SocialPost post) {
    final now = DateTime.now();
    final postAge = now.difference(post.timestamp).inHours;
    final engagement = calculateEngagementScore(post);
    
    // Trending algorithm: engagement / (age + 2)^1.5
    return engagement / pow(postAge + 2, 1.5);
  }

  // Helper method to get related posts
  Future<List<SocialPost>> getRelatedPosts(SocialPost post, {int limit = 5}) async {
    try {
      final queryParams = <String, String>{
        'postId': post.id,
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/api/social/posts/${post.id}/related').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = data['posts'] as List;
        return posts.map((p) => SocialPost.fromJson(p)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Helper method to get user's social influence score
  double calculateSocialInfluenceScore(User user) {
    // This would typically calculate based on:
    // - Follower count
    // - Post engagement rates
    // - Community participation
    // - Expert verification status
    // - Content quality scores
    
    double score = 0.0;
    
    // Base score from followers
    score += (user.followerCount ?? 0) * 0.1;
    
    // Bonus for verified experts
    if (user.isExpertVerified ?? false) {
      score += 50.0;
    }
    
    // Bonus for active community members
    if (user.communityParticipationScore != null) {
      score += user.communityParticipationScore! * 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
}

// Helper function for power calculation
double pow(double x, double exponent) {
  return x.pow(exponent);
}