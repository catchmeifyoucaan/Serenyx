import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final List<String> petIds;
  final Map<String, dynamic> preferences;
  final int totalSessions;
  final int totalMoodRating;
  final bool isOnboarded;
  final String? notificationToken;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.petIds = const [],
    this.preferences = const {},
    this.totalSessions = 0,
    this.totalMoodRating = 0,
    this.isOnboarded = false,
    this.notificationToken,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    List<String>? petIds,
    Map<String, dynamic>? preferences,
    int? totalSessions,
    int? totalMoodRating,
    bool? isOnboarded,
    String? notificationToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      petIds: petIds ?? this.petIds,
      preferences: preferences ?? this.preferences,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMoodRating: totalMoodRating ?? this.totalMoodRating,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      notificationToken: notificationToken ?? this.notificationToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'petIds': petIds,
      'preferences': preferences,
      'totalSessions': totalSessions,
      'totalMoodRating': totalMoodRating,
      'isOnboarded': isOnboarded,
      'notificationToken': notificationToken,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      petIds: List<String>.from(json['petIds'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalMoodRating: json['totalMoodRating'] as int? ?? 0,
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      notificationToken: json['notificationToken'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        updatedAt,
        lastLoginAt,
        petIds,
        preferences,
        totalSessions,
        totalMoodRating,
        isOnboarded,
        notificationToken,
      ];

  double get averageMoodRating {
    if (totalSessions == 0) return 0.0;
    return totalMoodRating / totalSessions;
  }

  bool get hasPets => petIds.isNotEmpty;
  bool get isNewUser => totalSessions < 5;

  String get displayNameOrEmail => displayName ?? email.split('@').first;

  Map<String, dynamic> get notificationPreferences {
    return preferences['notifications'] ?? {
      'dailyReminders': true,
      'sessionComplete': true,
      'moodCheck': true,
      'petHealth': true,
    };
  }

  Map<String, dynamic> get themePreferences {
    return preferences['theme'] ?? {
      'isDarkMode': false,
      'accentColor': 'leafGreen',
      'animationSpeed': 'normal',
    };
  }
}