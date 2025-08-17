import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/ai_models.dart';
import 'package:intl/intl.dart';

class SmartSchedulingWidget extends StatefulWidget {
  final Pet pet;

  const SmartSchedulingWidget({super.key, required this.pet});

  @override
  State<SmartSchedulingWidget> createState() => _SmartSchedulingWidgetState();
}

class _SmartSchedulingWidgetState extends State<SmartSchedulingWidget> {
  final List<ScheduleRecommendation> _recommendations = [];
  final List<OptimizedSchedule> _schedules = [];
  bool _isOptimizing = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSchedulingData();
  }

  void _loadSchedulingData() {
    // Load real scheduling data from storage/database
    // For now, we'll start with empty lists for a clean slate
  }

  Future<void> _optimizeSchedule() async {
    setState(() {
      _isOptimizing = true;
    });

    try {
      // Simulate AI optimization (replace with actual AI service call)
      await Future.delayed(const Duration(seconds: 3));
      
      final recommendation = ScheduleRecommendation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        type: _generateRecommendationType(),
        title: _generateRecommendationTitle(),
        description: _generateRecommendationDescription(),
        priority: _generatePriority(),
        impact: _generateImpact(),
        timestamp: DateTime.now(),
        actions: _generateActions(),
        estimatedTime: _generateEstimatedTime(),
      );

      final schedule = OptimizedSchedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        date: _selectedDate,
        activities: _generateOptimizedActivities(),
        totalDuration: _generateTotalDuration(),
        efficiency: _generateEfficiency(),
        createdAt: DateTime.now(),
      );

      setState(() {
        _recommendations.insert(0, recommendation);
        _schedules.insert(0, schedule);
        _isOptimizing = false;
      });

      _showOptimizationResults(recommendation, schedule);
    } catch (e) {
      setState(() {
        _isOptimizing = false;
      });
      _showError('Schedule optimization failed. Please try again.');
    }
  }

  RecommendationType _generateRecommendationType() {
    final types = [RecommendationType.timing, RecommendationType.activity, RecommendationType.routine];
    return types[DateTime.now().millisecond % types.length];
  }

  String _generateRecommendationTitle() {
    final titles = [
      'Optimize Feeding Schedule',
      'Improve Exercise Timing',
      'Better Sleep Routine',
      'Enhanced Training Sessions',
      'Optimal Social Time',
      'Efficient Grooming Schedule'
    ];
    return titles[DateTime.now().millisecond % titles.length];
  }

  String _generateRecommendationDescription() {
    final descriptions = [
      'Based on your pet\'s natural rhythms, adjusting feeding times by 30 minutes could improve digestion and energy levels.',
      'Moving exercise sessions to early morning and late afternoon aligns with your pet\'s peak activity periods.',
      'Creating a consistent bedtime routine with calming activities can improve sleep quality and reduce anxiety.',
      'Shorter, more frequent training sessions during peak alertness periods can improve learning retention.',
      'Scheduling social interactions during your pet\'s most sociable hours can enhance bonding and reduce stress.',
      'Breaking grooming into smaller sessions throughout the week can make it less overwhelming for your pet.'
    ];
    return descriptions[DateTime.now().millisecond % descriptions.length];
  }

  Priority _generatePriority() {
    final priorities = [Priority.low, Priority.medium, Priority.high];
    return priorities[DateTime.now().millisecond % priorities.length];
  }

  String _generateImpact() {
    final impacts = [
      'High - Could improve health and behavior significantly',
      'Medium - May enhance daily routine and pet satisfaction',
      'Low - Minor improvements to overall well-being'
    ];
    return impacts[DateTime.now().millisecond % impacts.length];
  }

  List<String> _generateActions() {
    final actions = [
      'Adjust feeding times gradually over 3-5 days',
      'Monitor energy levels and appetite changes',
      'Keep a log of any behavioral improvements',
      'Consult with vet if significant changes occur',
      'Maintain consistency for at least 2 weeks',
      'Track progress and adjust as needed'
    ];
    return actions.take(3).toList();
  }

  int _generateEstimatedTime() {
    return 15 + (DateTime.now().millisecond % 45);
  }

  List<ScheduleActivity> _generateOptimizedActivities() {
    final activities = [
      ScheduleActivity(
        id: '1',
        name: 'Morning Exercise',
        startTime: '07:00',
        duration: 30,
        type: ActivityType.exercise,
        priority: ActivityPriority.high,
      ),
      ScheduleActivity(
        id: '2',
        name: 'Breakfast',
        startTime: '08:00',
        duration: 15,
        type: ActivityType.feeding,
        priority: ActivityPriority.high,
      ),
      ScheduleActivity(
        id: '3',
        name: 'Training Session',
        startTime: '09:30',
        duration: 20,
        type: ActivityType.training,
        priority: ActivityPriority.medium,
      ),
      ScheduleActivity(
        id: '4',
        name: 'Rest Period',
        startTime: '10:00',
        duration: 60,
        type: ActivityType.rest,
        priority: ActivityPriority.low,
      ),
      ScheduleActivity(
        id: '5',
        name: 'Lunch',
        startTime: '12:00',
        duration: 15,
        type: ActivityType.feeding,
        priority: ActivityPriority.high,
      ),
      ScheduleActivity(
        id: '6',
        name: 'Afternoon Play',
        startTime: '15:00',
        duration: 45,
        type: ActivityType.exercise,
        priority: ActivityPriority.medium,
      ),
      ScheduleActivity(
        id: '7',
        name: 'Dinner',
        startTime: '18:00',
        duration: 15,
        type: ActivityType.feeding,
        priority: ActivityPriority.high,
      ),
      ScheduleActivity(
        id: '8',
        name: 'Evening Walk',
        startTime: '19:30',
        duration: 30,
        type: ActivityType.exercise,
        priority: ActivityPriority.medium,
      ),
      ScheduleActivity(
        id: '9',
        name: 'Bedtime Routine',
        startTime: '21:00',
        duration: 20,
        type: ActivityType.grooming,
        priority: ActivityPriority.low,
      ),
    ];
    return activities;
  }

  int _generateTotalDuration() {
    return 240; // 4 hours of active time
  }

  double _generateEfficiency() {
    return 0.85 + (DateTime.now().millisecond % 15) / 100;
  }

  void _showOptimizationResults(ScheduleRecommendation recommendation, OptimizedSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Optimized!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recommendation: ${recommendation.title}'),
              const SizedBox(height: 8),
              Text('Impact: ${recommendation.impact}'),
              Text('Estimated Time: ${recommendation.estimatedTime} minutes'),
              const SizedBox(height: 16),
              Text('New Schedule Created:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${schedule.activities.length} activities'),
              Text('Total Duration: ${schedule.totalDuration} minutes'),
              Text('Efficiency: ${(schedule.efficiency * 100).toInt()}%'),
              const SizedBox(height: 16),
              Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recommendation.actions.map((action) => 
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• $action', style: TextStyle(fontSize: 12)),
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppTheme.colors.success;
      case Priority.medium:
        return AppTheme.colors.warning;
      case Priority.high:
        return AppTheme.colors.error;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  Color _getActivityTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.feeding:
        return AppTheme.colors.primary;
      case ActivityType.exercise:
        return AppTheme.colors.success;
      case ActivityType.training:
        return AppTheme.colors.warning;
      case ActivityType.grooming:
        return AppTheme.colors.secondary;
      case ActivityType.rest:
        return AppTheme.colors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildOptimizationSection(),
          const SizedBox(height: 24),
          _buildRecommendationsSection(),
          const SizedBox(height: 24),
          _buildSchedulesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Smart Scheduling',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI-powered schedule optimization to maximize your pet\'s health, happiness, and learning potential.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Optimize Daily Schedule',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get AI-powered recommendations to create the perfect daily routine for your pet.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Date selector
            ListTile(
              title: Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                style: AppTheme.textStyles.bodyMedium,
              ),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isOptimizing ? null : _optimizeSchedule,
                icon: _isOptimizing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.colors.onPrimary,
                          ),
                        ),
                      )
                    : Icon(Icons.auto_awesome),
                label: Text(_isOptimizing ? 'Optimizing...' : 'Optimize Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: AppTheme.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_recommendations.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.lightbulb,
                size: 64,
                color: AppTheme.colors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Recommendations Yet',
                style: AppTheme.textStyles.headlineSmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start optimizing your schedule to get AI-powered recommendations.',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendations',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._recommendations.map((recommendation) => _buildRecommendationCard(recommendation)),
      ],
    );
  }

  Widget _buildRecommendationCard(ScheduleRecommendation recommendation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(recommendation.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(recommendation.priority),
                    style: TextStyle(
                      color: _getPriorityColor(recommendation.priority),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${recommendation.estimatedTime}m',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.title,
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.description,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Impact: ${recommendation.impact}',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Actions:',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.actions.map((action) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.colors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildSchedulesSection() {
    if (_schedules.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimized Schedules',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._schedules.map((schedule) => _buildScheduleCard(schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(OptimizedSchedule schedule) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(schedule.date),
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${schedule.activities.length} activities • ${(schedule.efficiency * 100).toInt()}% efficient',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${schedule.totalDuration}m',
                    style: TextStyle(
                      color: AppTheme.colors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...schedule.activities.map((activity) => _buildActivityRow(activity)),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildActivityRow(ScheduleActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getActivityTypeColor(activity.type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity.name,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
          ),
          Text(
            '${activity.startTime} (${activity.duration}m)',
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
