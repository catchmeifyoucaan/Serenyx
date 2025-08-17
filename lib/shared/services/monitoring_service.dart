import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/analytics_models.dart';
import '../models/auth_models.dart';

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  // Stream controllers for real-time monitoring
  final StreamController<PerformanceMetric> _performanceController = 
      StreamController<PerformanceMetric>.broadcast();
  final StreamController<UserEvent> _userEventController = 
      StreamController<UserEvent>.broadcast();
  final StreamController<ErrorReport> _errorController = 
      StreamController<ErrorReport>.broadcast();

  // Analytics data storage
  final Map<String, List<PerformanceMetric>> _performanceMetrics = {};
  final Map<String, List<UserEvent>> _userEvents = {};
  final Map<String, List<ErrorReport>> _errorReports = {};
  final Map<String, ABTest> _activeTests = {};
  final Map<String, List<ABTestResult>> _testResults = {};

  // Configuration
  bool _isEnabled = true;
  int _samplingRate = 100; // Percentage of events to track
  Duration _flushInterval = const Duration(minutes: 5);
  Timer? _flushTimer;

  /// Initialize monitoring service
  void initialize() {
    _startFlushTimer();
    _initializeABTests();
    log('MonitoringService initialized');
  }

  /// Enable/disable monitoring
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      _startFlushTimer();
    } else {
      _flushTimer?.cancel();
    }
  }

  /// Set sampling rate (0-100)
  void setSamplingRate(int rate) {
    _samplingRate = rate.clamp(0, 100);
  }

  /// Get performance metrics stream
  Stream<PerformanceMetric> get performanceStream => _performanceController.stream;

  /// Get user events stream
  Stream<UserEvent> getUserEventStream(String userId) {
    return _userEventController.stream.where((event) => event.userId == userId);
  }

  /// Get error reports stream
  Stream<ErrorReport> get errorStream => _errorController.stream;

  /// Track performance metric
  void trackPerformance({
    required String userId,
    required String metricName,
    required double value,
    required String unit,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled || !_shouldSample()) return;

    final metric = PerformanceMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      metricName: metricName,
      value: value,
      unit: unit,
      category: category ?? 'general',
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    // Store locally
    if (!_performanceMetrics.containsKey(userId)) {
      _performanceMetrics[userId] = [];
    }
    _performanceMetrics[userId]!.add(metric);

    // Emit to stream
    _performanceController.add(metric);

    // Log for debugging
    log('Performance metric tracked: $metricName = $value $unit');
  }

  /// Track user event
  void trackUserEvent({
    required String userId,
    required String eventName,
    required String eventType,
    Map<String, dynamic>? properties,
    String? sessionId,
  }) {
    if (!_isEnabled || !_shouldSample()) return;

    final event = UserEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventName: eventName,
      eventType: eventType,
      timestamp: DateTime.now(),
      properties: properties ?? {},
      sessionId: sessionId ?? _generateSessionId(),
    );

    // Store locally
    if (!_userEvents.containsKey(userId)) {
      _userEvents[userId] = [];
    }
    _userEvents[userId]!.add(event);

    // Emit to stream
    _userEventController.add(event);

    // Log for debugging
    log('User event tracked: $eventName ($eventType)');
  }

  /// Track error
  void trackError({
    required String userId,
    required String errorType,
    required String errorMessage,
    required String stackTrace,
    String? screenName,
    Map<String, dynamic>? context,
  }) {
    if (!_isEnabled) return;

    final error = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      errorType: errorType,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      screenName: screenName,
      context: context ?? {},
      severity: _determineErrorSeverity(errorType, errorMessage),
    );

    // Store locally
    if (!_errorReports.containsKey(userId)) {
      _errorReports[userId] = [];
    }
    _errorReports[userId]!.add(error);

    // Emit to stream
    _errorController.add(error);

    // Log for debugging
    log('Error tracked: $errorType - $errorMessage', error: error);
  }

  /// Start performance trace
  PerformanceTrace startTrace(String traceName) {
    return PerformanceTrace(
      name: traceName,
      startTime: DateTime.now(),
      onStop: (duration, metadata) {
        trackPerformance(
          userId: 'system',
          metricName: traceName,
          value: duration.inMilliseconds.toDouble(),
          unit: 'ms',
          category: 'performance_trace',
          metadata: metadata,
        );
      },
    );
  }

  /// Get performance metrics for user
  Future<List<PerformanceMetric>> getUserPerformanceMetrics({
    required String userId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    List<PerformanceMetric> metrics = _performanceMetrics[userId] ?? [];

    // Filter by category
    if (category != null) {
      metrics = metrics.where((m) => m.category == category).toList();
    }

    // Filter by date range
    if (startDate != null) {
      metrics = metrics.where((m) => m.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      metrics = metrics.where((m) => m.timestamp.isBefore(endDate)).toList();
    }

    // Sort by timestamp (newest first)
    metrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Limit results
    if (metrics.length > limit) {
      metrics = metrics.take(limit).toList();
    }

    return metrics;
  }

  /// Get user events
  Future<List<UserEvent>> getUserEvents({
    required String userId,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    List<UserEvent> events = _userEvents[userId] ?? [];

    // Filter by event type
    if (eventType != null) {
      events = events.where((e) => e.eventType == eventType).toList();
    }

    // Filter by date range
    if (startDate != null) {
      events = events.where((e) => e.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      events = events.where((e) => e.timestamp.isBefore(endDate)).toList();
    }

    // Sort by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Limit results
    if (events.length > limit) {
      events = events.take(limit).toList();
    }

    return events;
  }

  /// Get error reports
  Future<List<ErrorReport>> getErrorReports({
    String? userId,
    String? errorType,
    ErrorSeverity? severity,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    List<ErrorReport> errors = [];
    
    if (userId != null) {
      errors = _errorReports[userId] ?? [];
    } else {
      // Get all errors
      for (final userErrors in _errorReports.values) {
        errors.addAll(userErrors);
      }
    }

    // Filter by error type
    if (errorType != null) {
      errors = errors.where((e) => e.errorType == errorType).toList();
    }

    // Filter by severity
    if (severity != null) {
      errors = errors.where((e) => e.severity == severity).toList();
    }

    // Filter by date range
    if (startDate != null) {
      errors = errors.where((e) => e.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      errors = errors.where((e) => e.timestamp.isBefore(endDate)).toList();
    }

    // Sort by timestamp (newest first)
    errors.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Limit results
    if (errors.length > limit) {
      errors = errors.take(limit).toList();
    }

    return errors;
  }

  /// Create A/B test
  Future<ABTest> createABTest({
    required String name,
    required String description,
    required List<String> variants,
    required String metric,
    required int sampleSize,
    required Duration duration,
    Map<String, dynamic>? targeting,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final test = ABTest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      variants: variants,
      metric: metric,
      sampleSize: sampleSize,
      duration: duration,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(duration),
      status: ABTestStatus.active,
      targeting: targeting ?? {},
      results: {},
    );

    _activeTests[test.id] = test;
    _testResults[test.id] = [];

    return test;
  }

  /// Get A/B test variant for user
  String? getABTestVariant(String testId, String userId) {
    final test = _activeTests[testId];
    if (test == null || test.status != ABTestStatus.active) return null;

    // Simple hash-based assignment
    final hash = userId.hashCode;
    final variantIndex = hash.abs() % test.variants.length;
    return test.variants[variantIndex];
  }

  /// Record A/B test result
  void recordABTestResult({
    required String testId,
    required String userId,
    required String variant,
    required String metric,
    required double value,
    Map<String, dynamic>? metadata,
  }) {
    final test = _activeTests[testId];
    if (test == null) return;

    final result = ABTestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: testId,
      userId: userId,
      variant: variant,
      metric: metric,
      value: value,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    // Store result
    if (!_testResults.containsKey(testId)) {
      _testResults[testId] = [];
    }
    _testResults[testId]!.add(result);

    // Update test results
    if (!test.results.containsKey(variant)) {
      test.results[variant] = [];
    }
    test.results[variant]!.add(value);
  }

  /// Get A/B test results
  Future<ABTestAnalysis> getABTestAnalysis(String testId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final test = _activeTests[testId];
    if (test == null) {
      return ABTestAnalysis(
        testId: testId,
        status: 'not_found',
        results: {},
        winner: null,
        confidence: 0.0,
        recommendations: [],
      );
    }

    final analysis = _analyzeABTest(test);
    return analysis;
  }

  /// Get real-time alerts
  Stream<Alert> getAlerts() {
    return Stream.periodic(const Duration(seconds: 30), (_) {
      return _generateAlerts();
    }).asyncExpand((alerts) async* {
      for (final alert in alerts) {
        yield alert;
      }
    });
  }

  /// Get analytics dashboard data
  Future<AnalyticsDashboard> getAnalyticsDashboard({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    // Get user metrics
    final performanceMetrics = await getUserPerformanceMetrics(
      userId: userId,
      startDate: start,
      endDate: end,
    );

    final userEvents = await getUserEvents(
      userId: userId,
      startDate: start,
      endDate: end,
    );

    final errorReports = await getErrorReports(
      userId: userId,
      startDate: start,
      endDate: end,
    );

    // Calculate metrics
    final totalEvents = userEvents.length;
    final totalErrors = errorReports.length;
    final avgPerformance = performanceMetrics.isNotEmpty
        ? performanceMetrics.map((m) => m.value).reduce((a, b) => a + b) / performanceMetrics.length
        : 0.0;

    // Generate insights
    final insights = _generateInsights(userEvents, performanceMetrics, errorReports);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      totalEvents,
      totalErrors,
      avgPerformance,
      insights,
    );

    return AnalyticsDashboard(
      userId: userId,
      period: TimeRange(start: start, end: end),
      metrics: DashboardMetrics(
        totalEvents: totalEvents,
        totalErrors: totalErrors,
        avgPerformance: avgPerformance,
        userEngagement: _calculateUserEngagement(userEvents),
        errorRate: totalEvents > 0 ? (totalErrors / totalEvents) * 100 : 0.0,
      ),
      insights: insights,
      recommendations: recommendations,
      charts: _generateCharts(userEvents, performanceMetrics, errorReports),
    );
  }

  /// Flush data to external service
  Future<void> flushData() async {
    if (!_isEnabled) return;

    try {
      // In real implementation, send data to analytics service
      log('Flushing monitoring data...');
      
      // Clear old data (keep last 7 days)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      
      for (final userId in _performanceMetrics.keys) {
        _performanceMetrics[userId] = _performanceMetrics[userId]!
            .where((m) => m.timestamp.isAfter(cutoffDate))
            .toList();
      }
      
      for (final userId in _userEvents.keys) {
        _userEvents[userId] = _userEvents[userId]!
            .where((e) => e.timestamp.isAfter(cutoffDate))
            .toList();
      }
      
      for (final userId in _errorReports.keys) {
        _errorReports[userId] = _errorReports[userId]!
            .where((e) => e.timestamp.isAfter(cutoffDate))
            .toList();
      }
      
      log('Monitoring data flushed successfully');
    } catch (e) {
      log('Failed to flush monitoring data: $e');
    }
  }

  // Private helper methods
  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flushData());
  }

  void _initializeABTests() {
    // Initialize with some sample A/B tests
    _activeTests['button_color_test'] = ABTest(
      id: 'button_color_test',
      name: 'Button Color Test',
      description: 'Test different button colors for engagement',
      variants: ['blue', 'green', 'orange'],
      metric: 'click_rate',
      sampleSize: 1000,
      duration: const Duration(days: 14),
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      status: ABTestStatus.active,
      targeting: {'userType': 'premium'},
      results: {},
    );
  }

  bool _shouldSample() {
    final random = Random();
    return random.nextInt(100) < _samplingRate;
  }

  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  ErrorSeverity _determineErrorSeverity(String errorType, String errorMessage) {
    if (errorType.contains('crash') || errorType.contains('fatal')) {
      return ErrorSeverity.critical;
    } else if (errorType.contains('error') || errorType.contains('exception')) {
      return ErrorSeverity.high;
    } else if (errorType.contains('warning')) {
      return ErrorSeverity.medium;
    } else {
      return ErrorSeverity.low;
    }
  }

  ABTestAnalysis _analyzeABTest(ABTest test) {
    final results = <String, List<double>>{};
    
    // Group results by variant
    for (final result in _testResults[test.id] ?? []) {
      if (!results.containsKey(result.variant)) {
        results[result.variant] = [];
      }
      results[result.variant]!.add(result.value);
    }

    // Calculate statistics
    final variantStats = <String, VariantStats>{};
    String? winner;
    double maxValue = 0.0;

    for (final entry in results.entries) {
      final variant = entry.key;
      final values = entry.value;
      
      if (values.isNotEmpty) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        final stdDev = _calculateStandardDeviation(values, avg);
        
        variantStats[variant] = VariantStats(
          variant: variant,
          count: values.length,
          average: avg,
          standardDeviation: stdDev,
          confidenceInterval: _calculateConfidenceInterval(values, avg, stdDev),
        );
        
        if (avg > maxValue) {
          maxValue = avg;
          winner = variant;
        }
      }
    }

    // Calculate confidence level
    final confidence = _calculateStatisticalSignificance(variantStats);

    // Generate recommendations
    final recommendations = <String>[];
    if (confidence > 0.95) {
      recommendations.add('Test shows statistically significant results');
      if (winner != null) {
        recommendations.add('Recommend implementing variant: $winner');
      }
    } else {
      recommendations.add('Test needs more data for statistical significance');
      recommendations.add('Continue running test for longer period');
    }

    return ABTestAnalysis(
      testId: test.id,
      status: test.status.name,
      results: variantStats,
      winner: winner,
      confidence: confidence,
      recommendations: recommendations,
    );
  }

  double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.length < 2) return 0.0;
    
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / (values.length - 1);
    return sqrt(variance);
  }

  double _calculateConfidenceInterval(List<double> values, double mean, double stdDev) {
    if (values.length < 2) return 0.0;
    
    // 95% confidence interval (1.96 * standard error)
    final standardError = stdDev / sqrt(values.length);
    return 1.96 * standardError;
  }

  double _calculateStatisticalSignificance(Map<String, VariantStats> variantStats) {
    // Simple confidence calculation based on sample sizes and variance
    if (variantStats.length < 2) return 0.0;
    
    final totalSamples = variantStats.values.map((v) => v.count).reduce((a, b) => a + b);
    final avgVariance = variantStats.values.map((v) => v.standardDeviation).reduce((a, b) => a + b) / variantStats.length;
    
    // Higher sample size and lower variance = higher confidence
    return (totalSamples / 1000) * (1 / (1 + avgVariance));
  }

  List<Alert> _generateAlerts() {
    final alerts = <Alert>[];
    
    // Check for high error rates
    final totalErrors = _errorReports.values.expand((e) => e).length;
    final totalEvents = _userEvents.values.expand((e) => e).length;
    
    if (totalEvents > 0) {
      final errorRate = (totalErrors / totalEvents) * 100;
      if (errorRate > 5.0) {
        alerts.add(Alert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AlertType.error,
          title: 'High Error Rate',
          message: 'Error rate is ${errorRate.toStringAsFixed(1)}%',
          severity: AlertSeverity.high,
          timestamp: DateTime.now(),
        ));
      }
    }
    
    // Check for performance issues
    final performanceMetrics = _performanceMetrics.values.expand((m) => m);
    if (performanceMetrics.isNotEmpty) {
      final avgPerformance = performanceMetrics.map((m) => m.value).reduce((a, b) => a + b) / performanceMetrics.length;
      if (avgPerformance > 5000) { // 5 seconds
        alerts.add(Alert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AlertType.performance,
          title: 'Performance Degradation',
          message: 'Average response time is ${avgPerformance.toStringAsFixed(0)}ms',
          severity: AlertSeverity.medium,
          timestamp: DateTime.now(),
        ));
      }
    }
    
    return alerts;
  }

  List<Insight> _generateInsights(
    List<UserEvent> events,
    List<PerformanceMetric> metrics,
    List<ErrorReport> errors,
  ) {
    final insights = <Insight>[];
    
    // User engagement insights
    if (events.isNotEmpty) {
      final eventTypes = events.map((e) => e.eventType).toSet();
      insights.add(Insight(
        type: InsightType.userEngagement,
        title: 'User Activity',
        description: 'User performed ${events.length} actions across ${eventTypes.length} different types',
        confidence: 0.8,
        recommendations: ['Continue monitoring user engagement patterns'],
      ));
    }
    
    // Performance insights
    if (metrics.isNotEmpty) {
      final avgPerformance = metrics.map((m) => m.value).reduce((a, b) => a + b) / metrics.length;
      if (avgPerformance > 1000) {
        insights.add(Insight(
          type: InsightType.performance,
          title: 'Performance Alert',
          description: 'Average performance is ${avgPerformance.toStringAsFixed(0)}ms',
          confidence: 0.9,
          recommendations: ['Investigate performance bottlenecks', 'Optimize critical paths'],
        ));
      }
    }
    
    // Error insights
    if (errors.isNotEmpty) {
      final criticalErrors = errors.where((e) => e.severity == ErrorSeverity.critical).length;
      if (criticalErrors > 0) {
        insights.add(Insight(
          type: InsightType.error,
          title: 'Critical Errors Detected',
          description: '$criticalErrors critical errors found',
          confidence: 0.95,
          recommendations: ['Immediate investigation required', 'Check system health'],
        ));
      }
    }
    
    return insights;
  }

  List<String> _generateRecommendations(
    int totalEvents,
    int totalErrors,
    double avgPerformance,
    List<Insight> insights,
  ) {
    final recommendations = <String>[];
    
    if (totalEvents == 0) {
      recommendations.add('No user activity detected - consider user onboarding improvements');
    }
    
    if (totalErrors > 0) {
      recommendations.add('Implement error monitoring and alerting');
      recommendations.add('Review error handling procedures');
    }
    
    if (avgPerformance > 2000) {
      recommendations.add('Optimize application performance');
      recommendations.add('Implement performance monitoring');
    }
    
    if (insights.isEmpty) {
      recommendations.add('Collect more data for meaningful insights');
    }
    
    return recommendations;
  }

  double _calculateUserEngagement(List<UserEvent> events) {
    if (events.isEmpty) return 0.0;
    
    // Calculate engagement score based on event frequency and variety
    final uniqueEventTypes = events.map((e) => e.eventType).toSet().length;
    final totalEvents = events.length;
    final timeSpan = events.last.timestamp.difference(events.first.timestamp).inDays + 1;
    
    return (uniqueEventTypes * totalEvents) / (timeSpan * 10); // Normalized score
  }

  List<ChartData> _generateCharts(
    List<UserEvent> events,
    List<PerformanceMetric> metrics,
    List<ErrorReport> errors,
  ) {
    final charts = <ChartData>[];
    
    // User events over time
    if (events.isNotEmpty) {
      final eventCounts = <String, int>{};
      for (final event in events) {
        eventCounts[event.eventType] = (eventCounts[event.eventType] ?? 0) + 1;
      }
      
      charts.add(ChartData(
        type: ChartType.pie,
        title: 'User Event Distribution',
        data: eventCounts.entries.map((e) => ChartPoint(
          label: e.key,
          value: e.value.toDouble(),
        )).toList(),
      ));
    }
    
    // Performance over time
    if (metrics.isNotEmpty) {
      final performanceData = metrics.map((m) => ChartPoint(
        label: m.timestamp.toIso8601String().substring(0, 10),
        value: m.value,
      )).toList();
      
      charts.add(ChartData(
        type: ChartType.line,
        title: 'Performance Over Time',
        data: performanceData,
      ));
    }
    
    // Error distribution
    if (errors.isNotEmpty) {
      final errorCounts = <String, int>{};
      for (final error in errors) {
        errorCounts[error.errorType] = (errorCounts[error.errorType] ?? 0) + 1;
      }
      
      charts.add(ChartData(
        type: ChartType.bar,
        title: 'Error Distribution',
        data: errorCounts.entries.map((e) => ChartPoint(
          label: e.key,
          value: e.value.toDouble(),
        )).toList(),
      ));
    }
    
    return charts;
  }

  /// Dispose resources
  void dispose() {
    _flushTimer?.cancel();
    _performanceController.close();
    _userEventController.close();
    _errorController.close();
  }
}

