import 'package:flutter/material.dart';

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

enum PostType {
  petPhoto,
  healthMilestone,
  trainingProgress,
  mindfulnessSession,
  communityEvent,
  achievement,
  wellnessTip,
  aiInsight,
}

class SocialPost {
  final String id;
  final String userId;
  final String petId;
  final PostType type;
  final String content;
  final List<String> imageUrls;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final int likes;
  final int shares;
  final int comments;
  final List<String> hashtags;
  final bool isPublic;
  final SocialShareSettings shareSettings;

  SocialPost({
    required this.id,
    required this.userId,
    required this.petId,
    required this.type,
    required this.content,
    required this.imageUrls,
    required this.metadata,
    required this.createdAt,
    this.likes = 0,
    this.shares = 0,
    this.comments = 0,
    required this.hashtags,
    this.isPublic = true,
    required this.shareSettings,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      userId: json['userId'],
      petId: json['petId'],
      type: PostType.values.firstWhere((e) => e.toString() == json['type']),
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls']),
      metadata: Map<String, dynamic>.from(json['metadata']),
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      comments: json['comments'] ?? 0,
      hashtags: List<String>.from(json['hashtags']),
      isPublic: json['isPublic'] ?? true,
      shareSettings: SocialShareSettings.fromJson(json['shareSettings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'petId': petId,
      'type': type.toString(),
      'content': content,
      'imageUrls': imageUrls,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'shares': shares,
      'comments': comments,
      'hashtags': hashtags,
      'isPublic': isPublic,
      'shareSettings': shareSettings.toJson(),
    };
  }

  SocialPost copyWith({
    String? id,
    String? userId,
    String? petId,
    PostType? type,
    String? content,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    int? likes,
    int? shares,
    int? comments,
    List<String>? hashtags,
    bool? isPublic,
    SocialShareSettings? shareSettings,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
      hashtags: hashtags ?? this.hashtags,
      isPublic: isPublic ?? this.isPublic,
      shareSettings: shareSettings ?? this.shareSettings,
    );
  }
}

class SocialShareSettings {
  final bool shareToTwitter;
  final bool shareToFacebook;
  final bool shareToInstagram;
  final bool shareToTiktok;
  final bool shareToWhatsapp;
  final bool shareToTelegram;
  final bool shareViaEmail;
  final bool shareViaSMS;
  final String customMessage;
  final List<String> selectedHashtags;

  SocialShareSettings({
    this.shareToTwitter = false,
    this.shareToFacebook = false,
    this.shareToInstagram = false,
    this.shareToTiktok = false,
    this.shareToWhatsapp = false,
    this.shareToTelegram = false,
    this.shareViaEmail = false,
    this.shareViaSMS = false,
    this.customMessage = '',
    this.selectedHashtags = const [],
  });

  factory SocialShareSettings.fromJson(Map<String, dynamic> json) {
    return SocialShareSettings(
      shareToTwitter: json['shareToTwitter'] ?? false,
      shareToFacebook: json['shareToFacebook'] ?? false,
      shareToInstagram: json['shareToInstagram'] ?? false,
      shareToTiktok: json['shareToTiktok'] ?? false,
      shareToWhatsapp: json['shareToWhatsapp'] ?? false,
      shareToTelegram: json['shareToTelegram'] ?? false,
      shareViaEmail: json['shareViaEmail'] ?? false,
      shareViaSMS: json['shareViaSMS'] ?? false,
      customMessage: json['customMessage'] ?? '',
      selectedHashtags: List<String>.from(json['selectedHashtags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareToTwitter': shareToTwitter,
      'shareToFacebook': shareToFacebook,
      'shareToInstagram': shareToInstagram,
      'shareToTiktok': shareToTiktok,
      'shareToWhatsapp': shareToWhatsapp,
      'shareToTelegram': shareToTelegram,
      'shareViaEmail': shareViaEmail,
      'shareViaSMS': shareViaSMS,
      'customMessage': customMessage,
      'selectedHashtags': selectedHashtags,
    };
  }
}

class UserPoints {
  final String userId;
  final int totalPoints;
  final int level;
  final int experiencePoints;
  final int experienceToNextLevel;
  final List<Achievement> achievements;
  final Map<String, int> categoryPoints;
  final DateTime lastActivity;
  final int streakDays;
  final int maxStreakDays;

  UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.level,
    required this.experiencePoints,
    required this.experienceToNextLevel,
    required this.achievements,
    required this.categoryPoints,
    required this.lastActivity,
    required this.streakDays,
    required this.maxStreakDays,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'],
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
      experienceToNextLevel: json['experienceToNextLevel'] ?? 100,
      achievements: (json['achievements'] as List?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      categoryPoints: Map<String, int>.from(json['categoryPoints'] ?? {}),
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
      streakDays: json['streakDays'] ?? 0,
      maxStreakDays: json['maxStreakDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'level': level,
      'experiencePoints': experiencePoints,
      'experienceToNextLevel': experienceToNextLevel,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'categoryPoints': categoryPoints,
      'lastActivity': lastActivity.toIso8601String(),
      'streakDays': streakDays,
      'maxStreakDays': maxStreakDays,
    };
  }

  double get progressToNextLevel => experiencePoints / experienceToNextLevel;

  String get levelTitle {
    if (level >= 50) return 'Legendary Pet Parent';
    if (level >= 40) return 'Master Pet Guardian';
    if (level >= 30) return 'Expert Pet Caretaker';
    if (level >= 20) return 'Advanced Pet Lover';
    if (level >= 10) return 'Experienced Pet Owner';
    if (level >= 5) return 'Growing Pet Parent';
    return 'New Pet Parent';
  }

  Color get levelColor {
    if (level >= 50) return Colors.purple;
    if (level >= 40) return Colors.red;
    if (level >= 30) return Colors.orange;
    if (level >= 20) return Colors.yellow;
    if (level >= 10) return Colors.green;
    if (level >= 5) return Colors.blue;
    return Colors.grey;
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int pointsReward;
  final String iconPath;
  final DateTime unlockedAt;
  final bool isUnlocked;
  final Map<String, dynamic> criteria;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.iconPath,
    required this.unlockedAt,
    required this.isUnlocked,
    required this.criteria,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AchievementType.values.firstWhere((e) => e.toString() == json['type']),
      pointsReward: json['pointsReward'] ?? 0,
      iconPath: json['iconPath'],
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : DateTime.now(),
      isUnlocked: json['isUnlocked'] ?? false,
      criteria: Map<String, dynamic>.from(json['criteria'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'pointsReward': pointsReward,
      'iconPath': iconPath,
      'unlockedAt': unlockedAt.toIso8601String(),
      'isUnlocked': isUnlocked,
      'criteria': criteria,
    };
  }
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int totalPoints;
  final int level;
  final int rank;
  final String levelTitle;
  final int streakDays;
  final DateTime lastActivity;
  final List<String> recentAchievements;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.totalPoints,
    required this.level,
    required this.rank,
    required this.levelTitle,
    required this.streakDays,
    required this.lastActivity,
    required this.recentAchievements,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      rank: json['rank'] ?? 0,
      levelTitle: json['levelTitle'] ?? 'New Pet Parent',
      streakDays: json['streakDays'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
      recentAchievements: List<String>.from(json['recentAchievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'totalPoints': totalPoints,
      'level': level,
      'rank': rank,
      'levelTitle': levelTitle,
      'streakDays': streakDays,
      'lastActivity': lastActivity.toIso8601String(),
      'recentAchievements': recentAchievements,
    );
  }
}

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String organizerId;
  final String organizerName;
  final List<String> participants;
  final int maxParticipants;
  final String eventType;
  final List<String> tags;
  final String imageUrl;
  final bool isOnline;
  final String? meetingLink;
  final Map<String, dynamic> metadata;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.organizerId,
    required this.organizerName,
    required this.participants,
    required this.maxParticipants,
    required this.eventType,
    required this.tags,
    required this.imageUrl,
    required this.isOnline,
    this.meetingLink,
    required this.metadata,
  });

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    return CommunityEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      participants: List<String>.from(json['participants']),
      maxParticipants: json['maxParticipants'] ?? 100,
      eventType: json['eventType'],
      tags: List<String>.from(json['tags']),
      imageUrl: json['imageUrl'],
      isOnline: json['isOnline'] ?? false,
      meetingLink: json['meetingLink'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'participants': participants,
      'maxParticipants': maxParticipants,
      'eventType': eventType,
      'tags': tags,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'meetingLink': meetingLink,
      'metadata': metadata,
    };
  }

  bool get isFull => participants.length >= maxParticipants;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
}

class PetProgress {
  final String petId;
  final String petName;
  final String petType;
  final String petBreed;
  final int age;
  final List<String> photos;
  final Map<String, dynamic> healthMetrics;
  final Map<String, dynamic> trainingProgress;
  final Map<String, dynamic> wellnessStats;
  final List<Achievement> petAchievements;
  final DateTime lastUpdated;
  final String overallStatus;
  final List<String> recentMilestones;

  PetProgress({
    required this.petId,
    required this.petName,
    required this.petType,
    required this.petBreed,
    required this.age,
    required this.photos,
    required this.healthMetrics,
    required this.trainingProgress,
    required this.wellnessStats,
    required this.petAchievements,
    required this.lastUpdated,
    required this.overallStatus,
    required this.recentMilestones,
  });

  factory PetProgress.fromJson(Map<String, dynamic> json) {
    return PetProgress(
      petId: json['petId'],
      petName: json['petName'],
      petType: json['petType'],
      petBreed: json['petBreed'],
      age: json['age'] ?? 0,
      photos: List<String>.from(json['photos'] ?? []),
      healthMetrics: Map<String, dynamic>.from(json['healthMetrics'] ?? {}),
      trainingProgress: Map<String, dynamic>.from(json['trainingProgress'] ?? {}),
      wellnessStats: Map<String, dynamic>.from(json['wellnessStats'] ?? {}),
      petAchievements: (json['petAchievements'] as List?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      overallStatus: json['overallStatus'] ?? 'Good',
      recentMilestones: List<String>.from(json['recentMilestones'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'petName': petName,
      'petType': petType,
      'petBreed': petBreed,
      'age': age,
      'photos': photos,
      'healthMetrics': healthMetrics,
      'trainingProgress': trainingProgress,
      'wellnessStats': wellnessStats,
      'petAchievements': petAchievements.map((a) => a.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'overallStatus': overallStatus,
      'recentMilestones': recentMilestones,
    };
  }

  String get ageDescription {
    if (age < 12) return '$age months old';
    if (age < 24) return '${(age / 12).floor()} year old';
    return '${(age / 12).floor()} years old';
  }

  Color get statusColor {
    switch (overallStatus.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class SocialShareContent {
  final String title;
  final String message;
  final List<String> imageUrls;
  final String? url;
  final List<String> hashtags;
  final Map<SocialPlatform, String> platformSpecificMessages;

  SocialShareContent({
    required this.title,
    required this.message,
    required this.imageUrls,
    this.url,
    required this.hashtags,
    this.platformSpecificMessages = const {},
  });

  String getMessageForPlatform(SocialPlatform platform) {
    return platformSpecificMessages[platform] ?? message;
  }

  String getFullMessageForPlatform(SocialPlatform platform) {
    final baseMessage = getMessageForPlatform(platform);
    final hashtagString = hashtags.isNotEmpty ? ' ${hashtags.join(' ')}' : '';
    final urlString = url != null ? '\n\n$url' : '';
    return '$baseMessage$hashtagString$urlString';
  }
}