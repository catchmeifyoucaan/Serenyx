import 'package:flutter/material.dart';

// ============================================================================
// VETERINARY AI MODELS
// ============================================================================

class VeterinaryAIResponse {
  final String id;
  final String question;
  final String answer;
  final double confidence;
  final List<String> recommendations;
  final List<String> warnings;
  final String language;
  final DateTime timestamp;
  final String petId;
  final String userId;

  VeterinaryAIResponse({
    required this.id,
    required this.question,
    required this.answer,
    required this.confidence,
    required this.recommendations,
    required this.warnings,
    required this.language,
    required this.timestamp,
    required this.petId,
    required this.userId,
  });

  factory VeterinaryAIResponse.fromJson(Map<String, dynamic> json) {
    return VeterinaryAIResponse(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      language: json['language'] ?? 'en',
      timestamp: DateTime.parse(json['timestamp']),
      petId: json['petId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'confidence': confidence,
      'recommendations': recommendations,
      'warnings': warnings,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
      'petId': petId,
      'userId': userId,
    };
  }

  VeterinaryAIResponse copyWith({
    String? id,
    String? question,
    String? answer,
    double? confidence,
    List<String>? recommendations,
    List<String>? warnings,
    String? language,
    DateTime? timestamp,
    String? petId,
    String? userId,
  }) {
    return VeterinaryAIResponse(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      confidence: confidence ?? this.confidence,
      recommendations: recommendations ?? this.recommendations,
      warnings: warnings ?? this.warnings,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
    );
  }
}

// ============================================================================
// BEHAVIORAL ANALYSIS MODELS
// ============================================================================

class BehavioralAnalysis {
  final String id;
  final String petId;
  final DateTime timestamp;
  final PetMoodAnalysis moodAnalysis;
  final BehaviorPatternAnalysis behaviorPatterns;
  final StressAnalysis stressAnalysis;
  final SocialInteractionAnalysis socialAnalysis;
  final String overallAssessment;
  final List<String> recommendations;
  final String language;

  BehavioralAnalysis({
    required this.id,
    required this.petId,
    required this.timestamp,
    required this.moodAnalysis,
    required this.behaviorPatterns,
    required this.stressAnalysis,
    required this.socialAnalysis,
    required this.overallAssessment,
    required this.recommendations,
    required this.language,
  });

  factory BehavioralAnalysis.fromJson(Map<String, dynamic> json) {
    return BehavioralAnalysis(
      id: json['id'],
      petId: json['petId'],
      timestamp: DateTime.parse(json['timestamp']),
      moodAnalysis: PetMoodAnalysis.fromJson(json['moodAnalysis']),
      behaviorPatterns: BehaviorPatternAnalysis.fromJson(json['behaviorPatterns']),
      stressAnalysis: StressAnalysis.fromJson(json['stressAnalysis']),
      socialAnalysis: SocialInteractionAnalysis.fromJson(json['socialAnalysis']),
      overallAssessment: json['overallAssessment'],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'timestamp': timestamp.toIso8601String(),
      'moodAnalysis': moodAnalysis.toJson(),
      'behaviorPatterns': behaviorPatterns.toJson(),
      'stressAnalysis': stressAnalysis.toJson(),
      'socialAnalysis': socialAnalysis.toJson(),
      'overallAssessment': overallAssessment,
      'recommendations': recommendations,
      'language': language,
    };
  }
}

class PetMoodAnalysis {
  final String id;
  final String dominantMood;
  final double confidence;
  final List<String> moodFactors;
  final List<String> recommendations;
  final String language;

  PetMoodAnalysis({
    required this.id,
    required this.dominantMood,
    required this.confidence,
    required this.moodFactors,
    required this.recommendations,
    required this.language,
  });

