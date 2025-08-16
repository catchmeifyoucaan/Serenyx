import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/notification_models.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final Pet pet;
  final VoidCallback onToggle;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.pet,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeUntilReminder = reminder.scheduledTime.difference(now);
    final isOverdue = timeUntilReminder.isNegative;
    final isDueSoon = timeUntilReminder.inHours <= 2 && !isOverdue;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Overdue';
      statusIcon = Icons.warning;
    } else if (isDueSoon) {
      statusColor = AppTheme.heartPink;
      statusText = 'Due Soon';
      statusIcon = Icons.schedule;
    } else {
      statusColor = AppTheme.leafGreen;
      statusText = 'Scheduled';
      statusIcon = Icons.check_circle;
    }

    return Container(
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
        border: isOverdue || isDueSoon 
          ? Border.all(color: statusColor, width: 2)
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Show reminder details or edit dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing: ${reminder.title}'),
                backgroundColor: reminder.color,
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: reminder.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                      ),
                      child: Icon(
                        reminder.icon,
                        color: reminder.color,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: AppConstants.mdSpacing),
                    
                    // Title and Pet
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.warmGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'For ${pet.name}',
                            style: TextStyle(
                              color: AppTheme.warmGrey.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.mdSpacing),
                
                // Description
                Text(
                  reminder.description,
                  style: TextStyle(
                    color: AppTheme.warmGrey.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: AppConstants.mdSpacing),
                
                // Time and Frequency
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeInfo(
                        'Scheduled',
                        reminder.scheduledTime,
                        Icons.schedule,
                        reminder.color,
                      ),
                    ),
                    Expanded(
                      child: _buildFrequencyInfo(
                        reminder.frequency,
                        Icons.repeat,
                        AppTheme.softPurple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Time Until Due
                if (isOverdue || isDueSoon) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smSpacing,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.xsSpacing),
                        Text(
                          isOverdue 
                            ? '${timeUntilReminder.inDays.abs()} days overdue'
                            : 'Due in ${_formatTimeUntil(timeUntilReminder)}',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Actions
                Row(
                  children: [
                    // Toggle Switch
                    Row(
                      children: [
                        Text(
                          'Active',
                          style: TextStyle(
                            color: AppTheme.warmGrey.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppConstants.xsSpacing),
                        Switch(
                          value: reminder.isActive,
                          onChanged: (value) => onToggle(),
                          activeColor: reminder.color,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Action Buttons
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: Edit reminder
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Edit reminder coming soon! ✏️'),
                                backgroundColor: AppTheme.softPurple,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.edit,
                            color: AppTheme.warmGrey.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Snooze reminder
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Snooze reminder coming soon! 😴'),
                                backgroundColor: AppTheme.leafGreen,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.snooze,
                            color: AppTheme.warmGrey.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  Widget _buildTimeInfo(String label, DateTime time, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _formatTime(time),
          style: TextStyle(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          _formatDate(time),
          style: TextStyle(
            color: AppTheme.warmGrey.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyInfo(ReminderFrequency frequency, IconData icon, Color color) {
    String frequencyText;
    switch (frequency) {
      case ReminderFrequency.oneTime:
        frequencyText = 'One Time';
        break;
      case ReminderFrequency.daily:
        frequencyText = 'Daily';
        break;
      case ReminderFrequency.weekly:
        frequencyText = 'Weekly';
        break;
      case ReminderFrequency.monthly:
        frequencyText = 'Monthly';
        break;
      case ReminderFrequency.yearly:
        frequencyText = 'Yearly';
        break;
      case ReminderFrequency.custom:
        frequencyText = 'Custom';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Frequency',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          frequencyText,
          style: TextStyle(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    } else {
      return 'now';
    }
  }
}