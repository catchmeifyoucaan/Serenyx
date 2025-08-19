import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/social_models.dart';

class CommunityEventCard extends StatelessWidget {
  final CommunityEvent event;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onShare;

  const CommunityEventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onJoin,
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
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.colors.outline,
                ),
                child: event.imageUrl.isNotEmpty
                    ? Image.network(
                        event.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultEventImage();
                        },
                      )
                    : _buildDefaultEventImage(),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Header
                  Row(
                    children: [
                      // Event Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(event.eventType),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.eventType,
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Online/Offline Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isOnline 
                              ? AppTheme.colors.primary
                              : AppTheme.colors.textSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              event.isOnline ? Icons.wifi : Icons.location_on,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.isOnline ? 'Online' : 'Offline',
                              style: AppTheme.textStyles.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Event Title
                  Text(
                    event.title,
                    style: AppTheme.textStyles.titleLarge?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event Description
                  Text(
                    event.description,
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Event Details
                  _buildEventDetails(),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Join Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: event.isFull ? null : onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: event.isFull 
                                ? AppTheme.colors.textSecondary
                                : AppTheme.colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            event.isFull ? 'Event Full' : 'Join Event',
                            style: AppTheme.textStyles.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Share Button
                      OutlinedButton(
                        onPressed: onShare,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.colors.primary,
                          side: BorderSide(color: AppTheme.colors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  ),
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

  Widget _buildEventDetails() {
    return Column(
      children: [
        // Date and Time
        _buildDetailRow(
          Icons.schedule,
          _formatEventDate(event.startDate),
          AppTheme.colors.primary,
        ),
        
        const SizedBox(height: 8),
        
        // Location
        _buildDetailRow(
          Icons.location_on,
          event.location,
          AppTheme.colors.textSecondary,
        ),
        
        const SizedBox(height: 8),
        
        // Participants
        _buildDetailRow(
          Icons.people,
          '${event.participants.length}/${event.maxParticipants} participants',
          AppTheme.colors.textSecondary,
        ),
        
        // Tags
        if (event.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: event.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.colors.outline,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultEventImage() {
    return Container(
      color: AppTheme.colors.outline,
      child: Center(
        child: Icon(
          Icons.event,
          size: 48,
          color: AppTheme.colors.textSecondary,
        ),
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'workshop':
        return AppTheme.colors.primary;
      case 'discussion':
        return AppTheme.colors.secondary;
      case 'meetup':
        return AppTheme.colors.success;
      case 'training':
        return AppTheme.colors.warning;
      case 'social':
        return AppTheme.colors.info;
      default:
        return AppTheme.colors.primary;
    }
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today at ${_formatTime(date)}';
    if (difference == 1) return 'Tomorrow at ${_formatTime(date)}';
    if (difference < 7) return '${_formatDay(date)} at ${_formatTime(date)}';
    
    return '${_formatFullDate(date)} at ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}