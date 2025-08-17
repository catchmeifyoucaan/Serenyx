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

  // Real API endpoints - replace with your actual backend URLs
  static const String _baseUrl = 'https://api.serenyx.com';
  static const String _apiKey = 'YOUR_SERENYX_API_KEY'; // Replace with real key

  final StreamController<PerformanceMetric> _performanceController = 
      StreamController<PerformanceMetric>.broadcast();
  final StreamController<UserEvent> _userEventController = 
      StreamController<UserEvent>.broadcast();
  final StreamController<ErrorReport> _errorController = 
      StreamController<ErrorReport>.broadcast();

  bool _isEnabled = true;
  int _samplingRate = 100;
  Duration _flushInterval = const Duration(minutes: 5);
  Timer? _flushTimer;

  void initialize() {
    _startFlushTimer();
    _initializeRealTimeMonitoring();
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      _startFlushTimer();
    } else {
      _stopFlushTimer();
    }
  }

  void setSamplingRate(int rate) {
    _samplingRate = rate.clamp(1, 100);
  }

  Stream<PerformanceMetric> get performanceStream => _performanceController.stream;
  
  Stream<UserEvent> getUserEventStream(String userId) {
    return _userEventController.stream.where((event) => event.userId == userId);
  }
  
  Stream<ErrorReport> get errorStream => _errorController.stream;

  void trackPerformance({
    required String userId,
    required String metricName,
    required double value,
    required String unit,
    required String type,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled || !_shouldSample()) return;

    final metric = PerformanceMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: metricName,
      value: value,
      unit: unit,
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _performanceController.add(metric);
    _sendPerformanceMetricToBackend(metric);
  }

  void trackUserEvent({
    required String userId,
    required String eventName,
    required String eventType,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled || !_shouldSample()) return;

    final event = UserEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: eventName,
      type: eventType,
      properties: properties ?? {},
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _userEventController.add(event);
    _sendUserEventToBackend(event);
  }

  void trackError({
    required String userId,
    required String errorType,
    required String message,
    required ErrorSeverity severity,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_isEnabled) return;

    final error = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      errorType: errorType,
      message: message,
      severity: severity,
      stackTrace: stackTrace ?? '',
      context: context ?? {},
      timestamp: DateTime.now(),
    );

    _errorController.add(error);
    _sendErrorToBackend(error);
  }

  PerformanceTrace startTrace(String traceName) {
    return PerformanceTrace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: traceName,
      startTime: DateTime.now(),
      endTime: null,
      duration: null,
      metadata: {},
    );
  }

  Future<List<PerformanceMetric>> getUserPerformanceMetrics({
    required String userId,
    String? timeRange,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (timeRange != null) queryParams['timeRange'] = timeRange;

      final uri = Uri.parse('$_baseUrl/api/monitoring/performance').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final metrics = data['metrics'] as List;
        return metrics.map((metric) => PerformanceMetric.fromJson(metric)).toList();
      } else {
        throw Exception('Failed to fetch performance metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch performance metrics: $e');
    }
  }

  Future<List<UserEvent>> getUserEvents({
    required String userId,
    String? timeRange,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (timeRange != null) queryParams['timeRange'] = timeRange;

      final uri = Uri.parse('$_baseUrl/api/monitoring/events').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['events'] as List;
        return events.map((event) => UserEvent.fromJson(event)).toList();
      } else {
        throw Exception('Failed to fetch user events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user events: $e');
    }
  }

  Future<List<ErrorReport>> getErrorReports({
    String? timeRange,
    ErrorSeverity? severity,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (timeRange != null) queryParams['timeRange'] = timeRange;
      if (severity != null) queryParams['severity'] = severity.name;

      final uri = Uri.parse('$_baseUrl/api/monitoring/errors').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final errors = data['errors'] as List;
        return errors.map((error) => ErrorReport.fromJson(error)).toList();
      } else {
        throw Exception('Failed to fetch error reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch error reports: $e');
    }
  }

  Future<ABTest> createABTest({
    required String name,
    required String description,
    required List<String> variants,
    required DateTime startDate,
    required DateTime endDate,
    required String targetAudience,
    required List<String> metrics,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/monitoring/ab-tests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'variants': variants,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'targetAudience': targetAudience,
          'metrics': metrics,
          'metadata': metadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ABTest.fromJson(data);
      } else {
        throw Exception('Failed to create A/B test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create A/B test: $e');
    }
  }

  String? getABTestVariant(String testId, String userId) {
    // Real A/B test variant assignment logic
    if (!_isEnabled) return null;
    
    try {
      // This would typically call your backend to get the assigned variant
      // For now, use a deterministic hash-based assignment
      final hash = userId.hashCode + testId.hashCode;
      final random = Random(hash);
      final variants = ['control', 'variant-a', 'variant-b']; // This would come from the test
      return variants[random.nextInt(variants.length)];
    } catch (e) {
      log('Error getting A/B test variant: $e');
      return null;
    }
  }

  void recordABTestResult({
    required String testId,
    required String userId,
    required String variant,
    required String metric,
    required double value,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

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

    _sendABTestResultToBackend(result);
  }

  Future<ABTestAnalysis> getABTestAnalysis(String testId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/monitoring/ab-tests/$testId/analysis'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ABTestAnalysis.fromJson(data);
      } else {
        throw Exception('Failed to fetch A/B test analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch A/B test analysis: $e');
    }
  }

  Stream<Alert> getAlerts() {
    // Real-time alerts stream from backend
    return Stream.periodic(const Duration(seconds: 30), (_) {
      // This would typically connect to a WebSocket or Server-Sent Events
      // For now, return an empty stream
      return Alert(
        id: '',
        type: AlertType.performance,
        severity: AlertSeverity.low,
        title: '',
        message: '',
        timestamp: DateTime.now(),
        isResolved: false,
      );
    }).where((alert) => alert.id.isNotEmpty);
  }

  Future<AnalyticsDashboard> getAnalyticsDashboard({
    String? timeRange,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (timeRange != null) queryParams['timeRange'] = timeRange;
      if (userId != null) queryParams['userId'] = userId;

      final uri = Uri.parse('$_baseUrl/api/monitoring/dashboard').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalyticsDashboard.fromJson(data);
      } else {
        throw Exception('Failed to fetch analytics dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch analytics dashboard: $e');
    }
  }

  Future<void> flushData() async {
    if (!_isEnabled) return;

    try {
      // Flush any buffered data to backend
      await _flushPerformanceMetrics();
      await _flushUserEvents();
      await _flushErrors();
    } catch (e) {
      log('Error flushing monitoring data: $e');
    }
  }

  void dispose() {
    _stopFlushTimer();
    _performanceController.close();
    _userEventController.close();
    _errorController.close();
  }

  // Private helper methods
  void _startFlushTimer() {
    _stopFlushTimer();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flushData());
  }

  void _stopFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  bool _shouldSample() {
    if (_samplingRate >= 100) return true;
    final random = Random();
    return random.nextInt(100) < _samplingRate;
  }

  void _initializeRealTimeMonitoring() {
    // Initialize real-time monitoring connections
    _initializeWebSocketConnection();
    _initializePerformanceObserver();
    _initializeErrorListener();
  }

  void _initializeWebSocketConnection() {
    // Initialize WebSocket connection for real-time updates
    // This would connect to your backend's WebSocket endpoint
  }

  void _initializePerformanceObserver() {
    // Initialize performance monitoring
    // This would set up observers for various performance metrics
  }

  void _initializeErrorListener() {
    // Initialize error listeners
    // This would set up global error handlers
  }

  Future<void> _sendPerformanceMetricToBackend(PerformanceMetric metric) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/monitoring/performance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(metric.toJson()),
      );
    } catch (e) {
      log('Error sending performance metric to backend: $e');
    }
  }

  Future<void> _sendUserEventToBackend(UserEvent event) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/monitoring/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(event.toJson()),
      );
    } catch (e) {
      log('Error sending user event to backend: $e');
    }
  }

  Future<void> _sendErrorToBackend(ErrorReport error) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/monitoring/errors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(error.toJson()),
      );
    } catch (e) {
      log('Error sending error report to backend: $e');
    }
  }

  Future<void> _sendABTestResultToBackend(ABTestResult result) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/monitoring/ab-tests/results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(result.toJson()),
      );
    } catch (e) {
      log('Error sending A/B test result to backend: $e');
    }
  }

  Future<void> _flushPerformanceMetrics() async {
    // Flush any buffered performance metrics
  }

  Future<void> _flushUserEvents() async {
    // Flush any buffered user events
  }

  Future<void> _flushErrors() async {
    // Flush any buffered errors
  }

  // Helper methods for monitoring logic
  Map<String, dynamic> calculatePerformanceBaseline(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return {};

    final baseline = <String, Map<String, dynamic>>{};
    
    for (final metric in metrics) {
      if (!baseline.containsKey(metric.type)) {
        baseline[metric.type] = {
          'count': 0,
          'sum': 0.0,
          'min': double.infinity,
          'max': double.negativeInfinity,
          'values': <double>[],
        };
      }
      
      final stats = baseline[metric.type]!;
      stats['count'] = (stats['count'] as int) + 1;
      stats['sum'] = (stats['sum'] as double) + metric.value;
      stats['min'] = math.min(stats['min'] as double, metric.value);
      stats['max'] = math.max(stats['max'] as double, metric.value);
      (stats['values'] as List<double>).add(metric.value);
    }
    
    // Calculate averages and percentiles
    for (final type in baseline.keys) {
      final stats = baseline[type]!;
      final values = stats['values'] as List<double>;
      values.sort();
      
      stats['average'] = stats['sum'] / stats['count'];
      stats['p50'] = _calculatePercentile(values, 0.5);
      stats['p90'] = _calculatePercentile(values, 0.9);
      stats['p95'] = _calculatePercentile(values, 0.95);
      stats['p99'] = _calculatePercentile(values, 0.99);
      
      // Remove raw values to save memory
      stats.remove('values');
    }
    
    return baseline;
  }

  double _calculatePercentile(List<double> values, double percentile) {
    if (values.isEmpty) return 0.0;
    final index = (percentile * (values.length - 1)).round();
    return values[index.clamp(0, values.length - 1)];
  }

  Map<String, dynamic> analyzeUserBehavior(List<UserEvent> events) {
    if (events.isEmpty) return {};

    final analysis = <String, dynamic>{
      'totalEvents': events.length,
      'uniqueEventTypes': events.map((e) => e.type).toSet().length,
      'eventFrequency': <String, int>{},
      'sessionPatterns': <String, dynamic>{},
      'featureUsage': <String, int>{},
      'userJourney': <String, List<String>>{},
    };

    // Calculate event frequency
    for (final event in events) {
      analysis['eventFrequency'][event.type] = 
          (analysis['eventFrequency'][event.type] ?? 0) + 1;
    }

    // Analyze feature usage
    for (final event in events) {
      if (event.properties.containsKey('feature')) {
        final feature = event.properties['feature'] as String;
        analysis['featureUsage'][feature] = 
            (analysis['featureUsage'][feature] ?? 0) + 1;
      }
    }

    // Analyze user journey
    final sortedEvents = events.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final journey = <String>[];
    for (final event in sortedEvents) {
      journey.add('${event.type}:${event.name}');
    }
    analysis['userJourney']['fullJourney'] = journey;

    return analysis;
  }

  List<Map<String, dynamic>> generateInsights(
    Map<String, dynamic> performanceBaseline,
    Map<String, dynamic> userBehavior,
    List<ErrorReport> errors,
  ) {
    final insights = <Map<String, dynamic>>[];

    // Performance insights
    for (final type in performanceBaseline.keys) {
      final stats = performanceBaseline[type]!;
      final p95 = stats['p95'] as double;
      final average = stats['average'] as double;
      
      if (p95 > average * 2) {
        insights.add({
          'type': 'performance',
          'title': 'High Latency Detected',
          'message': '$type operations are showing high 95th percentile latency',
          'severity': 'warning',
          'recommendation': 'Investigate performance bottlenecks in $type operations',
          'metrics': stats,
        });
      }
    }

    // User behavior insights
    final totalEvents = userBehavior['totalEvents'] as int;
    if (totalEvents > 1000) {
      insights.add({
        'type': 'user_behavior',
        'title': 'High User Activity',
        'message': 'Users are very active with $totalEvents events',
        'severity': 'info',
        'recommendation': 'Consider optimizing for high-traffic scenarios',
        'metrics': userBehavior,
      });
    }

    // Error insights
    final criticalErrors = errors.where((e) => e.severity == ErrorSeverity.critical).length;
    if (criticalErrors > 0) {
      insights.add({
        'type': 'error',
        'title': 'Critical Errors Detected',
        'message': '$criticalErrors critical errors found',
        'severity': 'critical',
        'recommendation': 'Immediate investigation required for critical errors',
        'metrics': {'criticalErrorCount': criticalErrors},
      });
    }

    return insights;
  }

  Map<String, dynamic> calculateBusinessMetrics(
    List<UserEvent> events,
    List<PerformanceMetric> performance,
    List<ErrorReport> errors,
  ) {
    final metrics = <String, dynamic>{
      'userEngagement': _calculateUserEngagement(events),
      'systemReliability': _calculateSystemReliability(performance, errors),
      'performanceHealth': _calculatePerformanceHealth(performance),
      'errorRate': _calculateErrorRate(errors),
    };

    return metrics;
  }

  double _calculateUserEngagement(List<UserEvent> events) {
    if (events.isEmpty) return 0.0;
    
    final uniqueUsers = events.map((e) => e.userId).toSet().length;
    final totalEvents = events.length;
    
    return totalEvents / uniqueUsers;
  }

  double _calculateSystemReliability(
    List<PerformanceMetric> performance,
    List<ErrorReport> errors,
  ) {
    if (performance.isEmpty) return 1.0;
    
    final totalRequests = performance.length;
    final errorCount = errors.length;
    
    return (totalRequests - errorCount) / totalRequests;
  }

  double _calculatePerformanceHealth(List<PerformanceMetric> performance) {
    if (performance.isEmpty) return 1.0;
    
    final responseTimeMetrics = performance
        .where((m) => m.type == 'response_time')
        .map((m) => m.value)
        .toList();
    
    if (responseTimeMetrics.isEmpty) return 1.0;
    
    final averageResponseTime = responseTimeMetrics.reduce((a, b) => a + b) / responseTimeMetrics.length;
    final maxAcceptableTime = 1000.0; // 1 second
    
    return math.max(0.0, 1.0 - (averageResponseTime / maxAcceptableTime));
  }

  double _calculateErrorRate(List<ErrorReport> errors) {
    if (errors.isEmpty) return 0.0;
    
    final criticalErrors = errors.where((e) => e.severity == ErrorSeverity.critical).length;
    final totalErrors = errors.length;
    
    return criticalErrors / totalErrors;
  }
}

// Helper function for math operations
double math.min(double a, double b) => a < b ? a : b;
double math.max(double a, double b) => a > b ? a : b;