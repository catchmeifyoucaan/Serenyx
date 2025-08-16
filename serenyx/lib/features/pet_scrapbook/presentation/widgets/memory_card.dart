import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scrapbook_models.dart';

class MemoryCard extends StatelessWidget {
  final MemoryEntry memory;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.memory,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppTheme.colors.heartPink,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      memory.title,
                      style: AppTheme.textStyles.headlineSmall?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.leafGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      memory.mood,
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.leafGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                memory.description,
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
                      _formatDate(memory.date),
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  const Spacer(),
                  if (memory.photoUrl != null)
                    Icon(
                      Icons.photo,
                      size: 16,
                      color: AppTheme.colors.textSecondary,
                    ),
                  if (memory.photoUrl != null) const SizedBox(width: 4),
                  if (memory.photoUrl != null)
                    Text(
                      'Photo',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                ],
              ),
              if (memory.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: memory.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.softPink.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
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