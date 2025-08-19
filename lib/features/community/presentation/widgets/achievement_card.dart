import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/social_models.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: achievement.isUnlocked 
              ? AppTheme.colors.success.withOpacity(0.1)
              : AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: achievement.isUnlocked 
                ? AppTheme.colors.success
                : AppTheme.colors.outline,
            width: achievement.isUnlocked ? 2 : 1,
          ),
          boxShadow: achievement.isUnlocked ? [
            BoxShadow(
              color: AppTheme.colors.success.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Achievement Icon and Status
              Row(
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked 
                          ? AppTheme.colors.success
                          : AppTheme.colors.outline,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: achievement.isUnlocked
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : Icon(
                            _getAchievementIcon(achievement.type),
                            color: AppTheme.colors.textSecondary,
                            size: 24,
                          ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Status and Points
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Achievement Title
                        Text(
                          achievement.title,
                          style: AppTheme.textStyles.titleMedium?.copyWith(
                            color: AppTheme.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Points Reward
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppTheme.colors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${achievement.pointsReward} points',
                              style: AppTheme.textStyles.bodySmall?.copyWith(
                                color: AppTheme.colors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Unlock Status
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'UNLOCKED',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                achievement.description,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Unlock Date or Progress
              if (achievement.isUnlocked)
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.colors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unlocked ${_formatDate(achievement.unlockedAt)}',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: AppTheme.colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Locked - Keep going!',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(
      begin: const Offset(0.8, 0.8),
      duration: const Duration(milliseconds: 300),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstPet:
        return Icons.pets;
      case AchievementType.photoMaster:
        return Icons.photo_camera;
      case AchievementType.healthChampion:
        return Icons.health_and_safety;
      case AchievementType.trainingGuru:
        return Icons.school;
      case AchievementType.mindfulnessMaster:
        return Icons.self_improvement;
      case AchievementType.communityHelper:
        return Icons.people;
      case AchievementType.streakKeeper:
        return Icons.local_fire_department;
      case AchievementType.milestoneReacher:
        return Icons.emoji_events;
      case AchievementType.aiExplorer:
        return Icons.psychology;
      case AchievementType.wellnessAdvocate:
        return Icons.favorite;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    if (difference < 365) return '${(difference / 30).floor()} months ago';
    return '${(difference / 365).floor()} years ago';
  }
}