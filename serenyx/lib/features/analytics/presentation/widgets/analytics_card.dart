import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? trend;
  final String? trendLabel;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.trendLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: AppTheme.gentleCream,
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon
          Row(
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
              const Spacer(),
              if (trend != null) _buildTrendIndicator(),
            ],
          ),
          
          const SizedBox(height: AppConstants.mdSpacing),
          
          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppConstants.xsSpacing),
          
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppConstants.xsSpacing),
          
          // Subtitle
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.warmGrey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideY(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  Widget _buildTrendIndicator() {
    if (trend == null) return const SizedBox.shrink();
    
    final isPositive = trend! >= 0;
    final trendColor = isPositive ? AppTheme.leafGreen : AppTheme.heartPink;
    final trendIcon = isPositive ? Icons.trending_up : Icons.trending_down;
    final trendText = '${trend!.abs().toStringAsFixed(1)}%';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smSpacing,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.smRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            color: trendColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            trendText,
            style: TextStyle(
              color: trendColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}