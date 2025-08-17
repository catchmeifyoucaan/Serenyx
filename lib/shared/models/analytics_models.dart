import 'package:flutter/material.dart';

// ============================================================================
// PERFORMANCE METRICS
// ============================================================================

class PerformanceMetric {
  final String id;
  final String userId;
  final String metricName;
  final double value;
  final String unit;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.id,
    required this.userId,
    required this.metricName,
    required this.value,
    required this.unit,
    required this.category,
    required this.timestamp,
    required this.metadata,
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      id: json['id'],
      userId: json['userId'],
      metricName: json['metricName'],
      value: json['value']?.toDouble() ?? 0.0,
      unit: json['unit'],
      category: json['category'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'metricName': metricName,
      'value': value,
      'unit': unit,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  PerformanceMetric copyWith({
    String? id,
    String? userId,
    String? metricName,
    double? value,
    String? unit,
    String? category,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metricName: metricName ?? this.metricName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ============================================================================
// USER EVENTS
// ============================================================================

class UserEvent {
  final String id;
  final String userId;
  final String eventName;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final String sessionId;

  UserEvent({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.eventType,
    required this.timestamp,
    required this.properties,
    required this.sessionId,
  });

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      id: json['id'],
      userId: json['userId'],
      eventName: json['eventName'],
      eventType: json['eventType'],
      timestamp: DateTime.parse(json['timestamp']),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      sessionId: json['sessionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventName': eventName,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
      'sessionId': sessionId,
    );
  }

  UserEvent copyWith({
    String? id,
    String? userId,
    String? eventName,
    String? eventType,
    DateTime? timestamp,
    Map<String, dynamic>? properties,
    String? sessionId,
  }) {
    return UserEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventName: eventName ?? this.eventName,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      properties: properties ?? this.properties,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

// ============================================================================
// ERROR REPORTS
// ============================================================================

class ErrorReport {
  final String id;
  final String userId;
  final String errorType;
  final String errorMessage;
  final String stackTrace;
  final DateTime timestamp;
  final String? screenName;
  final Map<String, dynamic> context;
  final ErrorSeverity severity;

  ErrorReport({
    required this.id,
    required this.userId,
    required this.errorType,
    required this.errorMessage,
    required this.stackTrace,
    required this.timestamp,
    this.screenName,
    required this.context,
    required this.severity,
  });

  factory ErrorReport.fromJson(Map<String, dynamic> json) {
    return ErrorReport(
      id: json['id'],
      userId: json['userId'],
      errorType: json['errorType'],
      errorMessage: json['errorMessage'],
      stackTrace: json['stackTrace'],
      timestamp: DateTime.parse(json['timestamp']),
      screenName: json['screenName'],
      context: Map<String, dynamic>.from(json['context'] ?? {}),
      severity: ErrorSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => ErrorSeverity.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'screenName': screenName,
      'context': context,
      'severity': severity.name,
    };
  }

  ErrorReport copyWith({
    String? id,
    String? userId,
    String? errorType,
    String? errorMessage,
    String? stackTrace,
    DateTime? timestamp,
    String? screenName,
    Map<String, dynamic>? context,
    ErrorSeverity? severity,
  }) {
    return ErrorReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      errorType: errorType ?? this.errorType,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      screenName: screenName ?? this.screenName,
      context: context ?? this.context,
      severity: severity ?? this.severity,
    );
  }
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

// ============================================================================
// A/B TESTING
// ============================================================================

class ABTest {
  final String id;
  final String name;
  final String description;
  final List<String> variants;
  final String metric;
  final int sampleSize;
  final Duration duration;
  final DateTime startDate;
  final DateTime endDate;
  final ABTestStatus status;
  final Map<String, dynamic> targeting;
  final Map<String, List<double>> results;

  ABTest({
    required this.id,
    required this.name,
    required this.description,
    required this.variants,
    required this.metric,
    required this.sampleSize,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.targeting,
    required this.results,
  });

  factory ABTest.fromJson(Map<String, dynamic> json) {
    return ABTest(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      variants: List<String>.from(json['variants'] ?? []),
      metric: json['metric'],
      sampleSize: json['sampleSize'] ?? 0,
      duration: Duration(days: json['durationDays'] ?? 0),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: ABTestStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ABTestStatus.draft,
      ),
      targeting: Map<String, dynamic>.from(json['targeting'] ?? {}),
      results: (json['results'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<double>.from(value ?? [])),
      ) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'variants': variants,
      'metric': metric,
      'sampleSize': sampleSize,
      'durationDays': duration.inDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'targeting': targeting,
      'results': results,
    };
  }

  ABTest copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? variants,
    String? metric,
    int? sampleSize,
    Duration? duration,
    DateTime? startDate,
    DateTime? endDate,
    ABTestStatus? status,
    Map<String, dynamic>? targeting,
    Map<String, List<double>>? results,
  }) {
    return ABTest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      variants: variants ?? this.variants,
      metric: metric ?? this.metric,
      sampleSize: sampleSize ?? this.sampleSize,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      targeting: targeting ?? this.targeting,
      results: results ?? this.results,
    );
  }

  bool get isActive => status == ABTestStatus.active && 
                      DateTime.now().isAfter(startDate) && 
                      DateTime.now().isBefore(endDate);
  
  bool get isCompleted => DateTime.now().isAfter(endDate);
  
  Duration get remainingTime => endDate.difference(DateTime.now());
  
  int get totalParticipants {
    int total = 0;
    for (final variantResults in results.values) {
      total += variantResults.length;
    }
    return total;
  }
}

enum ABTestStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

class ABTestResult {
  final String id;
  final String testId;
  final String userId;
  final String variant;
  final String metric;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ABTestResult({
    required this.id,
    required this.testId,
    required this.userId,
    required this.variant,
    required this.metric,
    required this.value,
    required this.timestamp,
    required this.metadata,
  });