// Performance trace utility
class PerformanceTrace {
  final String name;
  final DateTime startTime;
  final Function(Duration duration, Map<String, dynamic> metadata) onStop;

  PerformanceTrace({
    required this.name,
    required this.startTime,
    required this.onStop,
  });

  void stop([Map<String, dynamic>? metadata]) {
    final duration = DateTime.now().difference(startTime);
    onStop(duration, metadata ?? {});
  }
}

// Additional models for monitoring service
class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
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
}

class ChartData {
  final ChartType type;
  final String title;
  final List<ChartPoint> data;

  ChartData({
    required this.type,
    required this.title,
    required this.data,
  });
}

class ChartPoint {
  final String label;
  final double value;

  ChartPoint({
    required this.label,
    required this.value,
  });
}

enum ChartType { line, bar, pie, area }

class Alert {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });
}

enum AlertType { error, performance, security, business }
enum AlertSeverity { low, medium, high, critical }

class Insight {
  final InsightType type;
  final String title;
  final String description;
  final double confidence;
  final List<String> recommendations;

  Insight({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.recommendations,
  });
}

enum InsightType { userEngagement, performance, error, business, security }

class DashboardMetrics {
  final int totalEvents;
  final int totalErrors;
  final double avgPerformance;
  final double userEngagement;
  final double errorRate;

  DashboardMetrics({
    required this.totalEvents,
    required this.totalErrors,
    required this.avgPerformance,
    required this.userEngagement,
    required this.errorRate,
  });
}

class AnalyticsDashboard {
  final String userId;
  final TimeRange period;
  final DashboardMetrics metrics;
  final List<Insight> insights;
  final List<String> recommendations;
  final List<ChartData> charts;

  AnalyticsDashboard({
    required this.userId,
    required this.period,
    required this.metrics,
    required this.insights,
    required this.recommendations,
    required this.charts,
  });
}