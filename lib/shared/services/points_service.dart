import 'dart:math';
import '../models/social_models.dart';

class PointsService {
  // Point values for different activities
  static const Map<String, int> _activityPoints = {
    'add_pet': 100,
    'upload_photo': 25,
    'complete_health_check': 50,
    'complete_training_session': 75,
    'achieve_milestone': 150,
    'complete_mindfulness_session': 60,
    'participate_community_event': 100,
    'help_other_user': 80,
    'maintain_streak': 20,
    'unlock_achievement': 200,
    'ai_analysis': 40,
    'share_progress': 30,
    'invite_friend': 150,
    'daily_login': 10,
    'weekly_goal': 200,
    'monthly_challenge': 500,
  };

  // Experience required for each level
  static const Map<int, int> _levelExperience = {
    1: 0,
    2: 100,
    3: 250,
    4: 450,
    5: 700,
    6: 1000,
    7: 1350,
    8: 1750,
    9: 2200,
    10: 2700,
    15: 5000,
    20: 8000,
    25: 12000,
    30: 17000,
    35: 23000,
    40: 30000,
    45: 38000,
    50: 50000,
  };

  /// Calculate points for an activity
  int calculatePointsForActivity(String activity, {Map<String, dynamic>? metadata}) {
    final basePoints = _activityPoints[activity] ?? 0;
    
    if (metadata != null) {
      // Bonus points for special circumstances
      if (metadata['difficulty'] == 'hard') {
        return (basePoints * 1.5).round();
      } else if (metadata['difficulty'] == 'easy') {
        return (basePoints * 0.8).round();
      }
      
      // Streak bonus
      if (metadata['streak'] != null && metadata['streak'] > 7) {
        return (basePoints * (1 + (metadata['streak'] - 7) * 0.1)).round();
      }
      
      // Time-based bonus
      if (metadata['time_of_day'] == 'morning') {
        return (basePoints * 1.1).round();
      }
    }
    
    return basePoints;
  }

  /// Calculate level from experience points
  int calculateLevel(int experiencePoints) {
    int level = 1;
    
    for (final entry in _levelExperience.entries) {
      if (experiencePoints >= entry.value) {
        level = entry.key;
      } else {
        break;
      }
    }
    
    return level;
  }

  /// Calculate experience needed for next level
  int calculateExperienceToNextLevel(int currentLevel) {
    final nextLevel = currentLevel + 1;
    final currentExp = _levelExperience[currentLevel] ?? 0;
    final nextExp = _levelExperience[nextLevel] ?? currentExp * 2;
    
    return nextExp - currentExp;
  }

  /// Calculate progress to next level (0.0 to 1.0)
  double calculateProgressToNextLevel(int currentLevel, int currentExperience) {
    final currentExp = _levelExperience[currentLevel] ?? 0;
    final nextExp = _levelExperience[currentLevel + 1] ?? currentExp * 2;
    final expInCurrentLevel = currentExperience - currentExp;
    final expNeededForLevel = nextExp - currentExp;
    
    return expInCurrentLevel / expNeededForLevel;
  }

  /// Award points for an activity
  UserPoints awardPoints({
    required UserPoints currentPoints,
    required String activity,
    Map<String, dynamic>? metadata,
  }) {
    final pointsEarned = calculatePointsForActivity(activity, metadata: metadata);
    final newTotalPoints = currentPoints.totalPoints + pointsEarned;
    final newExperiencePoints = currentPoints.experiencePoints + pointsEarned;
    
    // Calculate new level
    final newLevel = calculateLevel(newExperiencePoints);
    final newExperienceToNextLevel = calculateExperienceToNextLevel(newLevel);
    
    // Update category points
    final category = _getCategoryForActivity(activity);
    final currentCategoryPoints = currentPoints.categoryPoints[category] ?? 0;
    final newCategoryPoints = Map<String, int>.from(currentPoints.categoryPoints);
    newCategoryPoints[category] = currentCategoryPoints + pointsEarned;
    
    // Update streak
    final newStreakDays = _calculateNewStreak(currentPoints.lastActivity);
    final newMaxStreakDays = max(currentPoints.maxStreakDays, newStreakDays);
    
    return UserPoints(
      userId: currentPoints.userId,
      totalPoints: newTotalPoints,
      level: newLevel,
      experiencePoints: newExperiencePoints,
      experienceToNextLevel: newExperienceToNextLevel,
      achievements: currentPoints.achievements,
      categoryPoints: newCategoryPoints,
      lastActivity: DateTime.now(),
      streakDays: newStreakDays,
      maxStreakDays: newMaxStreakDays,
    );
  }

