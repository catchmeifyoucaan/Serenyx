import 'package:equatable/equatable.dart';

enum PetEmotion {
  happy,
  calm,
  excited,
  anxious,
  sad,
  neutral,
}

enum BehaviorType {
  eating,
  sleeping,
  playing,
  socializing,
  exploring,
  resting,
  training,
  grooming,
}

enum PredictionType {
  health,
  behavior,
  mood,
  activity,
  social,
}

class EmotionAnalysis extends Equatable {
  final PetEmotion emotion;
  final double confidence;
  final DateTime timestamp;
  final String imageUrl;
  final String context;

  const EmotionAnalysis({
    required this.emotion,
    required this.confidence,
    required this.timestamp,
    required this.imageUrl,
    required this.context,
  });

  @override
  List<Object?> get props => [emotion, confidence, timestamp, imageUrl, context];

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion.name,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'context': context,
    };
  }

  factory EmotionAnalysis.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysis(
      emotion: PetEmotion.values.firstWhere(
        (e) => e.name == json['emotion'],
        orElse: () => PetEmotion.neutral,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'] as String,
      context: json['context'] as String,
    );
  }
}

class BehaviorPrediction extends Equatable {
  final String id;
  final BehaviorType type;
  final String description;
  final double probability;
  final DateTime predictedTime;
  final List<String> factors;
  final String recommendation;

  const BehaviorPrediction({
    required this.id,
    required this.type,
    required this.description,
    required this.probability,
    required this.predictedTime,
    required this.factors,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        probability,
        predictedTime,
        factors,
        recommendation,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'probability': probability,
      'predictedTime': predictedTime.toIso8601String(),
      'factors': factors,
      'recommendation': recommendation,
    };
  }

  factory BehaviorPrediction.fromJson(Map<String, dynamic> json) {
    return BehaviorPrediction(
      id: json['id'] as String,
      type: BehaviorType.values.firstWhere(
        (b) => b.name == json['type'],
        orElse: () => BehaviorType.resting,
      ),
      description: json['description'] as String,
      probability: (json['probability'] as num).toDouble(),
      predictedTime: DateTime.parse(json['predictedTime']),
      factors: List<String>.from(json['factors']),
      recommendation: json['recommendation'] as String,
    );
  }
}

class PersonalizedContent extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String contentUrl;
  final double relevanceScore;
  final List<String> tags;
  final DateTime createdAt;

  const PersonalizedContent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.contentUrl,
    required this.relevanceScore,
    required this.tags,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        contentUrl,
        relevanceScore,
        tags,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'contentUrl': contentUrl,
      'relevanceScore': relevanceScore,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PersonalizedContent.fromJson(Map<String, dynamic> json) {
    return PersonalizedContent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      contentUrl: json['contentUrl'] as String,
      relevanceScore: (json['relevanceScore'] as num).toDouble(),
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SmartSchedule extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final String category;
  final double priority;
  final bool isRecurring;
  final String recurrencePattern;
  final List<String> tags;

  const SmartSchedule({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.category,
    required this.priority,
    required this.isRecurring,
    required this.recurrencePattern,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        scheduledTime,
        category,
        priority,
        isRecurring,
        recurrencePattern,
        tags,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'category': category,
      'priority': priority,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'tags': tags,
    };
  }

  factory SmartSchedule.fromJson(Map<String, dynamic> json) {
    return SmartSchedule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime']),
      category: json['category'] as String,
      priority: (json['priority'] as num).toDouble(),
      isRecurring: json['isRecurring'] as bool,
      recurrencePattern: json['recurrencePattern'] as String,
      tags: List<String>.from(json['tags']),
    );
  }
}

class AIInsight extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final double confidence;
  final DateTime timestamp;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.confidence,
    required this.timestamp,
    required this.recommendations,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        confidence,
        timestamp,
        recommendations,
        metadata,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'recommendations': recommendations,
      'metadata': metadata,
    };
  }

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      recommendations: List<String>.from(json['recommendations']),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
}