  factory ABTestResult.fromJson(Map<String, dynamic> json) {
    return ABTestResult(
      id: json['id'],
      testId: json['testId'],
      userId: json['userId'],
      variant: json['variant'],
      metric: json['metric'],
      value: json['value']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'variant': variant,
      'metric': metric,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    );
  }
}

class ABTestAnalysis {
  final String testId;
  final String status;
  final Map<String, VariantStats> results;
  final String? winner;
  final double confidence;
  final List<String> recommendations;

  ABTestAnalysis({
    required this.testId,
    required this.status,
    required this.results,
    this.winner,
    required this.confidence,
    required this.recommendations,
  });

  factory ABTestAnalysis.fromJson(Map<String, dynamic> json) {
    return ABTestAnalysis(
      testId: json['testId'],
      status: json['status'],
      results: (json['results'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, VariantStats.fromJson(value)),
      ) ?? {},
      winner: json['winner'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'status': status,
      'results': results.map((key, value) => MapEntry(key, value.toJson())),
      'winner': winner,
      'confidence': confidence,
      'recommendations': recommendations,
    };
  }
}

class VariantStats {
  final String variant;
  final int count;
  final double average;
  final double standardDeviation;
  final double confidenceInterval;

  VariantStats({
    required this.variant,
    required this.count,
    required this.average,
    required this.standardDeviation,
    required this.confidenceInterval,
  });

  factory VariantStats.fromJson(Map<String, dynamic> json) {
    return VariantStats(
      variant: json['variant'],
      count: json['count'] ?? 0,
      average: json['average']?.toDouble() ?? 0.0,
      standardDeviation: json['standardDeviation']?.toDouble() ?? 0.0,
      confidenceInterval: json['confidenceInterval']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant': variant,
      'count': count,
      'average': average,
      'standardDeviation': standardDeviation,
      'confidenceInterval': confidenceInterval,
    };
  }
}

// ============================================================================
// USER BEHAVIOR ANALYTICS
// ============================================================================

class UserBehavior {
  final String userId;
  final DateTime timestamp;
  final String action;
  final String screen;
  final Map<String, dynamic> properties;
  final String sessionId;
  final Duration? timeOnScreen;

  UserBehavior({
    required this.userId,
    required this.timestamp,
    required this.action,
    required this.screen,
    required this.properties,
    required this.sessionId,
    this.timeOnScreen,
  });

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      action: json['action'],
      screen: json['screen'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      sessionId: json['sessionId'],
      timeOnScreen: json['timeOnScreen'] != null 
          ? Duration(milliseconds: json['timeOnScreen']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'screen': screen,
      'properties': properties,
      'sessionId': sessionId,
      'timeOnScreen': timeOnScreen?.inMilliseconds,
    };
  }
}

class UserSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> screens;
  final List<String> actions;
  final Duration? duration;
  final String? deviceInfo;
  final String? appVersion;

  UserSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.screens,
    required this.actions,
    this.duration,
    this.deviceInfo,
    this.appVersion,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      screens: List<String>.from(json['screens'] ?? []),
      actions: List<String>.from(json['actions'] ?? []),
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration']) 
          : null,
      deviceInfo: json['deviceInfo'],
      appVersion: json['appVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endDate': endTime?.toIso8601String(),
      'screens': screens,
      'actions': actions,
      'duration': duration?.inMilliseconds,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
    };
  }

