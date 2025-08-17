import 'dart:math';
import '../models/social_models.dart';
import '../models/auth_models.dart';
import '../models/pet.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // Real API endpoints - replace with your actual backend URLs
  static const String _baseUrl = 'https://api.serenyx.com';
  static const String _apiKey = 'YOUR_SERENYX_API_KEY'; // Replace with real key

  Future<UserPoints> getUserPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/points'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserPoints.fromJson(data);
      } else {
        throw Exception('Failed to fetch user points: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user points: $e');
    }
  }

  Future<bool> awardPoints({
    required String userId,
    required int points,
    required String reason,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/points/award'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'points': points,
          'reason': reason,
          'category': category,
          'metadata': metadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to award points: $e');
    }
  }

  Future<bool> updateDailyStreak(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/streak/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update daily streak: $e');
    }
  }

  Future<bool> unlockAchievement({
    required String userId,
    required String achievementId,
    Map<String, dynamic>? unlockData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/achievements/unlock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'achievementId': achievementId,
          'unlockData': unlockData ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/achievements'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final achievements = data['achievements'] as List;
        return achievements.map((achievement) => Achievement.fromJson(achievement)).toList();
      } else {
        throw Exception('Failed to fetch user achievements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user achievements: $e');
    }
  }

  Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/achievements'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final achievements = data['achievements'] as List;
        return achievements.map((achievement) => Achievement.fromJson(achievement)).toList();
      } else {
        throw Exception('Failed to fetch all achievements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch all achievements: $e');
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl/api/gamification/leaderboard').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = data['entries'] as List;
        return entries.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
      } else {
        throw Exception('Failed to fetch leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  Future<LeaderboardEntry?> getUserLeaderboardPosition(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/leaderboard/users/$userId/position'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['entry'] != null) {
          return LeaderboardEntry.fromJson(data['entry']);
        }
        return null;
      } else {
        throw Exception('Failed to fetch user leaderboard position: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user leaderboard position: $e');
    }
  }

  Future<List<DailyChallenge>> getDailyChallenges({
    String? userId,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (userId != null) queryParams['userId'] = userId;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl/api/gamification/challenges/daily').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final challenges = data['challenges'] as List;
        return challenges.map((challenge) => DailyChallenge.fromJson(challenge)).toList();
      } else {
        throw Exception('Failed to fetch daily challenges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch daily challenges: $e');
    }
  }

  Future<bool> completeDailyChallenge({
    required String userId,
    required String challengeId,
    Map<String, dynamic>? completionData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/challenges/daily/$challengeId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'completionData': completionData ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to complete daily challenge: $e');
    }
  }

  Future<List<WeeklyGoal>> getWeeklyGoals({
    String? userId,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (userId != null) queryParams['userId'] = userId;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl/api/gamification/goals/weekly').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final goals = data['goals'] as List;
        return goals.map((goal) => WeeklyGoal.fromJson(goal)).toList();
      } else {
        throw Exception('Failed to fetch weekly goals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch weekly goals: $e');
    }
  }

  Future<List<Reward>> getRewardsCatalog({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl/api/gamification/rewards').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rewards = data['rewards'] as List;
        return rewards.map((reward) => Reward.fromJson(reward)).toList();
      } else {
        throw Exception('Failed to fetch rewards catalog: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch rewards catalog: $e');
    }
  }

  Future<bool> purchaseReward({
    required String userId,
    required String rewardId,
    Map<String, dynamic>? purchaseData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/rewards/$rewardId/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'purchaseData': purchaseData ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to purchase reward: $e');
    }
  }

  Future<UserStatistics> getUserStatistics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/statistics'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserStatistics.fromJson(data);
      } else {
        throw Exception('Failed to fetch user statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user statistics: $e');
    }
  }

  // Helper methods for gamification logic
  int calculateLevel(int totalPoints) {
    // Level calculation formula: level = sqrt(totalPoints / 100) + 1
    return (sqrt(totalPoints / 100) + 1).floor();
  }

  String getLevelTitle(int level) {
    if (level >= 50) return 'Legendary Pet Guardian';
    if (level >= 40) return 'Master Pet Caretaker';
    if (level >= 30) return 'Expert Pet Parent';
    if (level >= 20) return 'Advanced Pet Owner';
    if (level >= 10) return 'Experienced Pet Lover';
    if (level >= 5) return 'Dedicated Pet Parent';
    if (level >= 2) return 'Pet Enthusiast';
    return 'New Pet Parent';
  }

  int getPointsForNextLevel(int currentLevel) {
    // Points needed for next level: (level^2 - level) * 100
    final nextLevel = currentLevel + 1;
    return (nextLevel * nextLevel - nextLevel) * 100;
  }

  double getProgressToNextLevel(int totalPoints, int currentLevel) {
    final pointsForCurrentLevel = (currentLevel * currentLevel - currentLevel) * 100;
    final pointsForNextLevel = getPointsForNextLevel(currentLevel);
    final pointsInCurrentLevel = totalPoints - pointsForCurrentLevel;
    
    return pointsInCurrentLevel / (pointsForNextLevel - pointsForCurrentLevel);
  }

  List<String> getAchievementSuggestions(User user, List<Achievement> unlockedAchievements) {
    final suggestions = <String>[];
    final unlockedIds = unlockedAchievements.map((a) => a.id).toSet();
    
    // Suggest achievements based on user's activity
    if (user.pets.isNotEmpty && !unlockedIds.contains('first_pet')) {
      suggestions.add('Add your first pet to unlock "First Pet Parent" achievement');
    }
    
    if (user.lastSignInAt != null && !unlockedIds.contains('login_streak_7')) {
      suggestions.add('Log in for 7 consecutive days to unlock "Dedicated User" achievement');
    }
    
    if (user.pets.length >= 2 && !unlockedIds.contains('multi_pet_owner')) {
      suggestions.add('Add a second pet to unlock "Multi-Pet Household" achievement');
    }
    
    return suggestions;
  }

  Map<String, dynamic> calculateStreakBonus(int currentStreak) {
    if (currentStreak >= 30) {
      return {
        'multiplier': 3.0,
        'bonusPoints': 100,
        'title': 'Streak Master',
      };
    } else if (currentStreak >= 14) {
      return {
        'multiplier': 2.5,
        'bonusPoints': 50,
        'title': 'Streak Champion',
      };
    } else if (currentStreak >= 7) {
      return {
        'multiplier': 2.0,
        'bonusPoints': 25,
        'title': 'Streak Warrior',
      };
    } else if (currentStreak >= 3) {
      return {
        'multiplier': 1.5,
        'bonusPoints': 10,
        'title': 'Streak Builder',
      };
    } else {
      return {
        'multiplier': 1.0,
        'bonusPoints': 0,
        'title': 'Getting Started',
      };
    }
  }

  List<String> getDailyChallengeSuggestions(User user, List<DailyChallenge> completedChallenges) {
    final suggestions = <String>[];
    final completedIds = completedChallenges.map((c) => c.id).toSet();
    
    // Suggest challenges based on user's profile and pets
    if (user.pets.isNotEmpty && !completedIds.contains('pet_photo_challenge')) {
      suggestions.add('Take a photo of your pet for bonus points');
    }
    
    if (!completedIds.contains('health_check_challenge')) {
      suggestions.add('Update your pet\'s health information');
    }
    
    if (!completedIds.contains('community_engagement_challenge')) {
      suggestions.add('Comment on a community post');
    }
    
    return suggestions;
  }

  Map<String, dynamic> calculateRewardValue(Reward reward, User user) {
    final baseValue = reward.pointCost;
    final userLevel = calculateLevel(user.totalPoints ?? 0);
    
    // Higher level users get better value
    final levelMultiplier = 1.0 + (userLevel * 0.05);
    final adjustedValue = (baseValue * levelMultiplier).round();
    
    return {
      'baseCost': baseValue,
      'adjustedCost': adjustedValue,
      'levelMultiplier': levelMultiplier,
      'savings': baseValue - adjustedValue,
      'isGoodDeal': adjustedValue < baseValue,
    };
  }

  List<String> getLeaderboardCategories() {
    return [
      'Overall Points',
      'Daily Streak',
      'Achievements Unlocked',
      'Community Contributions',
      'Pet Care Activities',
      'Training Progress',
      'Health Monitoring',
      'Social Engagement',
    ];
  }

  Map<String, dynamic> getGamificationMetrics(String userId) {
    // This would typically come from a database
    // For now, return a basic structure
    return {
      'totalPoints': 0,
      'currentLevel': 1,
      'levelTitle': 'New Pet Parent',
      'progressToNextLevel': 0.0,
      'currentStreak': 0,
      'longestStreak': 0,
      'achievementsUnlocked': 0,
      'totalAchievements': 0,
      'leaderboardPosition': null,
      'recentActivity': [],
      'upcomingMilestones': [],
    };
  }

  Future<bool> checkAndAwardMilestones(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/milestones/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to check milestones: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboardHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/users/$userId/leaderboard/history'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final history = data['history'] as List;
        return history.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch leaderboard history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch leaderboard history: $e');
    }
  }

  Future<Map<String, dynamic>> getSeasonalEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gamification/events/seasonal'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch seasonal events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch seasonal events: $e');
    }
  }

  Future<bool> participateInSeasonalEvent({
    required String userId,
    required String eventId,
    Map<String, dynamic>? participationData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/gamification/events/seasonal/$eventId/participate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'participationData': participationData ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to participate in seasonal event: $e');
    }
  }
}

// Helper function for square root calculation
double sqrt(double x) {
  return x.sqrt();
}