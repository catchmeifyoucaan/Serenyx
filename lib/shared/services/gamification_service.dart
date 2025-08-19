import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gamification_models.dart';
import 'api_service.dart';

class GamificationService extends ChangeNotifier {
  static const String _achievementsKey = 'user_achievements';
  static const String _levelKey = 'user_level';
  static const String _experienceKey = 'user_experience';
  static const String _streaksKey = 'user_streaks';
  static const String _rewardsKey = 'user_rewards';
  
  final ApiService _apiService = ApiService();
  
  // User progress
  int _level = 1;
  int _experience = 0;
  int _experienceToNextLevel = 100;
  
  // Achievements
  List<Achievement> _achievements = [];
  List<Achievement> _unlockedAchievements = [];
  
  // Streaks
  Map<String, int> _streaks = {};
  DateTime? _lastActivityDate;
  
  // Rewards
  List<Reward> _rewards = [];
  List<Reward> _unlockedRewards = [];
  
  // Social features
  List<Challenge> _activeChallenges = [];
  List<LeaderboardEntry> _leaderboard = [];
  
  // Getters
  int get level => _level;
  int get experience => _experience;
  int get experienceToNextLevel => _experienceToNextLevel;
  double get levelProgress => _experience / _experienceToNextLevel;
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<Achievement> get unlockedAchievements => List.unmodifiable(_unlockedAchievements);
  Map<String, int> get streaks => Map.unmodifiable(_streaks);
  List<Reward> get rewards => List.unmodifiable(_rewards);
  List<Reward> get unlockedRewards => List.unmodifiable(_unlockedRewards);
  List<Challenge> get activeChallenges => List.unmodifiable(_activeChallenges);
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  
  // Singleton pattern
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  /// Initialize the service
  Future<void> initialize() async {
    await _loadUserProgress();
    await _loadAchievements();
    await _loadRewards();
    await _loadChallenges();
    await _loadLeaderboard();
    _checkDailyStreaks();
  }

  /// Load user progress from local storage
  Future<void> _loadUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _level = prefs.getInt(_levelKey) ?? 1;
      _experience = prefs.getInt(_experienceKey) ?? 0;
      _experienceToNextLevel = _calculateExperienceToNextLevel(_level);
      
      final streaksJson = prefs.getString(_streaksKey);
      if (streaksJson != null) {
        _streaks = Map<String, int>.from(jsonDecode(streaksJson));
      }
      
      final lastActivityJson = prefs.getString('last_activity_date');
      if (lastActivityJson != null) {
        _lastActivityDate = DateTime.parse(lastActivityJson);
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
  }

