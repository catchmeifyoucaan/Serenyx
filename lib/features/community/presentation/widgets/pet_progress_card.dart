import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/social_models.dart';

class PetProgressCard extends StatelessWidget {
  final PetProgress petProgress;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const PetProgressCard({
    super.key,
    required this.petProgress,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.colors.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Pet Image
            _buildHeader(),
            
            // Progress Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Info
                  _buildPetInfo(),
                  
                  const SizedBox(height: 20),
                  
                  // Health Metrics
                  _buildHealthMetrics(),
                  
                  const SizedBox(height: 20),
                  
                  // Training Progress
                  _buildTrainingProgress(),
                  
                  const SizedBox(height: 20),
                  
                  // Wellness Stats
                  _buildWellnessStats(),
                  
                  const SizedBox(height: 20),
                  
                  // Recent Milestones
                  _buildRecentMilestones(),
                  
                  const SizedBox(height: 20),
                  
                  // Achievements
                  _buildAchievements(),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(
      begin: 0.3,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Pet Image
          if (petProgress.photos.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  petProgress.photos.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultPetImage();
                  },
                ),
              ),
            )
          else
            _buildDefaultPetImage(),
          
          // Status Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: petProgress.statusColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: petProgress.statusColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                petProgress.overallStatus,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Pet Name Overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                petProgress.petName,
                style: AppTheme.textStyles.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPetImage() {
    return Container(
      color: AppTheme.colors.outline,
      child: Center(
        child: Icon(
          Icons.pets,
          size: 64,
          color: AppTheme.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPetInfo() {
    return Row(
      children: [
        // Pet Type and Breed
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${petProgress.petType} • ${petProgress.petBreed}',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              Text(
                petProgress.ageDescription,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Last Updated
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Last Updated',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            
            Text(
              _formatDate(petProgress.lastUpdated),
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Metrics',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: petProgress.healthMetrics.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.colors.outline),
              ),
              child: Column(
                children: [
                  Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    entry.value.toString(),
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrainingProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Progress',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Column(
          children: petProgress.trainingProgress.entries.map((entry) {
            final progress = _getProgressValue(entry.value.toString());
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      Text(
                        entry.value.toString(),
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: _getProgressColor(entry.value.toString()),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.colors.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(entry.value.toString()),
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWellnessStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellness Stats',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildWellnessStat(
                'Exercise',
                petProgress.wellnessStats['daily_exercise'] ?? 'N/A',
                Icons.directions_run,
                AppTheme.colors.primary,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildWellnessStat(
                'Mental Stimulation',
                petProgress.wellnessStats['mental_stimulation'] ?? 'N/A',
                Icons.psychology,
                AppTheme.colors.secondary,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildWellnessStat(
                'Sleep Quality',
                petProgress.wellnessStats['sleep_quality'] ?? 'N/A',
                Icons.bedtime,
                AppTheme.colors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWellnessStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            label,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMilestones() {
    if (petProgress.recentMilestones.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Milestones',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.success.withOpacity(0.3)),
          ),
          child: Column(
            children: petProgress.recentMilestones.map((milestone) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.colors.success,
                      size: 16,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Expanded(
                      child: Text(
                        milestone,
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    if (petProgress.petAchievements.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: petProgress.petAchievements.map((achievement) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.colors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.colors.warning.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppTheme.colors.warning,
                    size: 16,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Text(
                    achievement.title,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // View Details Button
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: AppTheme.colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'View Details',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Share Button
        OutlinedButton(
          onPressed: onShare,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.colors.primary,
            side: BorderSide(color: AppTheme.colors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share, size: 18),
              const SizedBox(width: 8),
              Text('Share'),
            ],
          ),
        ),
      ],
    );
  }

  double _getProgressValue(String progress) {
    switch (progress.toLowerCase()) {
      case 'complete':
      case 'mastered':
      case 'excellent':
        return 1.0;
      case 'good':
      case 'advanced':
        return 0.8;
      case 'fair':
      case 'intermediate':
        return 0.6;
      case 'poor':
      case 'beginner':
        return 0.4;
      case 'not started':
        return 0.0;
      default:
        return 0.5;
    }
  }

  Color _getProgressColor(String progress) {
    switch (progress.toLowerCase()) {
      case 'complete':
      case 'mastered':
      case 'excellent':
        return AppTheme.colors.success;
      case 'good':
      case 'advanced':
        return AppTheme.colors.primary;
      case 'fair':
      case 'intermediate':
        return AppTheme.colors.warning;
      case 'poor':
      case 'beginner':
        return AppTheme.colors.error;
      case 'not started':
        return AppTheme.colors.textSecondary;
      default:
        return AppTheme.colors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}