  factory PetMoodAnalysis.fromJson(Map<String, dynamic> json) {
    return PetMoodAnalysis(
      id: json['id'],
      dominantMood: json['dominantMood'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      moodFactors: List<String>.from(json['moodFactors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dominantMood': dominantMood,
      'confidence': confidence,
      'moodFactors': moodFactors,
      'recommendations': recommendations,
      'language': language,
    };
  }

  factory PetMoodAnalysis.empty() {
    return PetMoodAnalysis(
      id: '',
      dominantMood: 'Unknown',
      confidence: 0.0,
      moodFactors: [],
      recommendations: [],
      language: 'en',
    );
  }
}

class BehaviorPatternAnalysis {
  final String id;
  final List<BehaviorPattern> patterns;
  final List<BehaviorTrend> trends;
  final List<BehaviorAnomaly> anomalies;
  final List<String> recommendations;
  final String language;

  BehaviorPatternAnalysis({
    required this.id,
    required this.patterns,
    required this.trends,
    required this.anomalies,
    required this.recommendations,
    required this.language,
  });

  factory BehaviorPatternAnalysis.fromJson(Map<String, dynamic> json) {
    return BehaviorPatternAnalysis(
      id: json['id'],
      patterns: (json['patterns'] as List<dynamic>?)
              ?.map((p) => BehaviorPattern.fromJson(p))
              .toList() ??
          [],
      trends: (json['trends'] as List<dynamic>?)
              ?.map((t) => BehaviorTrend.fromJson(t))
              .toList() ??
          [],
      anomalies: (json['anomalies'] as List<dynamic>?)
              ?.map((a) => BehaviorAnomaly.fromJson(a))
              .toList() ??
          [],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patterns': patterns.map((p) => p.toJson()).toList(),
      'trends': trends.map((t) => t.toJson()).toList(),
      'anomalies': anomalies.map((a) => a.toJson()).toList(),
      'recommendations': recommendations,
      'language': language,
    };
  }

  factory BehaviorPatternAnalysis.empty() {
    return BehaviorPatternAnalysis(
      id: '',
      patterns: [],
      trends: [],
      anomalies: [],
      recommendations: [],
      language: 'en',
    );
  }
}

class BehaviorPattern {
  final String id;
  final String name;
  final String description;
  final String frequency;
  final double confidence;

  BehaviorPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.confidence,
  });

  factory BehaviorPattern.fromJson(Map<String, dynamic> json) {
    return BehaviorPattern(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'confidence': confidence,
    };
  }
}

class BehaviorTrend {
  final String id;
  final String name;
  final String description;
  final String trend;
  final double confidence;

  BehaviorTrend({
    required this.id,
    required this.name,
    required this.description,
    required this.trend,
    required this.confidence,
  });

  factory BehaviorTrend.fromJson(Map<String, dynamic> json) {
    return BehaviorTrend(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      trend: json['trend'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'trend': trend,
      'confidence': confidence,
    };
  }
}

class BehaviorAnomaly {
  final String id;
  final String name;
  final String description;
  final String severity;
  final double confidence;

  BehaviorAnomaly({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    required this.confidence,
  });

  factory BehaviorAnomaly.fromJson(Map<String, dynamic> json) {
    return BehaviorAnomaly(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      severity: json['severity'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'severity': severity,
      'confidence': confidence,
    };
  }
}

class StressAnalysis {
  final String id;
  final double stressLevel;
  final List<String> stressFactors;
  final List<String> copingMechanisms;
  final String language;

  StressAnalysis({
    required this.id,
    required this.stressLevel,
    required this.stressFactors,
    required this.copingMechanisms,
    required this.language,
  });

  factory StressAnalysis.fromJson(Map<String, dynamic> json) {
    return StressAnalysis(
      id: json['id'],
      stressLevel: json['stressLevel']?.toDouble() ?? 0.0,
      stressFactors: List<String>.from(json['stressFactors'] ?? []),
      copingMechanisms: List<String>.from(json['copingMechanisms'] ?? []),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stressLevel': stressLevel,
      'stressFactors': stressFactors,
      'copingMechanisms': copingMechanisms,
      'language': language,
    };
  }

  factory StressAnalysis.empty() {
    return StressAnalysis(
      id: '',
      stressLevel: 0.0,
      stressFactors: [],
      copingMechanisms: [],
      language: 'en',
    );
  }
}

class SocialInteractionAnalysis {
  final String id;
  final List<InteractionPattern> interactionPatterns;
  final double socialSkills;
  final List<String> recommendations;
  final String language;

  SocialInteractionAnalysis({
    required this.id,
    required this.interactionPatterns,
    required this.socialSkills,
    required this.recommendations,
    required this.language,
  });

  factory SocialInteractionAnalysis.fromJson(Map<String, dynamic> json) {
    return SocialInteractionAnalysis(
      id: json['id'],
      interactionPatterns: (json['interactionPatterns'] as List<dynamic>?)
              ?.map((p) => InteractionPattern.fromJson(p))
              .toList() ??
          [],
      socialSkills: json['socialSkills']?.toDouble() ?? 0.0,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interactionPatterns': interactionPatterns.map((p) => p.toJson()).toList(),
      'socialSkills': socialSkills,
      'recommendations': recommendations,
      'language': language,
    };
  }

