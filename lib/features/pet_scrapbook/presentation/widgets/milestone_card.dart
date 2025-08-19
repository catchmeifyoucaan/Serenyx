import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scrapbook_models.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.colors.leafGreen.withOpacity(0.1),
                AppTheme.colors.heartPink.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.leafGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getMilestoneIcon(milestone.type),
                        color: AppTheme.colors.leafGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title,
                            style: AppTheme.textStyles.headlineSmall?.copyWith(
                              color: AppTheme.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getMilestoneTypeText(milestone.type),
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.leafGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (milestone.isCelebrated)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.heartPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  milestone.description,
                  style: AppTheme.textStyles.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(milestone.date),
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (milestone.photoUrl != null)
                      Icon(
                        Icons.photo,
                        size: 16,
                        color: AppTheme.colors.textSecondary,
                      ),
                    if (milestone.photoUrl != null) const SizedBox(width: 4),
                    if (milestone.photoUrl != null)
                      Text(
                        'Photo',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, duration: 300.ms);
  }

  IconData _getMilestoneIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.birthday:
        return Icons.cake;
      case MilestoneType.training:
        return Icons.school;
      case MilestoneType.social:
        return Icons.people;
      case MilestoneType.health:
        return Icons.favorite;
      case MilestoneType.achievement:
        return Icons.star;
    }
  }

  String _getMilestoneTypeText(MilestoneType type) {
    switch (type) {
      case MilestoneType.birthday:
        return 'Birthday';
      case MilestoneType.training:
        return 'Training';
      case MilestoneType.social:
        return 'Social';
      case MilestoneType.health:
        return 'Health';
      case MilestoneType.achievement:
        return 'Achievement';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}