  bool get isActive => endTime == null;
  
  Duration get sessionDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }
}

// ============================================================================
// BUSINESS METRICS
// ============================================================================

class BusinessMetric {
  final String id;
  final String name;
  final String category;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic> dimensions;
  final String? userId;

  BusinessMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.dimensions,
    this.userId,
  });

  factory BusinessMetric.fromJson(Map<String, dynamic> json) {
    return BusinessMetric(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      value: json['value']?.toDouble() ?? 0.0,
      unit: json['unit'],
      timestamp: DateTime.parse(json['timestamp']),
      dimensions: Map<String, dynamic>.from(json['dimensions'] ?? {}),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'dimensions': dimensions,
      'userId': userId,
    );
  }
}

class ConversionFunnel {
  final String id;
  final String name;
  final List<FunnelStep> steps;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int> stepCounts;
  final double overallConversionRate;

  ConversionFunnel({
    required this.id,
    required this.name,
    required this.steps,
    required this.startDate,
    required this.endDate,
    required this.stepCounts,
    required this.overallConversionRate,
  });

  factory ConversionFunnel.fromJson(Map<String, dynamic> json) {
    return ConversionFunnel(
      id: json['id'],
      name: json['name'],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((step) => FunnelStep.fromJson(step))
              .toList() ??
          [],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      stepCounts: Map<String, int>.from(json['stepCounts'] ?? {}),
      overallConversionRate: json['overallConversionRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'steps': steps.map((step) => step.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'stepCounts': stepCounts,
      'overallConversionRate': overallConversionRate,
    };
  }
}

class FunnelStep {
  final String name;
  final String description;
  final int count;
  final double conversionRate;
  final double dropOffRate;

  FunnelStep({
    required this.name,
    required this.description,
    required this.count,
    required this.conversionRate,
    required this.dropOffRate,
  });

  factory FunnelStep.fromJson(Map<String, dynamic> json) {
    return FunnelStep(
      name: json['name'],
      description: json['description'],
      count: json['count'] ?? 0,
      conversionRate: json['conversionRate']?.toDouble() ?? 0.0,
      dropOffRate: json['dropOffRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'count': count,
      'conversionRate': conversionRate,
      'dropOffRate': dropOffRate,
    };
  }
}

// ============================================================================
// RETENTION AND ENGAGEMENT
// ============================================================================

class RetentionMetric {
  final String userId;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final int totalSessions;
  final int daysActive;
  final double retentionRate;
  final List<DateTime> activeDates;

  RetentionMetric({
    required this.userId,
    required this.firstSeen,
    required this.lastSeen,
    required this.totalSessions,
    required this.daysActive,
    required this.retentionRate,
    required this.activeDates,
  });

  factory RetentionMetric.fromJson(Map<String, dynamic> json) {
    return RetentionMetric(
      userId: json['userId'],
      firstSeen: DateTime.parse(json['firstSeen']),
      lastSeen: DateTime.parse(json['lastSeen']),
      totalSessions: json['totalSessions'] ?? 0,
      daysActive: json['daysActive'] ?? 0,
      retentionRate: json['retentionRate']?.toDouble() ?? 0.0,
      activeDates: (json['activeDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstSeen': firstSeen.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'totalSessions': totalSessions,
      'daysActive': daysActive,
      'retentionRate': retentionRate,
      'activeDates': activeDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  Duration get userLifetime => lastSeen.difference(firstSeen);
  
  bool get isRetained => retentionRate > 0.5;
  
  int get daysSinceLastSeen => DateTime.now().difference(lastSeen).inDays;
}

class EngagementScore {
  final String userId;
  final double score;
  final DateTime calculatedAt;
  final Map<String, double> factors;
  final String tier;

  EngagementScore({
    required this.userId,
    required this.score,
    required this.calculatedAt,
    required this.factors,
    required this.tier,
  });

  factory EngagementScore.fromJson(Map<String, dynamic> json) {
    return EngagementScore(
      userId: json['userId'],
      score: json['score']?.toDouble() ?? 0.0,
      calculatedAt: DateTime.parse(json['calculatedAt']),
      factors: Map<String, double>.from(json['factors'] ?? {}),
      tier: json['tier'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'score': score,
      'calculatedAt': calculatedAt.toIso8601String(),
      'factors': factors,
      'tier': tier,
    };
  }

  bool get isHighEngagement => score > 0.7;
  bool get isMediumEngagement => score > 0.4 && score <= 0.7;
  bool get isLowEngagement => score <= 0.4;
}