  factory SocialInteractionAnalysis.empty() {
    return SocialInteractionAnalysis(
      id: '',
      interactionPatterns: [],
      socialSkills: 0.0,
      recommendations: [],
      language: 'en',
    );
  }
}

class InteractionPattern {
  final String id;
  final String name;
  final String description;
  final String frequency;
  final double confidence;

  InteractionPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.confidence,
  });

  factory InteractionPattern.fromJson(Map<String, dynamic> json) {
    return InteractionPattern(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'confidence': confidence,
    };
  }
}

// ============================================================================
// TRAINING PROGRESS MODELS
// ============================================================================

class TrainingProgressAnalysis {
  final String id;
  final String petId;
  final DateTime timestamp;
  final TrainingPatternAnalysis patternAnalysis;
  final List<String> recommendations;
  final Map<String, double> progressMetrics;
  final List<String> nextMilestones;
  final String language;

  TrainingProgressAnalysis({
    required this.id,
    required this.petId,
    required this.timestamp,
    required this.patternAnalysis,
    required this.recommendations,
    required this.progressMetrics,
    required this.nextMilestones,
    required this.language,
  });

  factory TrainingProgressAnalysis.fromJson(Map<String, dynamic> json) {
    return TrainingProgressAnalysis(
      id: json['id'],
      petId: json['petId'],
      timestamp: DateTime.parse(json['timestamp']),
      patternAnalysis: TrainingPatternAnalysis.fromJson(json['patternAnalysis']),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      progressMetrics: Map<String, double>.from(json['progressMetrics'] ?? {}),
      nextMilestones: List<String>.from(json['nextMilestones'] ?? []),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'timestamp': timestamp.toIso8601String(),
      'patternAnalysis': patternAnalysis.toJson(),
      'recommendations': recommendations,
      'progressMetrics': progressMetrics,
      'nextMilestones': nextMilestones,
      'language': language,
    };
  }
}

class TrainingPatternAnalysis {
  final String id;
  final List<TrainingPattern> patterns;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;

  TrainingPatternAnalysis({
    required this.id,
    required this.patterns,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
  });

  factory TrainingPatternAnalysis.fromJson(Map<String, dynamic> json) {
    return TrainingPatternAnalysis(
      id: json['id'],
      patterns: (json['patterns'] as List<dynamic>?)
              ?.map((p) => TrainingPattern.fromJson(p))
              .toList() ??
          [],
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patterns': patterns.map((p) => p.toJson()).toList(),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
    };
  }

  factory TrainingPatternAnalysis.empty() {
    return TrainingPatternAnalysis(
      id: '',
      patterns: [],
      strengths: [],
      weaknesses: [],
      recommendations: [],
    );
  }
}

class TrainingPattern {
  final String id;
  final String name;
  final String description;
  final double effectiveness;

  TrainingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.effectiveness,
  });

  factory TrainingPattern.fromJson(Map<String, dynamic> json) {
    return TrainingPattern(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      effectiveness: json['effectiveness']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'effectiveness': effectiveness,
    };
  }
}

// ============================================================================
// BEHAVIORAL DATA MODELS
// ============================================================================

class BehavioralData {
  final String id;
  final String petId;
  final String type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final double confidence;

  BehavioralData({
    required this.id,
    required this.petId,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.metadata,
    required this.confidence,
  });

  factory BehavioralData.fromJson(Map<String, dynamic> json) {
    return BehavioralData(
      id: json['id'],
      petId: json['petId'],
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'confidence': confidence,
    );
  }
}

class TrainingSession {
  final String id;
  final String petId;
  final String type;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final List<String> goals;
  final Map<String, dynamic> results;
  final double successRate;

  TrainingSession({
    required this.id,
    required this.petId,
    required this.type,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.goals,
    required this.results,
    required this.successRate,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      petId: json['petId'],
      type: json['type'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'],
      goals: List<String>.from(json['goals'] ?? []),
      results: Map<String, dynamic>.from(json['results'] ?? {}),
      successRate: json['successRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'goals': goals,
      'results': results,
      'successRate': successRate,
    );
  }
}
