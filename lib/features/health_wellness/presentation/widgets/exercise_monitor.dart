import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';

class ExerciseMonitor extends StatefulWidget {
  final Pet pet;

  const ExerciseMonitor({super.key, required this.pet});

  @override
  State<ExerciseMonitor> createState() => _ExerciseMonitorState();
}

class _ExerciseMonitorState extends State<ExerciseMonitor> {
  List<Map<String, dynamic>> _exerciseEntries = [];
  List<Map<String, dynamic>> _exerciseGoals = [];
  bool _isAddingEntry = false;

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  void _loadExerciseData() {
    // Mock data - in real app, this would come from database
    _exerciseEntries = [
      {
        'id': '1',
        'activityType': 'Walking',
        'duration': 30,
        'distance': 2.5,
        'caloriesBurned': 120,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'notes': '${widget.pet.name} enjoyed the walk, good energy',
      },
      {
        'id': '2',
        'activityType': 'Playtime',
        'duration': 45,
        'distance': 0,
        'caloriesBurned': 80,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'notes': 'Fetch and tug-of-war, very active',
      },
    ];

    _exerciseGoals = [
      {
        'id': '1',
        'activityType': 'Daily Walks',
        'targetDuration': 30,
        'targetDistance': 2.0,
        'frequency': 'Daily',
        'isActive': true,
      },
      {
        'id': '2',
        'activityType': 'Play Sessions',
        'targetDuration': 60,
        'targetDistance': 0,
        'frequency': 'Daily',
        'isActive': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseSummary(),
          const SizedBox(height: 24),
          _buildExerciseGoals(),
          const SizedBox(height: 24),
          _buildAddExerciseEntry(),
          const SizedBox(height: 24),
          _buildExerciseHistory(),
        ],
      ),
    );
  }

  Widget _buildExerciseSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise Summary',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Today', '45 min', Icons.timer),
                _buildSummaryItem('This Week', '4.5 hrs', Icons.calendar_today),
                _buildSummaryItem('Calories', '680', Icons.local_fire_department),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.colors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseGoals() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise Goals',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._exerciseGoals.map((goal) => _buildGoalItem(goal)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            color: AppTheme.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal['activityType'],
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                Text(
                  '${goal['targetDuration']} min ${goal['frequency']}',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: goal['isActive'],
            onChanged: (value) {
              setState(() {
                goal['isActive'] = value;
              });
            },
            activeColor: AppTheme.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseEntry() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Exercise Entry',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingEntry = !_isAddingEntry;
                    });
                  },
                  icon: Icon(
                    _isAddingEntry ? Icons.remove : Icons.add,
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
            if (_isAddingEntry) ...[
              const SizedBox(height: 16),
              _buildExerciseForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Activity Type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Duration (min)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Distance (km)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Add exercise entry logic
              setState(() {
                _isAddingEntry = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: AppTheme.colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save Entry'),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseHistory() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Exercise',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._exerciseEntries.map((entry) => _buildHistoryItem(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppTheme.colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['activityType'],
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                Text(
                  '${entry['duration']} min • ${entry['caloriesBurned']} cal',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                if (entry['notes'] != null)
                  Text(
                    entry['notes'],
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            _formatDate(entry['date']),
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}