import 'package:equatable/equatable.dart';

enum SessionType {
  tickle,
  cuddle,
  play,
  zen,
  mindfulness,
}

enum SessionStatus {
  inProgress,
  completed,
  paused,
}

class Session extends Equatable {
  final String id;
  final String petId;
  final String userId;
  final SessionType type;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double progress;
  final List<String> interactions;
  final Map<String, dynamic> metadata;
  final String? feedback;
  final int moodRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Session({
    required this.id,
    required this.petId,
    required this.userId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.progress,
    this.interactions = const [],
    this.metadata = const {},
    this.feedback,
    this.moodRating = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Session copyWith({
    String? id,
    String? petId,
    String? userId,
    SessionType? type,
    SessionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    double? progress,
    List<String>? interactions,
    Map<String, dynamic>? metadata,
    String? feedback,
    int? moodRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      interactions: interactions ?? this.interactions,
      metadata: metadata ?? this.metadata,
      feedback: feedback ?? this.feedback,
      moodRating: moodRating ?? this.moodRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration.inSeconds,
      'progress': progress,
      'interactions': interactions,
      'metadata': metadata,
      'feedback': feedback,
      'moodRating': moodRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      petId: json['petId'] as String,
      userId: json['userId'] as String,
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.tickle,
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.inProgress,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: Duration(seconds: json['duration'] as int),
      progress: (json['progress'] as num).toDouble(),
      interactions: List<String>.from(json['interactions'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      feedback: json['feedback'] as String?,
      moodRating: json['moodRating'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        userId,
        type,
        status,
        startTime,
        endTime,
        duration,
        progress,
        interactions,
        metadata,
        feedback,
        moodRating,
        createdAt,
        updatedAt,
      ];

  bool get isCompleted => status == SessionStatus.completed;
  bool get isActive => status == SessionStatus.inProgress;
  
  Duration get elapsedTime {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  double get progressPercentage => (progress * 100).clamp(0.0, 100.0);

  String get typeDisplayName {
    switch (type) {
      case SessionType.tickle:
        return 'Tickle Session';
      case SessionType.cuddle:
        return 'Cuddle Time';
      case SessionType.play:
        return 'Playtime';
      case SessionType.zen:
        return 'Zen Time';
      case SessionType.mindfulness:
        return 'Mindfulness';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.paused:
        return 'Paused';
    }
  }
}