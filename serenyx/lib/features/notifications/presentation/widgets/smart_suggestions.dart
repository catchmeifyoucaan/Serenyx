import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/notification_models.dart';

class SmartSuggestionCard extends StatelessWidget {
  final SmartSuggestion suggestion;

  const SmartSuggestionCard({
    super.key,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(
          color: suggestion.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Show suggestion details or take action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing: ${suggestion.title}'),
                backgroundColor: suggestion.color,
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Priority
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: suggestion.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                      ),
                      child: Icon(
                        suggestion.icon,
                        color: suggestion.color,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: AppConstants.mdSpacing),
                    
                    // Title
                    Expanded(
                      child: Text(
                        suggestion.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(suggestion.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        border: Border.all(
                          color: _getPriorityColor(suggestion.priority).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPriorityIcon(suggestion.priority),
                            color: _getPriorityColor(suggestion.priority),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPriorityText(suggestion.priority),
                            style: TextStyle(
                              color: _getPriorityColor(suggestion.priority),
                              fontSize: 10,
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
                  suggestion.description,
                  style: TextStyle(
                    color: AppTheme.warmGrey.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: AppConstants.mdSpacing),
                
                // Type and Actions
                Row(
                  children: [
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: suggestion.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        border: Border.all(color: suggestion.color.withOpacity(0.2)),
                      ),
                      child: Text(
                        _getTypeText(suggestion.type),
                        style: TextStyle(
                          color: suggestion.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action Buttons
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Implement "Learn More" action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Learn More feature coming soon! 📚'),
                                backgroundColor: AppTheme.softPurple,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.info_outline,
                            color: suggestion.color,
                            size: 16,
                          ),
                          label: Text(
                            'Learn More',
                            style: TextStyle(
                              color: suggestion.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),
                        const SizedBox(width: AppConstants.xsSpacing),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement "Take Action" functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Action feature coming soon! 🚀'),
                                backgroundColor: suggestion.color,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            'Take Action',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: suggestion.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
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

  Color _getPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return AppTheme.leafGreen;
      case SuggestionPriority.medium:
        return AppTheme.heartPink;
      case SuggestionPriority.high:
        return Colors.orange;
      case SuggestionPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return Icons.low_priority;
      case SuggestionPriority.medium:
        return Icons.priority_high;
      case SuggestionPriority.high:
        return Icons.warning;
      case SuggestionPriority.urgent:
        return Icons.error;
    }
  }

  String _getPriorityText(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return 'Low';
      case SuggestionPriority.medium:
        return 'Medium';
      case SuggestionPriority.high:
        return 'High';
      case SuggestionPriority.urgent:
        return 'Urgent';
    }
  }

  String _getTypeText(SuggestionType type) {
    switch (type) {
      case SuggestionType.timing:
        return 'Timing';
      case SuggestionType.health:
        return 'Health';
      case SuggestionType.behavior:
        return 'Behavior';
      case SuggestionType.training:
        return 'Training';
      case SuggestionType.social:
        return 'Social';
      case SuggestionType.bonding:
        return 'Bonding';
      case SuggestionType.care:
        return 'Care';
    }
  }
}

class NotificationSettingsCard extends StatelessWidget {
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;

  const NotificationSettingsCard({
    super.key,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      decoration: BoxDecoration(
        color: AppTheme.gentleCream,
        borderRadius: BorderRadius.circular(AppConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          
          // General Settings
          _buildSettingItem(
            'Push Notifications',
            'Receive notifications on your device',
            Icons.notifications,
            AppTheme.heartPink,
            Switch(
              value: notificationsEnabled,
              onChanged: (value) => onToggleNotifications(),
              activeColor: AppTheme.leafGreen,
            ),
          ),
          
          _buildSettingItem(
            'Bonding Reminders',
            'Daily reminders for pet bonding sessions',
            Icons.favorite,
            AppTheme.heartPink,
            Switch(
              value: notificationsEnabled,
              onChanged: (value) => onToggleNotifications(),
              activeColor: AppTheme.leafGreen,
            ),
          ),
          
          _buildSettingItem(
            'Health Alerts',
            'Vaccination and health check reminders',
            Icons.health_and_safety,
            AppTheme.leafGreen,
            Switch(
              value: notificationsEnabled,
              onChanged: (value) => onToggleNotifications(),
              activeColor: AppTheme.leafGreen,
            ),
          ),
          
          _buildSettingItem(
            'Medication Reminders',
            'Reminders for pet medications',
            Icons.medication,
            AppTheme.softPurple,
            Switch(
              value: notificationsEnabled,
              onChanged: (value) => onToggleNotifications(),
              activeColor: AppTheme.softPurple,
            ),
          ),
          
          _buildSettingItem(
            'Smart Suggestions',
            'AI-powered pet care recommendations',
            Icons.lightbulb,
            AppTheme.lightPink,
            Switch(
              value: notificationsEnabled,
              onChanged: (value) => onToggleNotifications(),
              activeColor: AppTheme.lightPink,
            ),
          ),
          
          const SizedBox(height: AppConstants.mdSpacing),
          
          // Advanced Settings Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to advanced settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Advanced settings coming soon! ⚙️'),
                    backgroundColor: AppTheme.softPurple,
                  ),
                );
              },
              icon: Icon(Icons.settings, color: AppTheme.softPurple),
              label: Text(
                'Advanced Settings',
                style: TextStyle(color: AppTheme.softPurple),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.softPurple),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String description,
    IconData icon,
    Color color,
    Widget control,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.smRadius),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon
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
          
          const SizedBox(width: AppConstants.mdSpacing),
          
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Control
          control,
        ],
      ),
    );
  }
}