import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class SessionChart extends StatelessWidget {
  final Map<String, int> sessionFrequency;
  final String timeRange;

  const SessionChart({
    super.key,
    required this.sessionFrequency,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    if (sessionFrequency.isEmpty) {
      return _buildEmptyState();
    }

    final sortedEntries = sessionFrequency.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue = sessionFrequency.values.isNotEmpty 
        ? sessionFrequency.values.reduce((a, b) => a > b ? a : b) 
        : 0;

    return Container(
      height: 200,
      child: Column(
        children: [
          // Chart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sortedEntries.map((entry) {
                final height = maxValue > 0 
                    ? (entry.value / maxValue) * 120 
                    : 0;
                
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        // Bar
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.heartPink.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Container(
                              height: height.toDouble(),
                              decoration: BoxDecoration(
                                color: AppTheme.heartPink,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.heartPink.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ).animate()
                              .scaleY(
                                begin: 0,
                                duration: AppConstants.mediumAnimation,
                                delay: Duration(milliseconds: sortedEntries.indexOf(entry) * 100),
                              ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Label
                        Text(
                          _formatLabel(entry.key),
                          style: TextStyle(
                            color: AppTheme.warmGrey.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        // Value
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            color: AppTheme.heartPink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.heartPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sessions per ${_getTimeUnit()}',
                style: TextStyle(
                  color: AppTheme.warmGrey.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              color: AppTheme.warmGrey.withOpacity(0.3),
              size: 48,
            ),
            const SizedBox(height: AppConstants.smSpacing),
            Text(
              'No session data yet',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            Text(
              'Complete sessions to see your progress!',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        
        switch (timeRange) {
          case 'week':
            return '${month}/${year}';
          case 'month':
            return '${month}/${year}';
          case 'quarter':
            return 'Q${((month - 1) ~/ 3) + 1} ${year}';
          case 'year':
            return year.toString();
          default:
            return '${month}/${year}';
        }
      }
    } catch (e) {
      // Handle parsing errors gracefully
    }
    
    return dateKey;
  }

  String _getTimeUnit() {
    switch (timeRange) {
      case 'week':
        return 'day';
      case 'month':
        return 'day';
      case 'quarter':
        return 'week';
      case 'year':
        return 'month';
      default:
        return 'period';
    }
  }
}