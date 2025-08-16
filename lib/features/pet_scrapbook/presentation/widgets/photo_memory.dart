import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scrapbook_models.dart';

class PhotoMemoryWidget extends StatelessWidget {
  final PhotoMemory photoMemory;
  final VoidCallback onTap;

  const PhotoMemoryWidget({
    super.key,
    required this.photoMemory,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.colors.softPink.withOpacity(0.3),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.photo,
                          size: 48,
                          color: AppTheme.colors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            photoMemory.location,
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photoMemory.title,
                    style: AppTheme.textStyles.headlineSmall?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (photoMemory.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      photoMemory.description!,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                                              Text(
                          _formatDate(photoMemory.date),
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                                              Text(
                          photoMemory.location,
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (photoMemory.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: photoMemory.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.colors.heartPink.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.heartPink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, duration: 300.ms);
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