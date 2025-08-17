diff --git a/lib/features/ai_ml/presentation/widgets/behavioral_prediction_widget.dart b/lib/features/ai_ml/presentation/widgets/behavioral_prediction_widget.dart
--- a/lib/features/ai_ml/presentation/widgets/behavioral_prediction_widget.dart
+++ b/lib/features/ai_ml/presentation/widgets/behavioral_prediction_widget.dart
@@ -0,0 +1,556 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_animate/flutter_animate.dart';
+import '../../../../core/theme/app_theme.dart';
+import '../../../../shared/models/pet.dart';
+import '../../../../shared/models/ai_models.dart';
+
+class BehavioralPredictionWidget extends StatefulWidget {
+  final Pet pet;
+
+  const BehavioralPredictionWidget({super.key, required this.pet});
+
+  @override
+  State<BehavioralPredictionWidget> createState() => _BehavioralPredictionWidgetState();
+}
+
+class _BehavioralPredictionWidgetState extends State<BehavioralPredictionWidget> {
+  List<Map<String, dynamic>> _behaviorPredictions = [];
+  List<Map<String, dynamic>> _aiInsights = [];
+
+  @override
+  void initState() {
+    super.initState();
+    _loadBehaviorData();
+  }
+
+  void _loadBehaviorData() {
+    // Mock data - in real app, this would come from AI service
+    _behaviorPredictions = [
+      {
+        'id': '1',
+        'type': BehaviorType.playing,
+        'description': '${widget.pet.name} is likely to be most active between 3-5 PM',
+        'probability': 0.87,
+        'predictedTime': DateTime.now().add(const Duration(hours: 2)),
+        'factors': ['Previous activity patterns', 'Weather conditions', 'Recent rest periods'],
+        'recommendation': 'Schedule playtime and exercise during this window',
+      },
+      {
+        'id': '2',
+        'type': BehaviorType.sleeping,
+        'description': 'Expected deep sleep period from 10 PM to 6 AM',
+        'probability': 0.92,
+        'predictedTime': DateTime.now().add(const Duration(hours: 8)),
+        'factors': ['Circadian rhythm', 'Daily activity levels', 'Sleep quality history'],
+        'recommendation': 'Ensure quiet environment and comfortable sleeping area',
+      },
+      {
+        'id': '3',
+        'type': BehaviorType.socializing,
+        'description': 'High likelihood of seeking attention around meal times',
+        'probability': 0.78,
+        'predictedTime': DateTime.now().add(const Duration(hours: 4)),
+        'factors': ['Feeding schedule', 'Social interaction patterns', 'Attention-seeking behavior'],
+        'recommendation': 'Plan bonding activities and positive reinforcement',
+      },
+    ];
+
+    _aiInsights = [
+      {
+        'id': '1',
+        'title': 'Activity Pattern Recognition',
+        'description': '${widget.pet.name} shows consistent 3-hour activity cycles',
+        'category': 'Behavior',
+        'confidence': 0.89,
+        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
+        'recommendations': [
+          'Optimize exercise timing around these cycles',
+          'Schedule training during peak activity periods',
+          'Allow rest periods between active sessions',
+        ],
+        'metadata': {
+          'cycleLength': '3 hours',
+          'peakActivity': 'Afternoon',
+          'restPattern': 'Evening',
+        },
+      },
+      {
+        'id': '2',
+        'title': 'Social Interaction Trends',
+        'description': 'Increasing social engagement with family members',
+        'category': 'Social',
+        'confidence': 0.76,
+        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
+        'recommendations': [
+          'Continue positive reinforcement for social behavior',
+          'Introduce new social experiences gradually',
+          'Monitor for any signs of social anxiety',
+        ],
+        'metadata': {
+          'trend': 'Increasing',
+          'duration': '2 weeks',
+          'familyMembers': 'All',
+        },
+      },
+    ];
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return SingleChildScrollView(
+      padding: const EdgeInsets.all(16.0),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          _buildPredictionSummary(),
+          const SizedBox(height: 24),
+          _buildRunNewAnalysis(),
+          const SizedBox(height: 24),
+          _buildUpcomingPredictions(),
+          const SizedBox(height: 24),
+          _buildAIInsights(),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildPredictionSummary() {
+    final highConfidencePredictions = _behaviorPredictions
+        .where((pred) => pred['probability'] > 0.8)
+        .length;
+    
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
+                  color: AppTheme.colors.primary,
+                  size: 28,
+                ),
+                const SizedBox(width: 12),
+                Text(
+                  'Behavior Prediction Summary',
+                  style: AppTheme.textStyles.headlineSmall?.copyWith(
+                    color: AppTheme.colors.textPrimary,
+                  ),
+                ),
+              ],
+            ),
+            const SizedBox(height: 16),
+            Row(
+              children: [
+                Expanded(
+                  child: _buildPredictionStat(
+                    'High Confidence',
+                    '$highConfidencePredictions',
+                    'predictions',
+                    Icons.verified,
+                    AppTheme.colors.success,
+                  ),
+                ),
+                Expanded(
+                  child: _buildPredictionStat(
+                    'Total Predictions',
+                    '${_behaviorPredictions.length}',
+                    'active',
+                    Icons.analytics,
+                    AppTheme.colors.primary,
+                  ),
+                ),
+                Expanded(
+                  child: _buildPredictionStat(
+                    'AI Insights',
+                    '${_aiInsights.length}',
+                    'available',
+                    Icons.lightbulb,
+                    AppTheme.colors.warning,
+                  ),
+                ),
+              ],
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildPredictionStat(String label, String value, String unit, IconData icon, Color color) {
+    return Column(
+      children: [
+        Icon(icon, color: color, size: 32),
+        const SizedBox(height: 8),
+        Text(
+          value,
+          style: AppTheme.textStyles.titleLarge?.copyWith(
+            color: AppTheme.colors.textPrimary,
+            fontWeight: FontWeight.bold,
+          ),
+        ),
+        Text(
+          '$label $unit',
+          style: AppTheme.textStyles.bodySmall?.copyWith(
+            color: AppTheme.colors.textSecondary,
+          ),
+          textAlign: TextAlign.center,
+        ),
+      ],
+    );
+  }
+
+  Widget _buildRunNewAnalysis() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Run New Analysis',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            Text(
+              'Analyze recent behavior patterns to generate new predictions and insights',
+              style: AppTheme.textStyles.bodyMedium?.copyWith(
+                color: AppTheme.colors.textSecondary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            SizedBox(
+              width: double.infinity,
+              child: ElevatedButton.icon(
+                onPressed: () {
+                  _runNewAnalysis();
+                },
+                icon: const Icon(Icons.psychology),
+                label: const Text('Analyze Behavior'),
+                style: ElevatedButton.styleFrom(
+                  backgroundColor: AppTheme.colors.secondary,
+                  foregroundColor: Colors.white,
+                  padding: const EdgeInsets.symmetric(vertical: 16),
+                ),
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildUpcomingPredictions() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Upcoming Predictions',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._behaviorPredictions.map((prediction) => _buildPredictionCard(prediction)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
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
+              Container(
+                width: 40,
+                height: 40,
+                decoration: BoxDecoration(
+                  color: AppTheme.colors.primary.withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(20),
+                ),
+                child: Icon(
+                  _getBehaviorIcon(prediction['type']),
+                  color: AppTheme.colors.primary,
+                  size: 20,
+                ),
+              ),
+              const SizedBox(width: 16),
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      _getBehaviorText(prediction['type']),
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      '${(prediction['probability'] * 100).toInt()}% probability',
+                      style: AppTheme.textStyles.bodySmall?.copyWith(
+                        color: AppTheme.colors.primary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+              Container(
+                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+                decoration: BoxDecoration(
+                  color: _getProbabilityColor(prediction['probability']).withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(12),
+                ),
+                child: Text(
+                  _formatTime(prediction['predictedTime']),
+                  style: AppTheme.textStyles.bodySmall?.copyWith(
+                    color: _getProbabilityColor(prediction['probability']),
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+              ),
+            ],
+          ),
+          const SizedBox(height: 12),
+          Text(
+            prediction['description'],
+            style: AppTheme.textStyles.bodyMedium?.copyWith(
+              color: AppTheme.colors.textPrimary,
+            ),
+          ),
+          const SizedBox(height: 12),
+          Text(
+            'Recommendation:',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.primary,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          Text(
+            prediction['recommendation'],
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.textSecondary,
+            ),
+          ),
+        ],
+      ),
+    ).animate().fadeIn().slideX(begin: 0.3);
+  }
+
+  Widget _buildAIInsights() {
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
+                  Icons.lightbulb,
+                  color: AppTheme.colors.warning,
+                  size: 28,
+                ),
+                const SizedBox(width: 12),
+                Text(
+                  'AI Insights',
+                  style: AppTheme.textStyles.titleLarge?.copyWith(
+                    color: AppTheme.colors.textPrimary,
+                  ),
+                ),
+              ],
+            ),
+            const SizedBox(height: 16),
+            ..._aiInsights.map((insight) => _buildInsightCard(insight)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildInsightCard(Map<String, dynamic> insight) {
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
+                      insight['title'],
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      insight['description'],
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
+                  color: AppTheme.colors.warning.withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(12),
+                ),
+                child: Text(
+                  '${(insight['confidence'] * 100).toInt()}%',
+                  style: AppTheme.textStyles.bodySmall?.copyWith(
+                    color: AppTheme.colors.warning,
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+              ),
+            ],
+          ),
+          const SizedBox(height: 12),
+          Text(
+            'Recommendations:',
+            style: AppTheme.textStyles.bodySmall?.copyWith(
+              color: AppTheme.colors.primary,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          ...insight['recommendations'].map<Widget>((rec) => Padding(
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
+  void _runNewAnalysis() {
+    // TODO: Implement new behavior analysis
+    ScaffoldMessenger.of(context).showSnackBar(
+      SnackBar(
+        content: Text('Behavior analysis feature coming soon!'),
+        backgroundColor: AppTheme.colors.secondary,
+      ),
+    );
+  }
+
+  IconData _getBehaviorIcon(BehaviorType type) {
+    switch (type) {
+      case BehaviorType.eating:
+        return Icons.restaurant;
+      case BehaviorType.sleeping:
+        return Icons.bedtime;
+      case BehaviorType.playing:
+        return Icons.sports_esports;
+      case BehaviorType.socializing:
+        return Icons.people;
+      case BehaviorType.exploring:
+        return Icons.explore;
+      case BehaviorType.resting:
+        return Icons.weekend;
+      case BehaviorType.training:
+        return Icons.school;
+      case BehaviorType.grooming:
+        return Icons.brush;
+    }
+  }
+
+  String _getBehaviorText(BehaviorType type) {
+    switch (type) {
+      case BehaviorType.eating:
+        return 'Eating';
+      case BehaviorType.sleeping:
+        return 'Sleeping';
+      case BehaviorType.playing:
+        return 'Playing';
+      case BehaviorType.socializing:
+        return 'Socializing';
+      case BehaviorType.exploring:
+        return 'Exploring';
+      case BehaviorType.resting:
+        return 'Resting';
+      case BehaviorType.training:
+        return 'Training';
+      case BehaviorType.grooming:
+        return 'Grooming';
+    }
+  }
+
+  Color _getProbabilityColor(double probability) {
+    if (probability >= 0.8) {
+      return AppTheme.colors.success;
+    } else if (probability >= 0.6) {
+      return AppTheme.colors.warning;
+    } else {
+      return AppTheme.colors.error;
+    }
+  }
+
+  String _formatTime(DateTime time) {
+    final now = DateTime.now();
+    final difference = time.difference(now);
+    
+    if (difference.inHours < 1) {
+      return '${difference.inMinutes}m';
+    } else if (difference.inHours < 24) {
+      return '${difference.inHours}h';
+    } else {
+      return '${difference.inDays}d';
+    }
+  }
+}// Behavioral Prediction Widget
