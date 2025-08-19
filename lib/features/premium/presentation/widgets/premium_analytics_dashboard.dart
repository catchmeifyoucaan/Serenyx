import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/analytics_models.dart';
import 'package:intl/intl.dart';

class PremiumAnalyticsDashboard extends StatefulWidget {
  final Pet pet;
  final bool isPremium;

  const PremiumAnalyticsDashboard({
    super.key,
    required this.pet,
    required this.isPremium,
  });

  @override
  State<PremiumAnalyticsDashboard> createState() => _PremiumAnalyticsDashboardState();
}

class _PremiumAnalyticsDashboardState extends State<PremiumAnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<AnalyticsMetric> _metrics = [];
  final List<HealthTrend> _healthTrends = [];
  final List<BehavioralInsight> _behavioralInsights = [];
  final List<ActivitySummary> _activitySummaries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    // Load real analytics data from storage/database
    // For now, we'll start with empty lists for a clean slate
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPremium) {
      return _buildUpgradePrompt();
    }

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildTabBar(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildHealthTab(),
              _buildBehaviorTab(),
              _buildActivityTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradePrompt() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 80,
              color: AppTheme.colors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Analytics Dashboard',
              style: AppTheme.textStyles.headlineMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock advanced analytics, detailed insights, and comprehensive reporting to better understand your pet\'s health and behavior patterns.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to premium upgrade
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analytics Dashboard',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      color: AppTheme.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Comprehensive insights into ${widget.pet.name}\'s health, behavior, and activity patterns.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Card(
      elevation: 2,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.colors.primary,
        unselectedLabelColor: AppTheme.colors.textSecondary,
        indicatorColor: AppTheme.colors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
          Tab(icon: Icon(Icons.psychology), text: 'Behavior'),
          Tab(icon: Icon(Icons.fitness_center), text: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKeyMetrics(),
          const SizedBox(height: 24),
          _buildQuickInsights(),
          const SizedBox(height: 24),
          _buildTrendsOverview(),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildMetricCard(
              'Health Score',
              '92%',
              Icons.health_and_safety,
              AppTheme.colors.success,
              'Excellent condition',
            ),
            _buildMetricCard(
              'Activity Level',
              'High',
              Icons.fitness_center,
              AppTheme.colors.primary,
              'Very active',
            ),
            _buildMetricCard(
              'Behavior Score',
              '88%',
              Icons.psychology,
              AppTheme.colors.warning,
              'Good behavior',
            ),
            _buildMetricCard(
              'Training Progress',
              '75%',
              Icons.school,
              AppTheme.colors.info,
              'Making progress',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.textStyles.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsights() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Insights',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Health',
              '${widget.pet.name} is maintaining excellent health with consistent exercise and proper nutrition.',
              Icons.health_and_safety,
              AppTheme.colors.success,
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Behavior',
              'Recent improvements in obedience training show positive learning patterns.',
              Icons.psychology,
              AppTheme.colors.warning,
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Activity',
              'Daily exercise routine is well-established and contributing to overall well-being.',
              Icons.fitness_center,
              AppTheme.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsOverview() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trends Overview',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendItem(
              'Health Score',
              '↗️ +5%',
              'Improving over the last 30 days',
              AppTheme.colors.success,
            ),
            const SizedBox(height: 12),
            _buildTrendItem(
              'Activity Level',
              '→ 0%',
              'Consistent activity maintained',
              AppTheme.colors.primary,
            ),
            const SizedBox(height: 12),
            _buildTrendItem(
              'Training Progress',
              '↗️ +12%',
              'Significant improvement in commands',
              AppTheme.colors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String metric, String change, String description, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric,
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            change,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthMetrics(),
          const SizedBox(height: 24),
          _buildHealthTrends(),
          const SizedBox(height: 24),
          _buildHealthRecommendations(),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Metrics',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'Weight',
                    '25.5 lbs',
                    'Stable',
                    Icons.monitor_weight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthMetric(
                    'Heart Rate',
                    '72 bpm',
                    'Normal',
                    Icons.favorite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'Temperature',
                    '101.2°F',
                    'Normal',
                    Icons.thermostat,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthMetric(
                    'Hydration',
                    'Good',
                    'Well hydrated',
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String name, String value, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.colors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTrends() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Trends',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendChart('Weight Trend', 'Last 30 days'),
            const SizedBox(height: 16),
            _buildTrendChart('Activity Level', 'Weekly average'),
            const SizedBox(height: 16),
            _buildTrendChart('Sleep Quality', 'Daily average'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Chart visualization would go here',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecommendations() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Recommendations',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Continue current exercise routine',
              'Your pet is responding well to the current activity level.',
              Icons.check_circle,
              AppTheme.colors.success,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Monitor weight monthly',
              'Current weight is stable, continue monitoring for any changes.',
              Icons.info,
              AppTheme.colors.info,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Schedule annual checkup',
              'Next vet visit recommended in 3 months.',
              Icons.calendar_today,
              AppTheme.colors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBehaviorMetrics(),
          const SizedBox(height: 24),
          _buildBehaviorPatterns(),
          const SizedBox(height: 24),
          _buildBehaviorInsights(),
        ],
      ),
    );
  }

  Widget _buildBehaviorMetrics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavior Metrics',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBehaviorMetric(
                    'Obedience',
                    '85%',
                    'Good',
                    Icons.school,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBehaviorMetric(
                    'Socialization',
                    '78%',
                    'Improving',
                    Icons.people,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBehaviorMetric(
                    'Anxiety Level',
                    'Low',
                    'Well managed',
                    Icons.psychology,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBehaviorMetric(
                    'Aggression',
                    'None',
                    'Very friendly',
                    Icons.sentiment_satisfied,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorMetric(String name, String value, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.colors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorPatterns() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavior Patterns',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPatternItem(
              'Morning Energy',
              'High energy levels between 7-9 AM',
              Icons.wb_sunny,
              AppTheme.colors.warning,
            ),
            const SizedBox(height: 12),
            _buildPatternItem(
              'Training Response',
              'Best learning occurs in 15-minute sessions',
              Icons.schedule,
              AppTheme.colors.primary,
            ),
            const SizedBox(height: 12),
            _buildPatternItem(
              'Social Interaction',
              'Prefers calm, gradual introductions',
              Icons.people,
              AppTheme.colors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorInsights() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavior Insights',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Learning Style',
              '${widget.pet.name} responds best to positive reinforcement and short, focused training sessions.',
              Icons.lightbulb,
              AppTheme.colors.warning,
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Social Preferences',
              'Shows preference for familiar people and gradual introduction to new environments.',
              Icons.psychology,
              AppTheme.colors.info,
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Stress Triggers',
              'Loud noises and sudden movements can cause temporary anxiety.',
              Icons.warning,
              AppTheme.colors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityMetrics(),
          const SizedBox(height: 24),
          _buildActivityBreakdown(),
          const SizedBox(height: 24),
          _buildActivityGoals(),
        ],
      ),
    );
  }

  Widget _buildActivityMetrics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Metrics',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActivityMetric(
                    'Daily Steps',
                    '8,500',
                    'Target: 10,000',
                    Icons.directions_walk,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActivityMetric(
                    'Exercise Time',
                    '45 min',
                    'Target: 60 min',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActivityMetric(
                    'Play Sessions',
                    '3',
                    'Target: 4',
                    Icons.sports_esports,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActivityMetric(
                    'Training Time',
                    '20 min',
                    'Target: 30 min',
                    Icons.school,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetric(String name, String value, String target, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.colors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            target,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Breakdown',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem('Walking', '30 min', '35%', AppTheme.colors.primary),
            const SizedBox(height: 12),
            _buildActivityItem('Play Time', '15 min', '18%', AppTheme.colors.success),
            const SizedBox(height: 12),
            _buildActivityItem('Training', '20 min', '24%', AppTheme.colors.warning),
            const SizedBox(height: 12),
            _buildActivityItem('Rest', '20 min', '23%', AppTheme.colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String duration, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            activity,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
            ),
          ),
        ),
        Text(
          duration,
          style: AppTheme.textStyles.bodyMedium?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          percentage,
          style: AppTheme.textStyles.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityGoals() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Goals',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem(
              'Increase daily steps to 10,000',
              '85%',
              AppTheme.colors.success,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Extend exercise time to 60 minutes',
              '75%',
              AppTheme.colors.warning,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Add one more play session',
              '60%',
              AppTheme.colors.info,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Increase training time to 30 minutes',
              '67%',
              AppTheme.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, String progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                goal,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                ),
              ),
            ),
            Text(
              progress,
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _parseProgress(progress),
          backgroundColor: AppTheme.colors.surface,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  double _parseProgress(String progress) {
    return double.parse(progress.replaceAll('%', '')) / 100;
  }
}
