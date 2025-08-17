+import 'package:flutter/material.dart';
+import 'package:flutter_animate/flutter_animate.dart';
+import '../../../../core/theme/app_theme.dart';
+import '../../../../shared/models/pet.dart';
+
+class PremiumAnalyticsDashboard extends StatefulWidget {
+  final Pet pet;
+  final bool isPremium;
+
+  const PremiumAnalyticsDashboard({
+    super.key,
+    required this.pet,
+    required this.isPremium,
+  });
+
+  @override
+  State<PremiumAnalyticsDashboard> createState() => _PremiumAnalyticsDashboardState();
+}
+
+class _PremiumAnalyticsDashboardState extends State<PremiumAnalyticsDashboard> {
+  List<Map<String, dynamic>> _analytics = [];
+  List<Map<String, dynamic>> _patterns = [];
+  List<Map<String, dynamic>> _healthTrends = [];
+
+  @override
+  void initState() {
+    super.initState();
+    _loadPremiumAnalytics();
+  }
+
+  void _loadPremiumAnalytics() {
+    // Mock data - in real app, this would come from premium analytics service
+    _analytics = [
+      {
+        'id': '1',
+        'category': 'Behavior',
+        'metric': 'Social Interaction Score',
+        'value': 87.5,
+        'unit': '%',
+        'trend': 'increasing',
+        'change': 12.3,
+        'period': 'Last 30 days',
+        'insights': [
+          'Increased playtime with other pets',
+          'More responsive to social cues',
+          'Improved separation anxiety scores',
+        ],
+      },
+      {
+        'id': '2',
+        'category': 'Health',
+        'metric': 'Energy Level Consistency',
+        'value': 92.1,
+        'unit': '%',
+        'trend': 'stable',
+        'change': 2.1,
+        'period': 'Last 30 days',
+        'insights': [
+          'Stable energy throughout the day',
+          'Consistent sleep patterns',
+          'Optimal activity distribution',
+        ],
+      },
+      {
+        'id': '3',
+        'category': 'Training',
+        'metric': 'Learning Efficiency',
+        'value': 78.9,
+        'unit': '%',
+        'trend': 'increasing',
+        'change': 8.7,
+        'period': 'Last 30 days',
+        'insights': [
+          'Faster command response times',
+          'Better retention of new skills',
+          'Improved focus during sessions',
+        ],
+      },
+    ];
+
+    _patterns = [
+      {
+        'id': '1',
+        'pattern': 'Morning Energy Peak',
+        'description': '${widget.pet.name} shows highest energy levels between 7-9 AM',
+        'confidence': 0.89,
+        'frequency': 'Daily',
+        'recommendations': [
+          'Schedule exercise during this window',
+          'Use for training sessions',
+          'Plan outdoor activities',
+        ],
+      },
+      {
+        'id': '2',
+        'pattern': 'Post-Meal Rest',
+        'description': 'Consistent 30-minute rest period after meals',
+        'confidence': 0.76,
+        'frequency': 'After each meal',
+        'recommendations': [
+          'Avoid strenuous activity post-meal',
+          'Provide quiet resting area',
+          'Schedule grooming during this time',
+        ],
+      },
+    ];
+
+    _healthTrends = [
+      {
+        'id': '1',
+        'metric': 'Weight',
+        'currentValue': 25.4,
+        'previousValue': 25.1,
+        'unit': 'kg',
+        'trend': 'increasing',
+        'change': 0.3,
+        'period': 'Last month',
+        'isHealthy': true,
+        'recommendations': [
+          'Continue current feeding schedule',
+          'Monitor for any sudden changes',
+          'Maintain regular exercise routine',
+        ],
+      },
+      {
+        'id': '2',
+        'metric': 'Activity Level',
+        'currentValue': 85.2,
+        'previousValue': 82.7,
+        'unit': 'minutes/day',
+        'trend': 'increasing',
+        'change': 2.5,
+        'period': 'Last month',
+        'isHealthy': true,
+        'recommendations': [
+          'Great progress in activity levels',
+          'Consider adding variety to exercises',
+          'Monitor for signs of fatigue',
+        ],
+      },
+    ];
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    if (!widget.isPremium) {
+      return _buildPremiumUpgradePrompt();
+    }
+
+    return SingleChildScrollView(
+      padding: const EdgeInsets.all(16.0),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          _buildDashboardHeader(),
+          const SizedBox(height: 24),
+          _buildAdvancedMetrics(),
+          const SizedBox(height: 24),
+          _buildBehavioralPatterns(),
+          const SizedBox(height: 24),
+          _buildHealthTrends(),
+          const SizedBox(height: 24),
+          _buildPredictiveInsights(),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildPremiumUpgradePrompt() {
+    return Center(
+      child: Padding(
+        padding: const EdgeInsets.all(32.0),
+        child: Column(
+          mainAxisAlignment: MainAxisAlignment.center,
+          children: [
+            Icon(
+              Icons.lock,
+              size: 80,
+              color: AppTheme.colors.textSecondary,
+            ),
+            const SizedBox(height: 24),
+            Text(
+              'Premium Analytics',
+              style: AppTheme.textStyles.headlineMedium?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            Text(
+              'Unlock advanced analytics, behavioral patterns, and predictive insights to better understand your pet\'s health and behavior.',
+              style: AppTheme.textStyles.bodyLarge?.copyWith(
+                color: AppTheme.colors.textSecondary,
+              ),
+              textAlign: TextAlign.center,
+            ),
+            const SizedBox(height: 32),
+            ElevatedButton.icon(
+              onPressed: () {
+                // Navigate to upgrade screen
+              },
+              icon: const Icon(Icons.star),
+              label: const Text('Upgrade to Premium'),
+              style: ElevatedButton.styleFrom(
+                backgroundColor: AppTheme.colors.warning,
+                foregroundColor: Colors.white,
+                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildDashboardHeader() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Row(
+              children: [
+                Icon(
+                  Icons.analytics,
+                  color: AppTheme.colors.primary,
+                  size: 28,
+                ),
+                const SizedBox(width: 12),
+                Text(
+                  'Premium Analytics Dashboard',
+                  style: AppTheme.textStyles.headlineSmall?.copyWith(
+                    color: AppTheme.colors.textPrimary,
+                  ),
+                ),
+              ],
+            ),
+            const SizedBox(height: 16),
+            Text(
+              'Advanced insights and predictive analytics for ${widget.pet.name}',
+              style: AppTheme.textStyles.bodyMedium?.copyWith(
+                color: AppTheme.colors.textSecondary,
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildAdvancedMetrics() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Advanced Metrics',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._analytics.map((analytics) => _buildAnalyticsCard(analytics)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildAnalyticsCard(Map<String, dynamic> analytics) {
+    return Container(
+      margin: const EdgeInsets.only(bottom: 16),
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        color: AppTheme.colors.surface,
+        borderRadius: BorderRadius.circular(12),
+        border: Border.all(color: AppTheme.colors.outline),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Row(
+            children: [
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      analytics['metric'],
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      analytics['category'],
+                      style: AppTheme.textStyles.bodySmall?.copyWith(
+                        color: AppTheme.colors.textSecondary,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+              Column(
+                crossAxisAlignment: CrossAxisAlignment.end,
+                children: [
+                  Text(
+                    '${analytics['value']}${analytics['unit']}',
+                    style: AppTheme.textStyles.headlineSmall?.copyWith(
+                      color: AppTheme.colors.primary,
+                      fontWeight: FontWeight.bold,
+                    ),
+                  ),
+                  Row(
+                    children: [
+                      Icon(
+                        _getTrendIcon(analytics['trend']),
+                        color: _getTrendColor(analytics['trend']),
+                        size: 16,
+                      ),
+                      const SizedBox(width: 4),
+                      Text(
+                        '${analytics['change'] > 0 ? '+' : ''}${analytics['change']}%',
+                        style: AppTheme.textStyles.bodySmall?.copyWith(
+                          color: _getTrendColor(analytics['trend']),
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                ],
+              ),
+            ],
+          ),
+          const SizedBox(height: 12),
+          Text(
+            'Period: ${analytics['period']}',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.textSecondary,
+            ),
+          ),
+          const SizedBox(height: 12),
+          Text(
+            'Key Insights:',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.primary,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          ...analytics['insights'].map<Widget>((insight) => Padding(
+            padding: const EdgeInsets.only(top: 4),
+            child: Row(
+              children: [
+                Icon(
+                  Icons.check_circle,
+                  color: AppTheme.colors.success,
+                  size: 16,
+                ),
+                const SizedBox(width: 8),
+                Expanded(
+                  child: Text(
+                    insight,
+                    style: AppTheme.textStyles.bodySmall?.copyWith(
+                      color: AppTheme.colors.textPrimary,
+                    ),
+                  ),
+                ),
+              ],
+            ),
+          )),
+        ],
+      ),
+    ).animate().fadeIn().slideX(begin: 0.3);
+  }
+
+  Widget _buildBehavioralPatterns() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Behavioral Patterns',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._patterns.map((pattern) => _buildPatternCard(pattern)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildPatternCard(Map<String, dynamic> pattern) {
+    return Container(
+      margin: const EdgeInsets.only(bottom: 16),
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        color: AppTheme.colors.surface,
+        borderRadius: BorderRadius.circular(12),
+        border: Border.all(color: AppTheme.colors.outline),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Row(
+            children: [
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      pattern['pattern'],
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      pattern['description'],
+                      style: AppTheme.textStyles.bodyMedium?.copyWith(
+                        color: AppTheme.colors.textSecondary,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+              Container(
+                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+                decoration: BoxDecoration(
+                  color: AppTheme.colors.primary.withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(12),
+                ),
+                child: Text(
+                  '${(pattern['confidence'] * 100).toInt()}%',
+                  style: AppTheme.textStyles.bodySmall?.copyWith(
+                    color: AppTheme.colors.primary,
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+              ),
+            ],
+          ),
+          const SizedBox(height: 8),
+          Text(
+            'Frequency: ${pattern['frequency']}',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.textSecondary,
+            ),
+          ),
+          const SizedBox(height: 12),
+          Text(
+            'Recommendations:',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.primary,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          ...pattern['recommendations'].map<Widget>((rec) => Padding(
+            padding: const EdgeInsets.only(top: 4),
+            child: Row(
+              children: [
+                Icon(
+                  Icons.lightbulb,
+                  color: AppTheme.colors.warning,
+                  size: 16,
+                ),
+                const SizedBox(width: 8),
+                Expanded(
+                  child: Text(
+                    rec,
+                    style: AppTheme.textStyles.bodySmall?.copyWith(
+                      color: AppTheme.colors.textPrimary,
+                    ),
+                  ),
+                ),
+              ],
+            ),
+          )),
+        ],
+      ),
+    ).animate().fadeIn().slideX(begin: 0.3);
+  }
+
+  Widget _buildHealthTrends() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Health Trends',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._healthTrends.map((trend) => _buildTrendCard(trend)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildTrendCard(Map<String, dynamic> trend) {
+    return Container(
+      margin: const EdgeInsets.only(bottom: 16),
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        color: AppTheme.colors.surface,
+        borderRadius: BorderRadius.circular(12),
+        border: Border.all(color: AppTheme.colors.outline),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Row(
+            children: [
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      trend['metric'],
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      '${trend['currentValue']} ${trend['unit']}',
+                      style: AppTheme.textStyles.bodyLarge?.copyWith(
+                        color: AppTheme.colors.primary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+              Column(
+                crossAxisAlignment: CrossAxisAlignment.end,
+                children: [
+                  Row(
+                    children: [
+                      Icon(
+                        _getTrendIcon(trend['trend']),
+                        color: _getTrendColor(trend['trend']),
+                        size: 16,
+                      ),
+                      const SizedBox(width: 4),
+                      Text(
+                        '${trend['change'] > 0 ? '+' : ''}${trend['change']}',
+                        style: AppTheme.textStyles.bodySmall?.copyWith(
+                          color: _getTrendColor(trend['trend']),
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  Container(
+                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+                    decoration: BoxDecoration(
+                      color: trend['isHealthy'] 
+                          ? AppTheme.colors.success.withOpacity(0.2)
+                          : AppTheme.colors.error.withOpacity(0.2),
+                      borderRadius: BorderRadius.circular(12),
+                    ),
+                    child: Text(
+                      trend['isHealthy'] ? 'Healthy' : 'Monitor',
+                      style: AppTheme.textStyles.bodySmall?.copyWith(
+                        color: trend['isHealthy'] 
+                            ? AppTheme.colors.success
+                            : AppTheme.colors.error,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                  ),
+                ],
+              ),
+            ],
+          ),
+          const SizedBox(height: 8),
+          Text(
+            'Period: ${trend['period']}',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.textSecondary,
+            ),
+          ),
+          const SizedBox(height: 12),
+          Text(
+            'Recommendations:',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.primary,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          ...trend['recommendations'].map<Widget>((rec) => Padding(
+            padding: const EdgeInsets.only(top: 4),
+            child: Row(
+              children: [
+                Icon(
+                  Icons.check_circle,
+                  color: AppTheme.colors.success,
+                  size: 16,
+                ),
+                const SizedBox(width: 8),
+                Expanded(
+                  child: Text(
+                    rec,
+                    style: AppTheme.textStyles.bodySmall?.copyWith(
+                      color: AppTheme.colors.textPrimary,
+                    ),
+                  ),
+                ),
+              ],
+            ),
+          )),
+        ],
+      ),
+    ).animate().fadeIn().slideX(begin: 0.3);
+  }
+
+  Widget _buildPredictiveInsights() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Row(
+              children: [
+                Icon(
+                  Icons.psychology,
+                  color: AppTheme.colors.warning,
+                  size: 28,
+                ),
+                const SizedBox(width: 12),
+                Text(
+                  'Predictive Insights',
+                  style: AppTheme.textStyles.titleLarge?.copyWith(
+                    color: AppTheme.colors.textPrimary,
+                  ),
+                ),
+              ],
+            ),
+            const SizedBox(height: 16),
+            Text(
+              'AI-powered predictions based on ${widget.pet.name}\'s patterns and behavior',
+              style: AppTheme.textStyles.bodyMedium?.copyWith(
+                color: AppTheme.colors.textSecondary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            Container(
+              padding: const EdgeInsets.all(16),
+              decoration: BoxDecoration(
+                color: AppTheme.colors.warning.withOpacity(0.1),
+                borderRadius: BorderRadius.circular(12),
+                border: Border.all(color: AppTheme.colors.warning.withOpacity(0.3)),
+              ),
+              child: Column(
+                crossAxisAlignment: CrossAxisAlignment.start,
+                children: [
+                  Text(
+                    'Upcoming Health Check',
+                    style: AppTheme.textStyles.titleMedium?.copyWith(
+                      color: AppTheme.colors.warning,
+                      fontWeight: FontWeight.bold,
+                    ),
+                  ),
+                  const SizedBox(height: 8),
+                  Text(
+                    'Based on current trends, ${widget.pet.name} may need a health checkup in the next 2-3 weeks.',
+                    style: AppTheme.textStyles.bodyMedium?.copyWith(
+                      color: AppTheme.colors.textPrimary,
+                    ),
+                  ),
+                ],
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  IconData _getTrendIcon(String trend) {
+    switch (trend) {
+      case 'increasing':
+        return Icons.trending_up;
+      case 'decreasing':
+        return Icons.trending_down;
+      case 'stable':
+        return Icons.trending_flat;
+      default:
+        return Icons.trending_flat;
+    }
+  }
+
+  Color _getTrendColor(String trend) {
+    switch (trend) {
+      case 'increasing':
+        return AppTheme.colors.success;
+      case 'decreasing':
+        return AppTheme.colors.error;
+      case 'stable':
+        return AppTheme.colors.primary;
+      default:
+        return AppTheme.colors.textSecondary;
+    }
+  }
+}// Premium Analytics Dashboard
