import 'dart:math';
import '../models/social_models.dart';
import '../models/auth_models.dart';
import '../models/pet.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // Mock data for demonstration
  final Map<String, UserPoints> _userPoints = {};
  final List<Achievement> _achievements = [];
  final List<LeaderboardEntry> _leaderboard = [];
  final Map<String, List<Achievement>> _userAchievements = {};

  /// Initialize mock data
  void initializeMockData() {
    _initializeAchievements();
    _initializeUserPoints();
    _initializeLeaderboard();
  }

  /// Get user points and level
  Future<UserPoints> getUserPoints(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!_userPoints.containsKey(userId)) {
      // Create new user points
      final newUserPoints = UserPoints(
        userId: userId,
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        level: 1,
        levelTitle: 'Beginner',
        levelColor: _getLevelColor(1),
        achievements: [],
        lastEarnedDate: DateTime.now(),
      );
      _userPoints[userId] = newUserPoints;
      _userAchievements[userId] = [];
    }
    
    return _userPoints[userId]!;
  }

  /// Award points to user
  Future<bool> awardPoints({
    required String userId,
    required int points,
    required String reason,
    String? achievementId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_userPoints.containsKey(userId)) {
      await getUserPoints(userId);
    }

    final userPoints = _userPoints[userId]!;
    final oldLevel = userPoints.level;
    
    // Update points
    userPoints.totalPoints += points;
    userPoints.lastEarnedDate = DateTime.now();
    
    // Check for level up
    final newLevel = _calculateLevel(userPoints.totalPoints);
    if (newLevel > oldLevel) {
      userPoints.level = newLevel;
      userPoints.levelTitle = _getLevelTitle(newLevel);
      userPoints.levelColor = _getLevelColor(newLevel);
      
      // Award bonus points for leveling up
      final bonusPoints = newLevel * 10;
      userPoints.totalPoints += bonusPoints;
    }
    
    _userPoints[userId] = userPoints;
    
    // Update leaderboard
    _updateLeaderboard(userId, userPoints);
    
    return true;
  }

  /// Update daily streak
  Future<bool> updateDailyStreak(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_userPoints.containsKey(userId)) {
      await getUserPoints(userId);
    }

    final userPoints = _userPoints[userId]!;
    final today = DateTime.now();
    final lastEarned = userPoints.lastEarnedDate;
    
    // Check if it's a consecutive day
    if (today.difference(lastEarned).inDays <= 1) {
      userPoints.currentStreak++;
      if (userPoints.currentStreak > userPoints.longestStreak) {
        userPoints.longestStreak = userPoints.currentStreak;
      }
    } else {
      userPoints.currentStreak = 1;
    }
    
    _userPoints[userId] = userPoints;
    return true;
  }

  /// Unlock achievement
  Future<bool> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!_userPoints.containsKey(userId)) {
      await getUserPoints(userId);
    }

    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => Achievement.empty(),
    );

    if (achievement.id.isEmpty) return false;

    // Check if already unlocked
    if (_userAchievements[userId]!.any((a) => a.id == achievementId)) {
      return false;
    }

    // Unlock achievement
    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    _userAchievements[userId]!.add(unlockedAchievement);

    // Award points for achievement
    await awardPoints(
      userId: userId,
      points: achievement.pointsReward,
      reason: 'Achievement unlocked: ${achievement.title}',
      achievementId: achievementId,
    );

    return true;
  }

  /// Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_userAchievements.containsKey(userId)) {
      _userAchievements[userId] = [];
    }

    return _userAchievements[userId]!;
  }

  /// Get all available achievements
  Future<List<Achievement>> getAllAchievements() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_achievements);
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    int page = 0,
    int limit = 50,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    List<LeaderboardEntry> filteredLeaderboard = List.from(_leaderboard);

    // Filter by category if specified
    if (category != null) {
      filteredLeaderboard = filteredLeaderboard.where((entry) => 
        entry.levelTitle.toLowerCase().contains(category.toLowerCase())
      ).toList();
    }

    // Sort by total points (highest first)
    filteredLeaderboard.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredLeaderboard.length) {
      return [];
    }

    return filteredLeaderboard.sublist(
      startIndex, 
      endIndex > filteredLeaderboard.length ? filteredLeaderboard.length : endIndex
    );
  }

  /// Get user's leaderboard position
  Future<int> getUserLeaderboardPosition(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final sortedLeaderboard = List<LeaderboardEntry>.from(_leaderboard)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final userIndex = sortedLeaderboard.indexWhere((entry) => entry.userId == userId);
    return userIndex >= 0 ? userIndex + 1 : -1;
  }

  /// Get daily challenges
  Future<List<DailyChallenge>> getDailyChallenges(String userId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);

    return [
      DailyChallenge(
        id: '1',
        title: 'Take a photo of your pet',
        description: 'Capture a moment with your furry friend',
        points: 10,
        isCompleted: _isChallengeCompleted(userId, '1', today),
        type: 'photo',
        icon: '📸',
      ),
      DailyChallenge(
        id: '2',
        title: 'Log pet health data',
        description: 'Update your pet\'s health information',
        points: 15,
        isCompleted: _isChallengeCompleted(userId, '2', today),
        type: 'health',
        icon: '❤️',
      ),
      DailyChallenge(
        id: '3',
        title: 'Complete a training session',
        description: 'Spend time training your pet',
        points: 20,
        isCompleted: _isChallengeCompleted(userId, '3', today),
        type: 'training',
        icon: '🎯',
      ),
      DailyChallenge(
        id: '4',
        title: 'Share a pet moment',
        description: 'Post about your pet on social media',
        points: 25,
        isCompleted: _isChallengeCompleted(userId, '4', today),
        type: 'social',
        icon: '📱',
      ),
      DailyChallenge(
        id: '5',
        title: 'Read a pet care article',
        description: 'Learn something new about pet care',
        points: 15,
        isCompleted: _isChallengeCompleted(userId, '5', today),
        type: 'education',
        icon: '📚',
      ),
    ];
  }

  /// Complete daily challenge
  Future<bool> completeDailyChallenge({
    required String userId,
    required String challengeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final challenges = await getDailyChallenges(userId);
    final challenge = challenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => DailyChallenge.empty(),
    );

    if (challenge.id.isEmpty || challenge.isCompleted) {
      return false;
    }

    // Award points for completing challenge
    await awardPoints(
      userId: userId,
      points: challenge.points,
      reason: 'Daily challenge completed: ${challenge.title}',
    );

    // Mark challenge as completed
    _markChallengeCompleted(userId, challengeId, DateTime.now());

    return true;
  }

  /// Get weekly goals
  Future<List<WeeklyGoal>> getWeeklyGoals(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return [
      WeeklyGoal(
        id: '1',
        title: 'Complete 5 daily challenges',
        description: 'Finish at least 5 daily challenges this week',
        target: 5,
        current: _getWeeklyChallengeCount(userId, weekStart, weekEnd),
        points: 100,
        isCompleted: _getWeeklyChallengeCount(userId, weekStart, weekEnd) >= 5,
        type: 'challenges',
        icon: '🎯',
      ),
      WeeklyGoal(
        id: '2',
        title: 'Log health data 3 times',
        description: 'Update your pet\'s health information 3 times this week',
        target: 3,
        current: _getWeeklyHealthLogCount(userId, weekStart, weekEnd),
        points: 75,
        isCompleted: _getWeeklyHealthLogCount(userId, weekStart, weekEnd) >= 3,
        type: 'health',
        icon: '❤️',
      ),
      WeeklyGoal(
        id: '3',
        title: 'Train for 2 hours',
        description: 'Spend at least 2 hours training your pet this week',
        target: 120, // minutes
        current: _getWeeklyTrainingMinutes(userId, weekStart, weekEnd),
        points: 150,
        isCompleted: _getWeeklyTrainingMinutes(userId, weekStart, weekEnd) >= 120,
        type: 'training',
        icon: '🎓',
      ),
      WeeklyGoal(
        id: '4',
        title: 'Share 3 pet moments',
        description: 'Post about your pet 3 times this week',
        target: 3,
        current: _getWeeklySocialPosts(userId, weekStart, weekEnd),
        points: 125,
        isCompleted: _getWeeklySocialPosts(userId, weekStart, weekEnd) >= 3,
        type: 'social',
        icon: '📱',
      ),
    ];
  }

  /// Get rewards catalog
  Future<List<Reward>> getRewardsCatalog(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final userPoints = await getUserPoints(userId);
    
    return [
      Reward(
        id: '1',
        title: 'Custom Pet Badge',
        description: 'A special badge to display on your profile',
        pointsCost: 500,
        category: 'cosmetic',
        icon: '🏆',
        isAvailable: userPoints.totalPoints >= 500,
      ),
      Reward(
        id: '2',
        title: 'Premium Theme',
        description: 'Unlock a special app theme',
        pointsCost: 1000,
        category: 'cosmetic',
        icon: '🎨',
        isAvailable: userPoints.totalPoints >= 1000,
      ),
      Reward(
        id: '3',
        title: 'Extended Pet Profiles',
        description: 'Add more details to your pet profiles',
        pointsCost: 750,
        category: 'feature',
        icon: '📝',
        isAvailable: userPoints.totalPoints >= 750,
      ),
      Reward(
        id: '4',
        title: 'Advanced Analytics',
        description: 'Access detailed pet health analytics',
        pointsCost: 1500,
        category: 'feature',
        icon: '📊',
        isAvailable: userPoints.totalPoints >= 1500,
      ),
      Reward(
        id: '5',
        title: 'Priority Support',
        description: 'Get faster customer support',
        pointsCost: 2000,
        category: 'service',
        icon: '🚀',
        isAvailable: userPoints.totalPoints >= 2000,
      ),
    ];
  }

  /// Purchase reward
  Future<bool> purchaseReward({
    required String userId,
    required String rewardId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userPoints = await getUserPoints(userId);
    final rewards = await getRewardsCatalog(userId);
    final reward = rewards.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => Reward.empty(),
    );

    if (reward.id.isEmpty || !reward.isAvailable) {
      return false;
    }

    if (userPoints.totalPoints < reward.pointsCost) {
      return false;
    }

    // Deduct points
    await awardPoints(
      userId: userId,
      points: -reward.pointsCost,
      reason: 'Reward purchased: ${reward.title}',
    );

    // Add reward to user's inventory
    _addRewardToInventory(userId, reward);

    return true;
  }

  /// Get user statistics
  Future<UserStatistics> getUserStatistics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userPoints = await getUserPoints(userId);
    final achievements = await getUserAchievements(userId);
    final leaderboardPosition = await getUserLeaderboardPosition(userId);

    return UserStatistics(
      userId: userId,
      totalPoints: userPoints.totalPoints,
      currentStreak: userPoints.currentStreak,
      longestStreak: userPoints.longestStreak,
      level: userPoints.level,
      achievementsUnlocked: achievements.where((a) => a.isUnlocked).length,
      totalAchievements: _achievements.length,
      leaderboardPosition: leaderboardPosition,
      pointsThisWeek: _getWeeklyPoints(userId),
      pointsThisMonth: _getMonthlyPoints(userId),
      averageDailyPoints: _getAverageDailyPoints(userId),
      favoriteActivities: _getFavoriteActivities(userId),
      lastActive: userPoints.lastEarnedDate,
    );
  }

  // Private helper methods
  void _initializeAchievements() {
    _achievements.addAll([
      Achievement(
        id: 'first_pet',
        title: 'First Pet',
        description: 'Add your first pet to Serenyx',
        type: AchievementType.firstPet,
        pointsReward: 100,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/first_pet.png',
        color: Colors.blue,
      ),
      Achievement(
        id: 'photo_master',
        title: 'Photo Master',
        description: 'Upload 10 photos of your pets',
        type: AchievementType.photoMaster,
        pointsReward: 150,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/photo_master.png',
        color: Colors.purple,
      ),
      Achievement(
        id: 'health_guru',
        title: 'Health Guru',
        description: 'Log health data for 7 consecutive days',
        type: AchievementType.healthGuru,
        pointsReward: 200,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/health_guru.png',
        color: Colors.green,
      ),
      Achievement(
        id: 'training_pro',
        title: 'Training Pro',
        description: 'Complete 20 training sessions',
        type: AchievementType.trainingPro,
        pointsReward: 300,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/training_pro.png',
        color: Colors.orange,
      ),
      Achievement(
        id: 'social_butterfly',
        title: 'Social Butterfly',
        description: 'Interact with 50 other pet owners',
        type: AchievementType.socialButterfly,
        pointsReward: 250,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/social_butterfly.png',
        color: Colors.pink,
      ),
      Achievement(
        id: 'community_leader',
        title: 'Community Leader',
        description: 'Create a community group with 100+ members',
        type: AchievementType.communityLeader,
        pointsReward: 500,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/community_leader.png',
        color: Colors.indigo,
      ),
      Achievement(
        id: 'daily_streak',
        title: 'Daily Streak',
        description: 'Maintain a 30-day activity streak',
        type: AchievementType.dailyStreak,
        pointsReward: 400,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/daily_streak.png',
        color: Colors.red,
      ),
      Achievement(
        id: 'wellness_advocate',
        title: 'Wellness Advocate',
        description: 'Complete all wellness checklists for a month',
        type: AchievementType.wellnessAdvocate,
        pointsReward: 350,
        isUnlocked: false,
        iconPath: 'assets/icons/achievements/wellness_advocate.png',
        color: Colors.teal,
      ),
    ]);
  }

  void _initializeUserPoints() {
    // Initialize with some sample users
    _userPoints['user1'] = UserPoints(
      userId: 'user1',
      totalPoints: 1250,
      currentStreak: 7,
      longestStreak: 15,
      level: 8,
      levelTitle: 'Pet Enthusiast',
      levelColor: _getLevelColor(8),
      achievements: [],
      lastEarnedDate: DateTime.now().subtract(const Duration(hours: 2)),
    );

    _userPoints['user2'] = UserPoints(
      userId: 'user2',
      totalPoints: 890,
      currentStreak: 3,
      longestStreak: 8,
      level: 6,
      levelTitle: 'Pet Lover',
      levelColor: _getLevelColor(6),
      achievements: [],
      lastEarnedDate: DateTime.now().subtract(const Duration(hours: 5)),
    );

    _userPoints['user3'] = UserPoints(
      userId: 'user3',
      totalPoints: 2100,
      currentStreak: 12,
      longestStreak: 25,
      level: 12,
      levelTitle: 'Pet Expert',
      levelColor: _getLevelColor(12),
      achievements: [],
      lastEarnedDate: DateTime.now().subtract(const Duration(hours: 1)),
    );
  }

  void _initializeLeaderboard() {
    _userPoints.forEach((userId, userPoints) {
      _leaderboard.add(LeaderboardEntry(
        userId: userId,
        userName: _getUserName(userId),
        userPhotoUrl: _getUserPhotoUrl(userId),
        totalPoints: userPoints.totalPoints,
        level: userPoints.level,
        levelTitle: userPoints.levelTitle,
        levelColor: userPoints.levelColor,
        streakDays: userPoints.currentStreak,
        recentAchievements: _getRecentAchievements(userId),
        lastActivity: userPoints.lastEarnedDate,
      ));
    });
  }

  int _calculateLevel(int totalPoints) {
    // Simple level calculation: every 100 points = 1 level
    return (totalPoints / 100).floor() + 1;
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Pet Lover';
    if (level < 15) return 'Pet Enthusiast';
    if (level < 20) return 'Pet Expert';
    if (level < 25) return 'Pet Master';
    if (level < 30) return 'Pet Legend';
    return 'Pet God';
  }

  Color _getLevelColor(int level) {
    if (level < 5) return Colors.grey;
    if (level < 10) return Colors.blue;
    if (level < 15) return Colors.green;
    if (level < 20) return Colors.orange;
    if (level < 25) return Colors.purple;
    if (level < 30) return Colors.red;
    return Colors.amber;
  }

  void _updateLeaderboard(String userId, UserPoints userPoints) {
    final existingIndex = _leaderboard.indexWhere((entry) => entry.userId == userId);
    
    if (existingIndex >= 0) {
      _leaderboard[existingIndex] = _leaderboard[existingIndex].copyWith(
        totalPoints: userPoints.totalPoints,
        level: userPoints.level,
        levelTitle: userPoints.levelTitle,
        levelColor: userPoints.levelColor,
        streakDays: userPoints.currentStreak,
        lastActivity: userPoints.lastEarnedDate,
      );
    } else {
      _leaderboard.add(LeaderboardEntry(
        userId: userId,
        userName: _getUserName(userId),
        userPhotoUrl: _getUserPhotoUrl(userId),
        totalPoints: userPoints.totalPoints,
        level: userPoints.level,
        levelTitle: userPoints.levelTitle,
        levelColor: userPoints.levelColor,
        streakDays: userPoints.currentStreak,
        recentAchievements: _getRecentAchievements(userId),
        lastActivity: userPoints.lastEarnedDate,
      ));
    }
  }

  String _getUserName(String userId) {
    final names = {
      'user1': 'Sarah Johnson',
      'user2': 'Mike Chen',
      'user3': 'Emma Rodriguez',
    };
    return names[userId] ?? 'Unknown User';
  }

  String? _getUserPhotoUrl(String userId) {
    final photos = {
      'user1': 'https://example.com/sarah.jpg',
      'user2': 'https://example.com/mike.jpg',
      'user3': 'https://example.com/emma.jpg',
    };
    return photos[userId];
  }

  List<String> _getRecentAchievements(String userId) {
    // Mock recent achievements
    return ['First Pet', 'Photo Master'];
  }

  bool _isChallengeCompleted(String userId, String challengeId, DateTime date) {
    // Mock challenge completion status
    final random = Random(userId.hashCode + date.millisecondsSinceEpoch);
    return random.nextBool();
  }

  void _markChallengeCompleted(String userId, String challengeId, DateTime date) {
    // Mock challenge completion tracking
    // In real implementation, this would store in database
  }

  int _getWeeklyChallengeCount(String userId, DateTime weekStart, DateTime weekEnd) {
    // Mock weekly challenge count
    final random = Random(userId.hashCode);
    return random.nextInt(7);
  }

  int _getWeeklyHealthLogCount(String userId, DateTime weekStart, DateTime weekEnd) {
    // Mock weekly health log count
    final random = Random(userId.hashCode);
    return random.nextInt(5);
  }

  int _getWeeklyTrainingMinutes(String userId, DateTime weekStart, DateTime weekEnd) {
    // Mock weekly training minutes
    final random = Random(userId.hashCode);
    return random.nextInt(180) + 30; // 30-210 minutes
  }

  int _getWeeklySocialPosts(String userId, DateTime weekStart, DateTime weekEnd) {
    // Mock weekly social posts
    final random = Random(userId.hashCode);
    return random.nextInt(5);
  }

  void _addRewardToInventory(String userId, Reward reward) {
    // Mock reward inventory
    // In real implementation, this would store in database
  }

  int _getWeeklyPoints(String userId) {
    // Mock weekly points
    final random = Random(userId.hashCode);
    return random.nextInt(200) + 50;
  }

  int _getMonthlyPoints(String userId) {
    // Mock monthly points
    final random = Random(userId.hashCode);
    return random.nextInt(800) + 200;
  }

  double _getAverageDailyPoints(String userId) {
    // Mock average daily points
    final random = Random(userId.hashCode);
    return (random.nextInt(50) + 10).toDouble();
  }

  List<String> _getFavoriteActivities(String userId) {
    // Mock favorite activities
    return ['Health Logging', 'Photo Sharing', 'Training Sessions'];
  }
}

