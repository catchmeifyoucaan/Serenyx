import 'package:flutter/material.dart';

// Social Platform Enum
enum SocialPlatform {
  twitter,
  facebook,
  instagram,
  tiktok,
  whatsapp,
  telegram,
  email,
  sms,
}

// Achievement Types
enum AchievementType {
  firstPet,
  photoMaster,
  healthChampion,
  trainingGuru,
  mindfulnessMaster,
  communityHelper,
  streakKeeper,
  milestoneReacher,
  aiExplorer,
  wellnessAdvocate,
}

// Post Types
enum PostType {
  achievement,
  milestone,
  healthUpdate,
  trainingProgress,
  mindfulnessSession,
  communityEvent,
  petPhoto,
  wellnessTip,
}

// User Points Model
class UserPoints {
  final String userId;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final String levelTitle;
  final Color levelColor;
  final List<Achievement> achievements;
  final DateTime lastEarnedDate;

  UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.levelTitle,
    required this.levelColor,
    required this.achievements,
    required this.lastEarnedDate,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'],
      totalPoints: json['totalPoints'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      level: json['level'] ?? 1,
      levelTitle: json['levelTitle'] ?? 'Beginner',
      levelColor: _parseColor(json['levelColor']),
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      lastEarnedDate: json['lastEarnedDate'] != null
          ? DateTime.parse(json['lastEarnedDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'level': level,
      'levelTitle': levelTitle,
      'levelColor': levelColor.value,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'lastEarnedDate': lastEarnedDate.toIso8601String(),
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String) {
      // Handle hex color strings
      final hex = colorValue.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.blue;
  }

  UserPoints copyWith({
    String? userId,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? level,
    String? levelTitle,
    Color? levelColor,
    List<Achievement>? achievements,
    DateTime? lastEarnedDate,
  }) {
    return UserPoints(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      levelColor: levelColor ?? this.levelColor,
      achievements: achievements ?? this.achievements,
      lastEarnedDate: lastEarnedDate ?? this.lastEarnedDate,
    );
  }
}

// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int pointsReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String iconPath;
  final Color color;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.isUnlocked,
    this.unlockedAt,
    required this.iconPath,
    required this.color,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${json['type']}',
        orElse: () => AchievementType.firstPet,
      ),
      pointsReward: json['pointsReward'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      iconPath: json['iconPath'] ?? '',
      color: _parseColor(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'pointsReward': pointsReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'iconPath': iconPath,
      'color': color.value,
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String) {
      final hex = colorValue.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.blue;
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    int? pointsReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? iconPath,
    Color? color,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      pointsReward: pointsReward ?? this.pointsReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
    );
  }
}

// Leaderboard Entry Model
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int totalPoints;
  final int level;
  final String levelTitle;
  final Color levelColor;
  final int streakDays;
  final List<String> recentAchievements;
  final DateTime lastActivity;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.totalPoints,
    required this.level,
    required this.levelTitle,
    required this.levelColor,
    required this.streakDays,
    required this.recentAchievements,
    required this.lastActivity,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      levelTitle: json['levelTitle'] ?? 'Beginner',
      levelColor: _parseColor(json['levelColor']),
      streakDays: json['streakDays'] ?? 0,
      recentAchievements: List<String>.from(json['recentAchievements'] ?? []),
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'totalPoints': totalPoints,
      'level': level,
      'levelTitle': levelTitle,
      'levelColor': levelColor.value,
      'streakDays': streakDays,
      'recentAchievements': recentAchievements,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String) {
      final hex = colorValue.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.blue;
  }
}