  /// Save user progress to local storage
  Future<void> _saveUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_levelKey, _level);
      await prefs.setInt(_experienceKey, _experience);
      await prefs.setString(_streaksKey, jsonEncode(_streaks));
      
      if (_lastActivityDate != null) {
        await prefs.setString('last_activity_date', _lastActivityDate!.toIso8601String());
      }
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  /// Add experience points
  Future<void> addExperience(int points, {String? reason}) async {
    final oldLevel = _level;
    
    _experience += points;
    
    // Check for level up
    while (_experience >= _experienceToNextLevel) {
      _levelUp();
    }
    
    // Update streaks
    _updateStreak('daily_login');
    
    // Save progress
    await _saveUserProgress();
    
    // Check for achievements
    await _checkAchievements();
    
    // Notify listeners
    notifyListeners();
    
    // Show level up notification if applicable
    if (_level > oldLevel) {
      _showLevelUpNotification();
    }
  }

  /// Level up the user
  void _levelUp() {
    _level++;
    _experience -= _experienceToNextLevel;
    _experienceToNextLevel = _calculateExperienceToNextLevel(_level);
    
    // Unlock new rewards
    _unlockLevelRewards(_level);
  }

  /// Calculate experience needed for next level
  int _calculateExperienceToNextLevel(int level) {
    return 100 + (level - 1) * 50;
  }

  /// Show level up notification
  void _showLevelUpNotification() {
    // This would trigger a UI notification
    // Implementation depends on your notification system
  }

  /// Load achievements from API
  Future<void> _loadAchievements() async {
    try {
      // Load from API
      final achievementsData = await _apiService.getAchievements();
      _achievements = achievementsData.map((data) => Achievement.fromJson(data)).toList();
      
      // Load unlocked achievements from local storage
      final prefs = await SharedPreferences.getInstance();
      final unlockedJson = prefs.getString(_achievementsKey);
      if (unlockedJson != null) {
        final unlockedIds = List<String>.from(jsonDecode(unlockedJson));
        _unlockedAchievements = _achievements
            .where((achievement) => unlockedIds.contains(achievement.id))
            .toList();
      }
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  /// Check for new achievements
  Future<void> _checkAchievements() async {
    final newAchievements = <Achievement>[];
    
    for (final achievement in _achievements) {
      if (!_unlockedAchievements.contains(achievement) && _checkAchievementCondition(achievement)) {
        newAchievements.add(achievement);
      }
    }
    
    if (newAchievements.isNotEmpty) {
      await _unlockAchievements(newAchievements);
    }
  }

  /// Check if achievement condition is met
  bool _checkAchievementCondition(Achievement achievement) {
    switch (achievement.type) {
      case 'level':
        return _level >= achievement.requirement;
      case 'streak':
        return _streaks[achievement.streakType] ?? 0 >= achievement.requirement;
      case 'experience':
        return _experience >= achievement.requirement;
      case 'activity':
        return _checkActivityAchievement(achievement);
      default:
        return false;
    }
  }

  /// Check activity-based achievement
  bool _checkActivityAchievement(Achievement achievement) {
    // Implementation depends on your activity tracking
    return false;
  }

  /// Unlock achievements
  Future<void> _unlockAchievements(List<Achievement> achievements) async {
    _unlockedAchievements.addAll(achievements);
    
    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = _unlockedAchievements.map((a) => a.id).toList();
    await prefs.setString(_achievementsKey, jsonEncode(unlockedIds));
    
    // Add experience for unlocking achievements
    for (final achievement in achievements) {
      await addExperience(achievement.experienceReward, reason: 'Achievement: ${achievement.title}');
    }
    
    // Show achievement unlock notifications
    for (final achievement in achievements) {
      _showAchievementUnlock(achievement);
    }
  }

  /// Show achievement unlock notification
  void _showAchievementUnlock(Achievement achievement) {
    // This would trigger the achievement unlock dialog
    // Implementation depends on your UI system
  }

  /// Load rewards from API
  Future<void> _loadRewards() async {
    try {
      final rewardsData = await _apiService.getRewards();
      _rewards = rewardsData.map((data) => Reward.fromJson(data)).toList();
      
      // Load unlocked rewards from local storage
      final prefs = await SharedPreferences.getInstance();
      final unlockedJson = prefs.getString(_rewardsKey);
      if (unlockedJson != null) {
        final unlockedIds = List<String>.from(jsonDecode(unlockedJson));
        _unlockedRewards = _rewards
            .where((reward) => unlockedIds.contains(reward.id))
            .toList();
      }
    } catch (e) {
      print('Error loading rewards: $e');
    }
  }

  /// Unlock level rewards
  void _unlockLevelRewards(int level) {
    final levelRewards = _rewards.where((reward) => reward.unlockLevel == level).toList();
    
    for (final reward in levelRewards) {
      if (!_unlockedRewards.contains(reward)) {
        _unlockedRewards.add(reward);
        _showRewardUnlock(reward);
      }
    }
  }

  /// Show reward unlock notification
  void _showRewardUnlock(Reward reward) {
    // This would trigger the reward unlock dialog
    // Implementation depends on your UI system
  }

  /// Update streak
  void _updateStreak(String streakType) {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    if (_lastActivityDate != null) {
      final lastActivityString = '${_lastActivityDate!.year}-${_lastActivityDate!.month.toString().padLeft(2, '0')}-${_lastActivityDate!.day.toString().padLeft(2, '0')}';
      
      if (todayString == lastActivityString) {
        // Already updated today
        return;
      }
      
      final difference = today.difference(_lastActivityDate!).inDays;
      if (difference == 1) {
        // Consecutive day
        _streaks[streakType] = (_streaks[streakType] ?? 0) + 1;
      } else if (difference > 1) {
        // Streak broken
        _streaks[streakType] = 1;
      }
    } else {
      // First activity
      _streaks[streakType] = 1;
    }
    
    _lastActivityDate = today;
  }

  /// Check daily streaks
  void _checkDailyStreaks() {
    if (_lastActivityDate != null) {
      final today = DateTime.now();
      final difference = today.difference(_lastActivityDate!).inDays;
      
      if (difference > 1) {
        // Reset streaks if more than 1 day has passed
        _streaks.clear();
      }
    }
  }

  /// Load challenges from API
  Future<void> _loadChallenges() async {
    try {
      final challengesData = await _apiService.getChallenges();
      _activeChallenges = challengesData.map((data) => Challenge.fromJson(data)).toList();
    } catch (e) {
      print('Error loading challenges: $e');
    }
  }

  /// Load leaderboard from API
  Future<void> _loadLeaderboard() async {
    try {
      final leaderboardData = await _apiService.getLeaderboard();
      _leaderboard = leaderboardData.map((data) => LeaderboardEntry.fromJson(data)).toList();
    } catch (e) {
      print('Error loading leaderboard: $e');
    }
  }

  /// Complete a challenge
  Future<void> completeChallenge(String challengeId) async {
    final challenge = _activeChallenges.firstWhere((c) => c.id == challengeId);
    
    // Add experience reward
    await addExperience(challenge.experienceReward, reason: 'Challenge: ${challenge.title}');
    
    // Remove from active challenges
    _activeChallenges.remove(challenge);
    
    // Check for new challenges
    await _loadChallenges();
    
    notifyListeners();
  }

  /// Share achievement on social media
  Future<void> shareAchievement(Achievement achievement) async {
    // Implementation depends on your social sharing system
  }

  /// Get user statistics
  Map<String, dynamic> getUserStats() {
    return {
      'level': _level,
      'experience': _experience,
      'experienceToNextLevel': _experienceToNextLevel,
      'levelProgress': levelProgress,
      'totalAchievements': _achievements.length,
      'unlockedAchievements': _unlockedAchievements.length,
      'totalRewards': _rewards.length,
      'unlockedRewards': _unlockedRewards.length,
      'currentStreaks': _streaks,
      'activeChallenges': _activeChallenges.length,
    };
  }

  /// Get achievement progress
  double getAchievementProgress(Achievement achievement) {
    switch (achievement.type) {
      case 'level':
        return (_level / achievement.requirement).clamp(0.0, 1.0);
      case 'streak':
        final currentStreak = _streaks[achievement.streakType] ?? 0;
        return (currentStreak / achievement.requirement).clamp(0.0, 1.0);
      case 'experience':
        return (_experience / achievement.requirement).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }

  /// Get next achievement to unlock
  Achievement? getNextAchievement() {
    final lockedAchievements = _achievements
        .where((achievement) => !_unlockedAchievements.contains(achievement))
        .toList();
    
    if (lockedAchievements.isEmpty) return null;
    
    // Sort by progress (descending) and return the one with highest progress
    lockedAchievements.sort((a, b) {
      final progressA = getAchievementProgress(a);
      final progressB = getAchievementProgress(b);
      return progressB.compareTo(progressA);
    });
    
    return lockedAchievements.first;
  }
}

// Extension to add gamification methods to ApiService
extension GamificationApi on ApiService {
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final response = await _makeRequest('GET', '/gamification/achievements');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['achievements']);
  }
  
  Future<List<Map<String, dynamic>>> getRewards() async {
    final response = await _makeRequest('GET', '/gamification/rewards');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['rewards']);
  }
  
  Future<List<Map<String, dynamic>>> getChallenges() async {
    final response = await _makeRequest('GET', '/gamification/challenges');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['challenges']);
  }
  
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await _makeRequest('GET', '/gamification/leaderboard');
    final data = _parseResponse(response);
    return List<Map<String, dynamic>>.from(data['leaderboard']);
  }
}