// Additional models for gamification
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isCompleted;
  final String type;
  final String icon;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.isCompleted,
    required this.type,
    required this.icon,
  });

  factory DailyChallenge.empty() {
    return DailyChallenge(
      id: '',
      title: '',
      description: '',
      points: 0,
      isCompleted: false,
      type: '',
      icon: '',
    );
  }
}

class WeeklyGoal {
  final String id;
  final String title;
  final String description;
  final int target;
  final int current;
  final int points;
  final bool isCompleted;
  final String type;
  final String icon;

  WeeklyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.current,
    required this.points,
    required this.isCompleted,
    required this.type,
    required this.icon,
  });
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String category;
  final String icon;
  final bool isAvailable;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.category,
    required this.icon,
    required this.isAvailable,
  });

  factory Reward.empty() {
    return Reward(
      id: '',
      title: '',
      description: '',
      pointsCost: 0,
      category: '',
      icon: '',
      isAvailable: false,
    );
  }
}

class UserStatistics {
  final String userId;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int achievementsUnlocked;
  final int totalAchievements;
  final int leaderboardPosition;
  final int pointsThisWeek;
  final int pointsThisMonth;
  final double averageDailyPoints;
  final List<String> favoriteActivities;
  final DateTime lastActive;

  UserStatistics({
    required this.userId,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.achievementsUnlocked,
    required this.totalAchievements,
    required this.leaderboardPosition,
    required this.pointsThisWeek,
    required this.pointsThisMonth,
    required this.averageDailyPoints,
    required this.favoriteActivities,
    required this.lastActive,
  });
}