// Community Event Model
class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String eventType;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final bool isOnline;
  final int maxParticipants;
  final List<String> participants;
  final List<String> tags;
  final String imageUrl;
  final String organizerId;
  final String organizerName;
  final Color eventColor;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.isOnline,
    required this.maxParticipants,
    required this.participants,
    required this.tags,
    required this.imageUrl,
    required this.organizerId,
    required this.organizerName,
    required this.eventColor,
  });

  bool get isFull => participants.length >= maxParticipants;

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    return CommunityEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventType: json['eventType'] ?? 'Workshop',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'] ?? 'Online',
      isOnline: json['isOnline'] ?? false,
      maxParticipants: json['maxParticipants'] ?? 50,
      participants: List<String>.from(json['participants'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      eventColor: _parseColor(json['eventColor']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventType': eventType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'isOnline': isOnline,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'tags': tags,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'eventColor': eventColor.value,
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String) {
      final hex = colorValue.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.blue;
  }

  CommunityEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    bool? isOnline,
    int? maxParticipants,
    List<String>? participants,
    List<String>? tags,
    String? imageUrl,
    String? organizerId,
    String? organizerName,
    Color? eventColor,
  }) {
    return CommunityEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      eventColor: eventColor ?? this.eventColor,
    );
  }
}

// Pet Progress Model
class PetProgress {
  final String id;
  final String petId;
  final String petName;
  final String petType;
  final String petBreed;
  final String ageDescription;
  final String overallStatus;
  final Color statusColor;
  final Map<String, dynamic> healthMetrics;
  final Map<String, String> trainingProgress;
  final Map<String, String> wellnessStats;
  final List<String> recentMilestones;
  final List<Achievement> petAchievements;
  final List<String> photos;
  final DateTime lastUpdated;

  PetProgress({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petType,
    required this.petBreed,
    required this.ageDescription,
    required this.overallStatus,
    required this.statusColor,
    required this.healthMetrics,
    required this.trainingProgress,
    required this.wellnessStats,
    required this.recentMilestones,
    required this.petAchievements,
    required this.photos,
    required this.lastUpdated,
  });

