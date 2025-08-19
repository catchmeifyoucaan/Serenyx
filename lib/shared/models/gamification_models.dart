class Achievement {
  final String id;
  final String title;
  final String description;
  final String type; // 'level', 'streak', 'experience', 'activity'
  final int requirement;
  final int experienceReward;
  final String? streakType; // For streak-based achievements
  final String icon;
  final String rarity; // 'common', 'uncommon', 'rare', 'epic', 'legendary'
  final String? category;
  final Map<String, dynamic>? metadata;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.experienceReward,
    this.streakType,
    required this.icon,
    required this.rarity,
    this.category,
    this.metadata,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      requirement: json['requirement'],
      experienceReward: json['experienceReward'],
      streakType: json['streakType'],
      icon: json['icon'],
      rarity: json['rarity'],
      category: json['category'],
      metadata: json['metadata'],
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'requirement': requirement,
      'experienceReward': experienceReward,
      'streakType': streakType,
      'icon': icon,
      'rarity': rarity,
      'category': category,
      'metadata': metadata,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Reward {
  final String id;
  final String title;
  final String description;
  final String type; // 'cosmetic', 'feature', 'bonus', 'exclusive'
  final int unlockLevel;
  final int? pointCost;
  final String icon;
  final String rarity;
  final String? category;
  final Map<String, dynamic>? metadata;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.unlockLevel,
    this.pointCost,
    required this.icon,
    required this.rarity,
    this.category,
    this.metadata,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      unlockLevel: json['unlockLevel'],
      pointCost: json['pointCost'],
      icon: json['icon'],
      rarity: json['rarity'],
      category: json['category'],
      metadata: json['metadata'],
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'])
          : null,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'unlockLevel': unlockLevel,
      'pointCost': pointCost,
      'icon': icon,
      'rarity': rarity,
      'category': category,
      'metadata': metadata,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type; // 'daily', 'weekly', 'monthly', 'special'
  final int experienceReward;
  final int? pointReward;
  final String icon;
  final String category;
  final Map<String, dynamic> requirements;
  final DateTime? expiresAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final double progress; // 0.0 to 1.0

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.experienceReward,
    this.pointReward,
    required this.icon,
    required this.category,
    required this.requirements,
    this.expiresAt,
    this.isCompleted = false,
    this.completedAt,
    this.progress = 0.0,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      experienceReward: json['experienceReward'],
      pointReward: json['pointReward'],
      icon: json['icon'],
      category: json['category'],
      requirements: json['requirements'] ?? {},
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'experienceReward': experienceReward,
      'pointReward': pointReward,
      'icon': icon,
      'category': category,
      'requirements': requirements,
      'expiresAt': expiresAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
    };
  }
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int rank;
  final int points;
  final int level;
  final String levelTitle;
  final int achievementsUnlocked;
  final int currentStreak;
  final String? category;
  final DateTime lastActivity;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.rank,
    required this.points,
    required this.level,
    required this.levelTitle,
    required this.achievementsUnlocked,
    required this.currentStreak,
    this.category,
    required this.lastActivity,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      rank: json['rank'],
      points: json['points'],
      level: json['level'],
      levelTitle: json['levelTitle'],
      achievementsUnlocked: json['achievementsUnlocked'],
      currentStreak: json['currentStreak'],
      category: json['category'],
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'rank': rank,
      'points': points,
      'level': level,
      'levelTitle': levelTitle,
      'achievementsUnlocked': achievementsUnlocked,
      'currentStreak': currentStreak,
      'category': category,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}

class UserProgress {
  final int level;
  final int experience;
  final int experienceToNextLevel;
  final double levelProgress;
  final String levelTitle;
  final int totalPoints;
  final int achievementsUnlocked;
  final int totalAchievements;
  final Map<String, int> streaks;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivity;

  UserProgress({
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.levelProgress,
    required this.levelTitle,
    required this.totalPoints,
    required this.achievementsUnlocked,
    required this.totalAchievements,
    required this.streaks,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivity,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      level: json['level'],
      experience: json['experience'],
      experienceToNextLevel: json['experienceToNextLevel'],
      levelProgress: json['levelProgress'].toDouble(),
      levelTitle: json['levelTitle'],
      totalPoints: json['totalPoints'],
      achievementsUnlocked: json['achievementsUnlocked'],
      totalAchievements: json['totalAchievements'],
      streaks: Map<String, int>.from(json['streaks']),
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'experience': experience,
      'experienceToNextLevel': experienceToNextLevel,
      'levelProgress': levelProgress,
      'levelTitle': levelTitle,
      'totalPoints': totalPoints,
      'achievementsUnlocked': achievementsUnlocked,
      'totalAchievements': totalAchievements,
      'streaks': streaks,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final String type;
  final int requirement;
  final int experienceReward;
  final String icon;
  final bool isReached;
  final DateTime? reachedAt;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.experienceReward,
    required this.icon,
    this.isReached = false,
    this.reachedAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      requirement: json['requirement'],
      experienceReward: json['experienceReward'],
      icon: json['icon'],
      isReached: json['isReached'] ?? false,
      reachedAt: json['reachedAt'] != null 
          ? DateTime.parse(json['reachedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'requirement': requirement,
      'experienceReward': experienceReward,
      'icon': icon,
      'isReached': isReached,
      'reachedAt': reachedAt?.toIso8601String(),
    };
  }
}

class SeasonalEvent {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final List<Challenge> challenges;
  final List<Reward> rewards;
  final String theme;
  final bool isActive;
  final double progress;

  SeasonalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.challenges,
    required this.rewards,
    required this.theme,
    this.isActive = false,
    this.progress = 0.0,
  });

  factory SeasonalEvent.fromJson(Map<String, dynamic> json) {
    return SeasonalEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      challenges: (json['challenges'] as List)
          .map((c) => Challenge.fromJson(c))
          .toList(),
      rewards: (json['rewards'] as List)
          .map((r) => Reward.fromJson(r))
          .toList(),
      theme: json['theme'],
      isActive: json['isActive'] ?? false,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'challenges': challenges.map((c) => c.toJson()).toList(),
      'rewards': rewards.map((r) => r.toJson()).toList(),
      'theme': theme,
      'isActive': isActive,
      'progress': progress,
    };
  }
}