  /// Get category for an activity
  String _getCategoryForActivity(String activity) {
    switch (activity) {
      case 'add_pet':
      case 'upload_photo':
        return 'pet_management';
      case 'complete_health_check':
      case 'achieve_milestone':
        return 'health_wellness';
      case 'complete_training_session':
        return 'training_behavior';
      case 'complete_mindfulness_session':
        return 'mindfulness';
      case 'participate_community_event':
      case 'help_other_user':
        return 'community';
      case 'ai_analysis':
        return 'ai_features';
      case 'share_progress':
        return 'social';
      case 'invite_friend':
        return 'referrals';
      case 'daily_login':
      case 'maintain_streak':
        return 'engagement';
      case 'weekly_goal':
      case 'monthly_challenge':
        return 'challenges';
      default:
        return 'general';
    }
  }

  /// Calculate new streak based on last activity
  int _calculateNewStreak(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity).inDays;
    
    if (difference <= 1) {
      // Activity within 24 hours, maintain streak
      return 1; // This will be updated by the calling function
    } else if (difference == 2) {
      // Activity within 48 hours, maintain streak
      return 1;
    } else {
      // Streak broken
      return 0;
    }
  }

  /// Check if user qualifies for an achievement
  List<Achievement> checkAchievements({
    required UserPoints userPoints,
    required List<Achievement> availableAchievements,
    Map<String, dynamic>? recentActivity,
  }) {
    final newAchievements = <Achievement>[];
    
    for (final achievement in availableAchievements) {
      if (achievement.isUnlocked) continue;
      
      if (_qualifiesForAchievement(achievement, userPoints, recentActivity)) {
        newAchievements.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }
    
    return newAchievements;
  }

  /// Check if user qualifies for a specific achievement
  bool _qualifiesForAchievement(
    Achievement achievement,
    UserPoints userPoints,
    Map<String, dynamic>? recentActivity,
  ) {
    final criteria = achievement.criteria;
    
    switch (achievement.type) {
      case AchievementType.firstPet:
        return userPoints.categoryPoints['pet_management'] != null &&
               userPoints.categoryPoints['pet_management']! > 0;
        
      case AchievementType.photoMaster:
        final photoCount = recentActivity?['photo_count'] ?? 0;
        return photoCount >= (criteria['required_photos'] ?? 10);
        
      case AchievementType.healthChampion:
        final healthChecks = userPoints.categoryPoints['health_wellness'] ?? 0;
        return healthChecks >= (criteria['required_health_checks'] ?? 50);
        
      case AchievementType.trainingGuru:
        final trainingSessions = userPoints.categoryPoints['training_behavior'] ?? 0;
        return trainingSessions >= (criteria['required_sessions'] ?? 30);
        
      case AchievementType.mindfulnessMaster:
        final mindfulnessSessions = userPoints.categoryPoints['mindfulness'] ?? 0;
        return mindfulnessSessions >= (criteria['required_sessions'] ?? 20);
        
      case AchievementType.communityHelper:
        final communityPoints = userPoints.categoryPoints['community'] ?? 0;
        return communityPoints >= (criteria['required_points'] ?? 500);
        
      case AchievementType.streakKeeper:
        return userPoints.streakDays >= (criteria['required_streak'] ?? 7);
        
      case AchievementType.milestoneReacher:
        return userPoints.level >= (criteria['required_level'] ?? 10);
        
      case AchievementType.aiExplorer:
        final aiPoints = userPoints.categoryPoints['ai_features'] ?? 0;
        return aiPoints >= (criteria['required_points'] ?? 200);
        
      case AchievementType.wellnessAdvocate:
        final totalPoints = userPoints.totalPoints;
        return totalPoints >= (criteria['required_points'] ?? 1000);
    }
    
    return false;
  }

  /// Generate leaderboard entries
  List<LeaderboardEntry> generateLeaderboard({
    required List<UserPoints> allUserPoints,
    required Map<String, String> userNames,
    required Map<String, String?> userPhotos,
    required Map<String, List<String>> userAchievements,
  }) {
    final entries = <LeaderboardEntry>[];
    
    // Sort by total points (descending)
    final sortedPoints = List<UserPoints>.from(allUserPoints)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    
    for (int i = 0; i < sortedPoints.length; i++) {
      final userPoints = sortedPoints[i];
      final rank = i + 1;
      
      entries.add(LeaderboardEntry(
        userId: userPoints.userId,
        userName: userNames[userPoints.userId] ?? 'Unknown User',
        userPhotoUrl: userPhotos[userPoints.userId],
        totalPoints: userPoints.totalPoints,
        level: userPoints.level,
        rank: rank,
        levelTitle: userPoints.levelTitle,
        streakDays: userPoints.streakDays,
        lastActivity: userPoints.lastActivity,
        recentAchievements: userAchievements[userPoints.userId] ?? [],
      ));
    }
    
    return entries;
  }

  /// Get leaderboard for specific category
  List<LeaderboardEntry> getCategoryLeaderboard({
    required List<LeaderboardEntry> allEntries,
    required String category,
  }) {
    final categoryEntries = List<LeaderboardEntry>.from(allEntries);
    
    // Sort by category-specific criteria
    switch (category) {
      case 'health_wellness':
        // Sort by health-related achievements
        categoryEntries.sort((a, b) {
          final aHealth = a.recentAchievements.where((achievement) => 
            achievement.toLowerCase().contains('health')).length;
          final bHealth = b.recentAchievements.where((achievement) => 
            achievement.toLowerCase().contains('health')).length;
          return bHealth.compareTo(aHealth);
        });
        break;
        
      case 'training_behavior':
        // Sort by training-related achievements
        categoryEntries.sort((a, b) {
          final aTraining = a.recentAchievements.where((achievement) => 
            achievement.toLowerCase().contains('training')).length;
          final bTraining = b.recentAchievements.where((achievement) => 
            achievement.toLowerCase().contains('training')).length;
          return bTraining.compareTo(aTraining);
        });
        break;
        
      case 'community':
        // Sort by community participation
        categoryEntries.sort((a, b) => b.streakDays.compareTo(a.streakDays));
        break;
        
      case 'streak':
        // Sort by current streak
        categoryEntries.sort((a, b) => b.streakDays.compareTo(a.streakDays));
        break;
        
      default:
        // Default sorting by total points
        categoryEntries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    }
    
    return categoryEntries;
  }

  /// Calculate weekly and monthly rankings
  Map<String, List<LeaderboardEntry>> calculateTimeBasedRankings({
    required List<LeaderboardEntry> allEntries,
    required Map<String, List<Map<String, dynamic>>> userActivities,
  }) {
    final weeklyEntries = <LeaderboardEntry>[];
    final monthlyEntries = <LeaderboardEntry>[];
    
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));
    
    for (final entry in allEntries) {
      final userActivity = userActivities[entry.userId] ?? [];
      
      // Calculate weekly points
      final weeklyPoints = userActivity
          .where((activity) => DateTime.parse(activity['timestamp']).isAfter(weekAgo))
          .fold<int>(0, (sum, activity) => sum + (activity['points'] ?? 0));
      
      // Calculate monthly points
      final monthlyPoints = userActivity
          .where((activity) => DateTime.parse(activity['timestamp']).isAfter(monthAgo))
          .fold<int>(0, (sum, activity) => sum + (activity['points'] ?? 0));
      
      weeklyEntries.add(entry.copyWith(totalPoints: weeklyPoints));
      monthlyEntries.add(entry.copyWith(totalPoints: monthlyPoints));
    }
    
    // Sort by time-based points
    weeklyEntries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    monthlyEntries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    
    // Update ranks
    for (int i = 0; i < weeklyEntries.length; i++) {
      weeklyEntries[i] = weeklyEntries[i].copyWith(rank: i + 1);
    }
    
    for (int i = 0; i < monthlyEntries.length; i++) {
      monthlyEntries[i] = monthlyEntries[i].copyWith(rank: i + 1);
    }
    
    return {
      'weekly': weeklyEntries,
      'monthly': monthlyEntries,
    };
  }

  /// Generate personalized recommendations based on points
  List<String> generateRecommendations({
    required UserPoints userPoints,
    required List<Achievement> availableAchievements,
  }) {
    final recommendations = <String>[];
    
    // Check for low-scoring categories
    final categoryPoints = userPoints.categoryPoints;
    final avgPoints = categoryPoints.values.fold<int>(0, (sum, points) => sum + points) / 
                     categoryPoints.length;
    
    for (final entry in categoryPoints.entries) {
      if (entry.value < avgPoints * 0.5) {
        recommendations.add('Focus on ${_getCategoryDisplayName(entry.key)} activities to earn more points!');
      }
    }
    
    // Check for achievable achievements
    for (final achievement in availableAchievements) {
      if (!achievement.isUnlocked) {
        final criteria = achievement.criteria;
        final currentValue = _getCurrentValueForAchievement(achievement.type, userPoints);
        final requiredValue = _getRequiredValueForAchievement(achievement.type, criteria);
        
        if (currentValue >= requiredValue * 0.8) {
          recommendations.add('You\'re close to unlocking "${achievement.title}"! Keep going!');
        }
      }
    }
    
    // Streak recommendations
    if (userPoints.streakDays < 7) {
      recommendations.add('Maintain your daily activity to build a 7-day streak and earn bonus points!');
    } else if (userPoints.streakDays < 30) {
      recommendations.add('Great streak! Aim for 30 days to unlock special rewards!');
    }
    
    // Level recommendations
    if (userPoints.progressToNextLevel > 0.8) {
      recommendations.add('You\'re almost at level ${userPoints.level + 1}! Complete a few more activities to level up!');
    }
    
    return recommendations;
  }

  /// Get display name for category
  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'pet_management':
        return 'pet management';
      case 'health_wellness':
        return 'health & wellness';
      case 'training_behavior':
        return 'training & behavior';
      case 'mindfulness':
        return 'mindfulness';
      case 'community':
        return 'community participation';
      case 'ai_features':
        return 'AI features';
      case 'social':
        return 'social sharing';
      case 'referrals':
        return 'referrals';
      case 'engagement':
        return 'daily engagement';
      case 'challenges':
        return 'challenges';
      default:
        return category.replaceAll('_', ' ');
    }
  }

  /// Get current value for achievement type
  int _getCurrentValueForAchievement(AchievementType type, UserPoints userPoints) {
    switch (type) {
      case AchievementType.firstPet:
        return userPoints.categoryPoints['pet_management'] ?? 0;
      case AchievementType.photoMaster:
        return 0; // This would come from recent activity
      case AchievementType.healthChampion:
        return userPoints.categoryPoints['health_wellness'] ?? 0;
      case AchievementType.trainingGuru:
        return userPoints.categoryPoints['training_behavior'] ?? 0;
      case AchievementType.mindfulnessMaster:
        return userPoints.categoryPoints['mindfulness'] ?? 0;
      case AchievementType.communityHelper:
        return userPoints.categoryPoints['community'] ?? 0;
      case AchievementType.streakKeeper:
        return userPoints.streakDays;
      case AchievementType.milestoneReacher:
        return userPoints.level;
      case AchievementType.aiExplorer:
        return userPoints.categoryPoints['ai_features'] ?? 0;
      case AchievementType.wellnessAdvocate:
        return userPoints.totalPoints;
    }
  }

  /// Get required value for achievement
  int _getRequiredValueForAchievement(AchievementType type, Map<String, dynamic> criteria) {
    switch (type) {
      case AchievementType.firstPet:
        return 1;
      case AchievementType.photoMaster:
        return criteria['required_photos'] ?? 10;
      case AchievementType.healthChampion:
        return criteria['required_health_checks'] ?? 50;
      case AchievementType.trainingGuru:
        return criteria['required_sessions'] ?? 30;
      case AchievementType.mindfulnessMaster:
        return criteria['required_sessions'] ?? 20;
      case AchievementType.communityHelper:
        return criteria['required_points'] ?? 500;
      case AchievementType.streakKeeper:
        return criteria['required_streak'] ?? 7;
      case AchievementType.milestoneReacher:
        return criteria['required_level'] ?? 10;
      case AchievementType.aiExplorer:
        return criteria['required_points'] ?? 200;
      case AchievementType.wellnessAdvocate:
        return criteria['required_points'] ?? 1000;
    }
  }
}