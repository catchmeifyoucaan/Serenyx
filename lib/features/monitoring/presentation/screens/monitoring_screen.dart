import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/monitoring_service.dart';
import '../../../../shared/models/analytics_models.dart';
import '../../../../core/theme/app_theme.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with TickerProviderStateMixin {
  final String _userId = 'demo-user';
  final MonitoringService _monitoringService = MonitoringService();
  
  List<PerformanceMetric> _performanceMetrics = [];
  List<UserEvent> _userEvents = [];
  List<ErrorReport> _errorReports = [];
  List<ABTest> _activeTests = [];
  AnalyticsDashboard? _analyticsDashboard;
  
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  String _selectedTimeRange = '24h';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _timeRanges = ['1h', '24h', '7d', '30d', '90d'];

  @override
  void initState() {
    super.initState();
    _monitoringService.initialize();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadPerformanceMetrics(),
        _loadUserEvents(),
        _loadErrorReports(),
        _loadActiveTests(),
        _loadAnalyticsDashboard(),
      ]);
      
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      _showSnackBar('Error loading monitoring data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPerformanceMetrics() async {
    final metrics = await _monitoringService.getUserPerformanceMetrics(
      userId: _userId,
      timeRange: _selectedTimeRange,
    );
    setState(() => _performanceMetrics = metrics);
  }

  Future<void> _loadUserEvents() async {
    final events = await _monitoringService.getUserEvents(
      userId: _userId,
      timeRange: _selectedTimeRange,
    );
    setState(() => _userEvents = events);
  }

  Future<void> _loadErrorReports() async {
    final errors = await _monitoringService.getErrorReports(
      timeRange: _selectedTimeRange,
    );
    setState(() => _errorReports = errors);
  }

  Future<void> _loadActiveTests() async {
    final tests = await _monitoringService.getActiveABTests();
    setState(() => _activeTests = tests);
  }

  Future<void> _loadAnalyticsDashboard() async {
    final dashboard = await _monitoringService.getAnalyticsDashboard(
      timeRange: _selectedTimeRange,
    );
    setState(() => _analyticsDashboard = dashboard);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: Text(
          'Monitoring & Analytics',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: AppTheme.colors.primary),
            onPressed: _showLanguageSelector,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.colors.primary),
            onPressed: _initializeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: _initializeData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeRangeSelector(),
                        const SizedBox(height: 24),
                        _buildOverviewCards(),
                        const SizedBox(height: 24),
                        _buildPerformanceMetricsSection(),
                        const SizedBox(height: 24),
                        _buildABTestingSection(),
                        const SizedBox(height: 24),
                        _buildAlertsSection(),
                        const SizedBox(height: 24),
                        _buildInsightsSection(),
                        const SizedBox(height: 24),
                        _buildUserEventsSection(),
                        const SizedBox(height: 24),
                        _buildErrorReportsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppTheme.colors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            'Time Range:',
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedTimeRange,
            underline: const SizedBox(),
            items: _timeRanges.map((range) {
              return DropdownMenuItem(
                value: range,
                child: Text(range),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTimeRange = value);
                _initializeData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    if (_analyticsDashboard == null) return const SizedBox.shrink();
    
    final metrics = _analyticsDashboard!.metrics;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          title: 'Total Users',
          value: '${(metrics.totalUsers / 1000).toStringAsFixed(1)}K',
          icon: Icons.people,
          color: AppTheme.colors.primary,
          trend: '+12%',
          trendUp: true,
        ),
        _buildMetricCard(
          title: 'Active Users',
          value: '${(metrics.activeUsers / 1000).toStringAsFixed(1)}K',
          icon: Icons.person_active,
          color: Colors.green,
          trend: '+8%',
          trendUp: true,
        ),
        _buildMetricCard(
          title: 'Retention Rate',
          value: '${(metrics.retentionRate * 100).toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.blue,
          trend: '+5%',
          trendUp: true,
        ),
        _buildMetricCard(
          title: 'Engagement Score',
          value: '${(metrics.engagementScore * 100).toStringAsFixed(1)}%',
          icon: Icons.engagement,
          color: Colors.purple,
          trend: '+3%',
          trendUp: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendUp ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      color: trendUp ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: trendUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.textStyles.headlineSmall?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsSection() {
    return _buildSectionCard(
      title: 'Performance Metrics',
      icon: Icons.speed,
      child: Column(
        children: _performanceMetrics.take(5).map((metric) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  _getMetricIcon(metric.type),
                  color: _getMetricColor(metric.type),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.name,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${metric.value.toStringAsFixed(2)} ${metric.unit}',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(metric.timestamp),
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildABTestingSection() {
    return _buildSectionCard(
      title: 'Active A/B Tests',
      icon: Icons.science,
      child: Column(
        children: _activeTests.map((test) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.outline.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        test.name,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTestStatusColor(test.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        test.status.name.toUpperCase(),
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: _getTestStatusColor(test.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  test.description,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.variant, color: AppTheme.colors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Variants: ${test.variants.join(', ')}',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timeline, color: AppTheme.colors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Ends: ${_formatDate(test.endDate)}',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAlertsSection() {
    if (_analyticsDashboard == null) return const SizedBox.shrink();
    
    final alerts = _analyticsDashboard!.performanceAlerts;
    
    return _buildSectionCard(
      title: 'Active Alerts',
      icon: Icons.warning,
      child: Column(
        children: alerts.where((alert) => !alert.isResolved).map((alert) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAlertSeverityColor(alert.severity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getAlertSeverityColor(alert.severity).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getAlertTypeIcon(alert.type),
                  color: _getAlertSeverityColor(alert.severity),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        alert.message,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAlertSeverityColor(alert.severity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.severity.name.toUpperCase(),
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightsSection() {
    if (_analyticsDashboard == null) return const SizedBox.shrink();
    
    final insights = _analyticsDashboard!.insights;
    
    return _buildSectionCard(
      title: 'AI Insights',
      icon: Icons.lightbulb,
      child: Column(
        children: insights.map((insight) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.outline.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getInsightTypeIcon(insight.type),
                      color: _getInsightTypeColor(insight.type),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        insight.title,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getImpactColor(insight.impact).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        insight.impact.toUpperCase(),
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: _getImpactColor(insight.impact),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.message,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Confidence: ${(insight.confidence * 100).toStringAsFixed(0)}%',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimestamp(insight.timestamp),
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserEventsSection() {
    return _buildSectionCard(
      title: 'Recent User Events',
      icon: Icons.event,
      child: Column(
        children: _userEvents.take(5).map((event) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  _getEventTypeIcon(event.type),
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.properties.isNotEmpty)
                        Text(
                          'Properties: ${event.properties.toString()}',
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(event.timestamp),
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorReportsSection() {
    return _buildSectionCard(
      title: 'Error Reports',
      icon: Icons.bug_report,
      child: Column(
        children: _errorReports.take(5).map((error) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getErrorSeverityColor(error.severity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getErrorSeverityColor(error.severity).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: _getErrorSeverityColor(error.severity),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        error.errorType,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getErrorSeverityColor(error.severity),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error.severity.name.toUpperCase(),
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  error.message,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                if (error.stackTrace.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Stack Trace: ${error.stackTrace.substring(0, error.stackTrace.length > 100 ? 100 : error.stackTrace.length)}...',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(error.timestamp),
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.colors.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.shadow.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.colors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildLanguageOption('en', 'English', '🇺🇸'),
                _buildLanguageOption('es', 'Español', '🇪🇸'),
                _buildLanguageOption('fr', 'Français', '🇫🇷'),
                _buildLanguageOption('de', 'Deutsch', '🇩🇪'),
                _buildLanguageOption('it', 'Italiano', '🇮🇹'),
                _buildLanguageOption('pt', 'Português', '🇵🇹'),
                _buildLanguageOption('ja', '日本語', '🇯🇵'),
                _buildLanguageOption('ko', '한국어', '🇰🇷'),
                _buildLanguageOption('zh', '中文', '🇨🇳'),
                _buildLanguageOption('ar', 'العربية', '🇸🇦'),
                _buildLanguageOption('hi', 'हिन्दी', '🇮🇳'),
                _buildLanguageOption('ru', 'Русский', '🇷🇺'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () {
        setState(() => _selectedLanguage = code);
        Navigator.pop(context);
        _initializeData();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colors.primary.withOpacity(0.1) : AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              name,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.colors.primary : AppTheme.colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for icons and colors
  IconData _getMetricIcon(String type) {
    switch (type.toLowerCase()) {
      case 'response_time': return Icons.speed;
      case 'memory_usage': return Icons.memory;
      case 'cpu_usage': return Icons.memory;
      case 'network_latency': return Icons.network_check;
      default: return Icons.analytics;
    }
  }

  Color _getMetricColor(String type) {
    switch (type.toLowerCase()) {
      case 'response_time': return Colors.orange;
      case 'memory_usage': return Colors.blue;
      case 'cpu_usage': return Colors.red;
      case 'network_latency': return Colors.green;
      default: return AppTheme.colors.primary;
    }
  }

  Color _getTestStatusColor(ABTestStatus status) {
    switch (status) {
      case ABTestStatus.active: return Colors.green;
      case ABTestStatus.paused: return Colors.orange;
      case ABTestStatus.completed: return Colors.blue;
      case ABTestStatus.draft: return Colors.grey;
    }
  }

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low: return Colors.blue;
      case AlertSeverity.medium: return Colors.orange;
      case AlertSeverity.high: return Colors.red;
      case AlertSeverity.critical: return Colors.purple;
    }
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.performance: return Icons.speed;
      case AlertType.error: return Icons.error;
      case AlertType.security: return Icons.security;
      case AlertType.business: return Icons.business;
    }
  }

  Color _getInsightTypeColor(InsightType type) {
    switch (type) {
      case InsightType.performance: return Colors.blue;
      case InsightType.user_behavior: return Colors.green;
      case InsightType.business: return Colors.purple;
      case InsightType.security: return Colors.orange;
    }
  }

  IconData _getInsightTypeIcon(InsightType type) {
    switch (type) {
      case InsightType.performance: return Icons.speed;
      case InsightType.user_behavior: return Icons.psychology;
      case InsightType.business: return Icons.trending_up;
      case InsightType.security: return Icons.security;
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'page_view': return Icons.visibility;
      case 'button_click': return Icons.touch_app;
      case 'form_submit': return Icons.send;
      case 'api_call': return Icons.api;
      default: return Icons.event;
    }
  }

  Color _getErrorSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low: return Colors.blue;
      case ErrorSeverity.medium: return Colors.orange;
      case ErrorSeverity.high: return Colors.red;
      case ErrorSeverity.critical: return Colors.purple;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}