  factory PetProgress.fromJson(Map<String, dynamic> json) {
    return PetProgress(
      id: json['id'],
      petId: json['petId'],
      petName: json['petName'],
      petType: json['petType'],
      petBreed: json['petBreed'],
      ageDescription: json['ageDescription'],
      overallStatus: json['overallStatus'],
      statusColor: _parseColor(json['statusColor']),
      healthMetrics: Map<String, dynamic>.from(json['healthMetrics'] ?? {}),
      trainingProgress: Map<String, String>.from(json['trainingProgress'] ?? {}),
      wellnessStats: Map<String, String>.from(json['wellnessStats'] ?? {}),
      recentMilestones: List<String>.from(json['recentMilestones'] ?? []),
      petAchievements: (json['petAchievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      photos: List<String>.from(json['photos'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'petType': petType,
      'petBreed': petBreed,
      'ageDescription': ageDescription,
      'overallStatus': overallStatus,
      'statusColor': statusColor.value,
      'healthMetrics': healthMetrics,
      'trainingProgress': trainingProgress,
      'wellnessStats': wellnessStats,
      'recentMilestones': recentMilestones,
      'petAchievements': petAchievements.map((a) => a.toJson()).toList(),
      'photos': photos,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String) {
      final hex = colorValue.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.green;
  }

  PetProgress copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petType,
    String? petBreed,
    String? ageDescription,
    String? overallStatus,
    Color? statusColor,
    Map<String, dynamic>? healthMetrics,
    Map<String, String>? trainingProgress,
    Map<String, String>? wellnessStats,
    List<String>? recentMilestones,
    List<Achievement>? petAchievements,
    List<String>? photos,
    DateTime? lastUpdated,
  }) {
    return PetProgress(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petType: petType ?? this.petType,
      petBreed: petBreed ?? this.petBreed,
      ageDescription: ageDescription ?? this.ageDescription,
      overallStatus: overallStatus ?? this.overallStatus,
      statusColor: statusColor ?? this.statusColor,
      healthMetrics: healthMetrics ?? this.healthMetrics,
      trainingProgress: trainingProgress ?? this.trainingProgress,
      wellnessStats: wellnessStats ?? this.wellnessStats,
      recentMilestones: recentMilestones ?? this.recentMilestones,
      petAchievements: petAchievements ?? this.petAchievements,
      photos: photos ?? this.photos,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Social Share Settings Model
class SocialShareSettings {
  final String customMessage;
  final List<String> selectedHashtags;
  final bool shareToTwitter;
  final bool shareToFacebook;
  final bool shareToInstagram;
  final bool shareToTiktok;
  final bool shareToWhatsapp;
  final bool shareToTelegram;
  final bool shareViaEmail;
  final bool shareViaSMS;

  SocialShareSettings({
    required this.customMessage,
    required this.selectedHashtags,
    this.shareToTwitter = false,
    this.shareToFacebook = false,
    this.shareToInstagram = false,
    this.shareToTiktok = false,
    this.shareToWhatsapp = false,
    this.shareToTelegram = false,
    this.shareViaEmail = false,
    this.shareViaSMS = false,
  });

  factory SocialShareSettings.fromJson(Map<String, dynamic> json) {
    return SocialShareSettings(
      customMessage: json['customMessage'] ?? '',
      selectedHashtags: List<String>.from(json['selectedHashtags'] ?? []),
      shareToTwitter: json['shareToTwitter'] ?? false,
      shareToFacebook: json['shareToFacebook'] ?? false,
      shareToInstagram: json['shareToInstagram'] ?? false,
      shareToTiktok: json['shareToTiktok'] ?? false,
      shareToWhatsapp: json['shareToWhatsapp'] ?? false,
      shareToTelegram: json['shareToTelegram'] ?? false,
      shareViaEmail: json['shareViaEmail'] ?? false,
      shareViaSMS: json['shareViaSMS'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customMessage': customMessage,
      'selectedHashtags': selectedHashtags,
      'shareToTwitter': shareToTwitter,
      'shareToFacebook': shareToFacebook,
      'shareToInstagram': shareToInstagram,
      'shareToTiktok': shareToTiktok,
      'shareToWhatsapp': shareToWhatsapp,
      'shareToTelegram': shareToTelegram,
      'shareViaEmail': shareViaEmail,
      'shareViaSMS': shareViaSMS,
    };
  }

  SocialShareSettings copyWith({
    String? customMessage,
    List<String>? selectedHashtags,
    bool? shareToTwitter,
    bool? shareToFacebook,
    bool? shareToInstagram,
    bool? shareToTiktok,
    bool? shareToWhatsapp,
    bool? shareToTelegram,
    bool? shareViaEmail,
    bool? shareViaSMS,
  }) {
    return SocialShareSettings(
      customMessage: customMessage ?? this.customMessage,
      selectedHashtags: selectedHashtags ?? this.selectedHashtags,
      shareToTwitter: shareToTwitter ?? this.shareToTwitter,
      shareToFacebook: shareToFacebook ?? this.shareToFacebook,
      shareToInstagram: shareToInstagram ?? this.shareToInstagram,
      shareToTiktok: shareToTiktok ?? this.shareToTiktok,
      shareToWhatsapp: shareToWhatsapp ?? this.shareToWhatsapp,
      shareToTelegram: shareToTelegram ?? this.shareToTelegram,
      shareViaEmail: shareViaEmail ?? this.shareViaEmail,
      shareViaSMS: shareViaSMS ?? this.shareViaSMS,
    );
  }
}

// Social Post Model
class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final PostType type;
  final String title;
  final String content;
  final List<String> images;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final int shares;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;

  SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    required this.title,
    required this.content,
    required this.images,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.likedBy,
    required this.createdAt,
    this.updatedAt,
    required this.metadata,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${json['type']}',
        orElse: () => PostType.petPhoto,
      ),
      title: json['title'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'type': type.toString().split('.').last,
      'title': title,
      'content': content,
      'images': images,
      'hashtags': hashtags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  SocialPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    PostType? type,
    String? title,
    String? content,
    List<String>? images,
    List<String>? hashtags,
    int? likes,
    int? comments,
    int? shares,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}