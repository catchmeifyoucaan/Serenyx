import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';

class BondingInsightsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Pet? pet;
  final String timeRange;

  const BondingInsightsCard({
    super.key,
    required this.stats,
    this.pet,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      decoration: BoxDecoration(
        color: AppTheme.gentleCream,
        borderRadius: BorderRadius.circular(AppConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.softPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.smRadius),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.softPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.mdSpacing),
              Expanded(
                child: Text(
                  'Bonding Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.lgSpacing),
          
          // Insights
          ..._buildInsights(),
          
          const SizedBox(height: AppConstants.lgSpacing),
          
          // Recommendations
          _buildRecommendations(),
        ],
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideY(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  List<Widget> _buildInsights() {
    final insights = <Widget>[];
    
    if (stats.isEmpty) {
      insights.add(_buildInsightItem(
        icon: Icons.info_outline,
        color: AppTheme.softPink,
        title: 'Getting Started',
        description: 'Complete your first session to unlock personalized insights!',
      ));
      return insights;
    }

    // Session completion insight
    final completionRate = stats['completion_rate'] ?? 0;
    if (completionRate >= 80) {
      insights.add(_buildInsightItem(
        icon: Icons.check_circle,
        color: AppTheme.leafGreen,
        title: 'Excellent Consistency',
        description: 'You\'re completing ${completionRate.toStringAsFixed(1)}% of your sessions! This shows great dedication to bonding time.',
      ));
    } else if (completionRate >= 60) {
      insights.add(_buildInsightItem(
        icon: Icons.trending_up,
        color: AppTheme.leafGreen,
        title: 'Good Progress',
        description: 'You\'re completing ${completionRate.toStringAsFixed(1)}% of your sessions. Keep up the great work!',
      ));
    } else {
      insights.add(_buildInsightItem(
        icon: Icons.lightbulb,
        color: AppTheme.heartPink,
        title: 'Room for Growth',
        description: 'Try to complete more sessions to strengthen your bond. Even short sessions make a difference!',
      ));
    }

    // Mood insight
    final averageMood = stats['average_mood'] ?? 0;
    if (averageMood >= 4.0) {
      insights.add(_buildInsightItem(
        icon: Icons.sentiment_very_satisfied,
        color: AppTheme.heartPink,
        title: 'Amazing Mood',
        description: 'Your average mood rating is ${averageMood.toStringAsFixed(1)}/5! You\'re both feeling wonderful together.',
      ));
    } else if (averageMood >= 3.0) {
      insights.add(_buildInsightItem(
        icon: Icons.sentiment_satisfied,
        color: AppTheme.leafGreen,
        title: 'Positive Vibes',
        description: 'Your average mood rating is ${averageMood.toStringAsFixed(1)}/5. You\'re building a strong connection!',
      ));
    } else {
      insights.add(_buildInsightItem(
        icon: Icons.sentiment_neutral,
        color: AppTheme.softPurple,
        title: 'Building Connection',
        description: 'Your average mood rating is ${averageMood.toStringAsFixed(1)}/5. Try different session types to find what works best.',
      ));
    }

    // Session type insight
    final favoriteType = stats['favorite_session_type'] ?? 'None';
    if (favoriteType != 'None') {
      insights.add(_buildInsightItem(
        icon: Icons.favorite,
        color: AppTheme.heartPink,
        title: 'Session Preference',
        description: 'You love ${favoriteType.toLowerCase()} sessions! This type really resonates with you both.',
      ));
    }

    // Time of day insight
    final bestTime = stats['best_time_of_day'] ?? 'Unknown';
    if (bestTime != 'Unknown') {
      insights.add(_buildInsightItem(
        icon: Icons.schedule,
        color: AppTheme.softPurple,
        title: 'Optimal Timing',
        description: 'Your best bonding time is $bestTime. Consider scheduling more sessions during this period.',
      ));
    }

    return insights;
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.mdSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppConstants.xsSpacing),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (stats.isEmpty) return const SizedBox.shrink();

    final recommendations = <String>[];
    
    // Add personalized recommendations based on stats
    final completionRate = stats['completion_rate'] ?? 0;
    if (completionRate < 70) {
      recommendations.add('Set daily reminders for bonding time');
      recommendations.add('Start with shorter, 5-minute sessions');
    }

    final averageMood = stats['average_mood'] ?? 0;
    if (averageMood < 3.5) {
      recommendations.add('Try different session types to find what works best');
      recommendations.add('Focus on creating a calm, distraction-free environment');
    }

    final totalSessions = stats['total_sessions'] ?? 0;
    if (totalSessions < 5) {
      recommendations.add('Aim for at least 3 sessions per week');
      recommendations.add('Experiment with different times of day');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Keep up your amazing bonding routine!');
      recommendations.add('Consider trying new session types for variety');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: TextStyle(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppConstants.mdSpacing),
        ...recommendations.map((recommendation) => 
          Container(
            margin: const EdgeInsets.only(bottom: AppConstants.smSpacing),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mdSpacing,
              vertical: AppConstants.smSpacing,
            ),
            decoration: BoxDecoration(
              color: AppTheme.softPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: AppTheme.heartPink,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.smSpacing),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      color: AppTheme.warmGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}