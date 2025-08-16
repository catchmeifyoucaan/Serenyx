import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/scrapbook_models.dart';
import 'memory_card.dart';
import 'milestone_card.dart';
import 'photo_memory.dart';

class TimelineWidget extends StatelessWidget {
  final List<dynamic> content;
  final Function(MemoryEntry) onMemoryTap;
  final Function(Milestone) onMilestoneTap;
  final Function(PhotoMemory) onPhotoTap;

  const TimelineWidget({
    super.key,
    required this.content,
    required this.onMemoryTap,
    required this.onMilestoneTap,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group content by month
    final groupedContent = _groupContentByMonth(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.lgSpacing),
        
        ...groupedContent.entries.map((entry) => 
          _buildMonthSection(entry.key, entry.value, context)
        ).toList(),
      ],
    );
  }

  Map<String, List<dynamic>> _groupContentByMonth(List<dynamic> content) {
    final Map<String, List<dynamic>> grouped = {};
    
    for (final item in content) {
      final date = item.date;
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(item);
    }
    
    // Sort months in descending order (newest first)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    final sortedGrouped = <String, List<dynamic>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  Widget _buildMonthSection(String monthKey, List<dynamic> monthContent, BuildContext context) {
    final date = DateTime.parse('$monthKey-01');
    final monthName = _getMonthName(date.month);
    final year = date.year;
    
    // Sort content within month by date (newest first)
    monthContent.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.xlSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mdSpacing,
              vertical: AppConstants.smSpacing,
            ),
            decoration: BoxDecoration(
              color: AppTheme.heartPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
              border: Border.all(color: AppTheme.heartPink.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.heartPink,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smSpacing),
                Text(
                  '$monthName $year',
                  style: TextStyle(
                    color: AppTheme.heartPink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${monthContent.length} items',
                  style: TextStyle(
                    color: AppTheme.heartPink.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.mdSpacing),
          
          // Timeline Items
          ...monthContent.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == monthContent.length - 1;
            
            return _buildTimelineItem(item, isLast, context);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(dynamic item, bool isLast, BuildContext context) {
    if (item is MemoryEntry) {
      return _buildMemoryTimelineItem(item, isLast, context);
    } else if (item is Milestone) {
      return _buildMilestoneTimelineItem(item, isLast, context);
    } else if (item is PhotoMemory) {
      return _buildPhotoTimelineItem(item, isLast, context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildMemoryTimelineItem(MemoryEntry memory, bool isLast, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line and Dot
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.softPurple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.softPurple.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: AppTheme.softPurple.withOpacity(0.3),
              ),
          ],
        ),
        
        const SizedBox(width: AppConstants.mdSpacing),
        
        // Memory Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onMemoryTap(memory),
                borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: AppTheme.softPurple,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.smSpacing),
                        Expanded(
                          child: Text(
                            memory.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.warmGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.softPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppConstants.smRadius),
                          ),
                          child: Text(
                            memory.mood,
                            style: TextStyle(
                              color: AppTheme.softPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.smSpacing),
                    
                    // Description
                    Text(
                      memory.description,
                      style: TextStyle(
                        color: AppTheme.warmGrey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.smSpacing),
                    
                    // Date and Tags
                    Row(
                      children: [
                        Text(
                          _formatDate(memory.date),
                          style: TextStyle(
                            color: AppTheme.warmGrey.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        ...memory.tags.take(3).map((tag) => 
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.softPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.smRadius),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppTheme.softPurple,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  Widget _buildMilestoneTimelineItem(Milestone milestone, bool isLast, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line and Dot
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: milestone.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: milestone.color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: milestone.color.withOpacity(0.3),
              ),
          ],
        ),
        
        const SizedBox(width: AppConstants.mdSpacing),
        
        // Milestone Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onMilestoneTap(milestone),
                borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          milestone.icon,
                          color: milestone.color,
                          size: 24,
                        ),
                        const SizedBox(width: AppConstants.smSpacing),
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.warmGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: milestone.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppConstants.smRadius),
                          ),
                          child: Text(
                            'Milestone',
                            style: TextStyle(
                              color: milestone.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.smSpacing),
                    
                    // Description
                    Text(
                      milestone.description,
                      style: TextStyle(
                        color: AppTheme.warmGrey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.smSpacing),
                    
                    // Date
                    Text(
                      _formatDate(milestone.date),
                      style: TextStyle(
                        color: milestone.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  Widget _buildPhotoTimelineItem(PhotoMemory photo, bool isLast, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line and Dot
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.leafGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.leafGreen.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: AppTheme.leafGreen.withOpacity(0.3),
              ),
          ],
        ),
        
        const SizedBox(width: AppConstants.mdSpacing),
        
        // Photo Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onPhotoTap(photo),
                borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.mdRadius),
                        topRight: Radius.circular(AppConstants.mdRadius),
                      ),
                      child: Image.network(
                        photo.photoUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // Photo Info
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.mdSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: AppTheme.leafGreen,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.smSpacing),
                              Expanded(
                                child: Text(
                                  photo.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.warmGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.leafGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppConstants.smRadius),
                                ),
                                child: Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: AppTheme.leafGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppConstants.smSpacing),
                          
                          // Description
                          if (photo.description != null)
                            Text(
                              photo.description!,
                              style: TextStyle(
                                color: AppTheme.warmGrey.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          
                          const SizedBox(height: AppConstants.smSpacing),
                          
                          // Date and Tags
                          Row(
                            children: [
                              Text(
                                _formatDate(photo.date),
                                style: TextStyle(
                                  color: AppTheme.warmGrey.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              ...photo.tags.take(2).map((tag) => 
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.leafGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppConstants.smRadius),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: AppTheme.leafGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}