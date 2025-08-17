import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';

class MentalHealthMonitor extends StatefulWidget {
  final Pet pet;

  const MentalHealthMonitor({super.key, required this.pet});

  @override
  State<MentalHealthMonitor> createState() => _MentalHealthMonitorState();
}

class _MentalHealthMonitorState extends State<MentalHealthMonitor> {
  List<Map<String, dynamic>> _moodEntries = [];
  List<Map<String, dynamic>> _behavioralNotes = [];
  bool _isAddingEntry = false;

  @override
  void initState() {
    super.initState();
    _loadMentalHealthData();
  }

  void _loadMentalHealthData() {
    // Mock data - in real app, this would come from database
    _moodEntries = [
      {
        'id': '1',
        'mood': 'Happy',
        'energyLevel': 'High',
        'stressLevel': 'Low',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'notes': '${widget.pet.name} was very playful and responsive today',
        'activities': ['Playtime', 'Training', 'Social interaction'],
      },
      {
        'id': '2',
        'mood': 'Calm',
        'energyLevel': 'Medium',
        'stressLevel': 'Low',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'notes': 'Relaxed behavior, good appetite, normal sleep patterns',
        'activities': ['Rest', 'Gentle walks', 'Quiet time'],
      },
    ];

    _behavioralNotes = [
      {
        'id': '1',
        'behavior': 'Separation Anxiety',
        'severity': 'Mild',
        'triggers': ['Owner leaving', 'Loud noises'],
        'copingStrategies': ['Calming music', 'Comfort toys', 'Gradual desensitization'],
        'lastObserved': DateTime.now().subtract(const Duration(days: 3)),
        'isImproving': true,
      },
      {
        'id': '2',
        'behavior': 'Aggression towards other dogs',
        'severity': 'Moderate',
        'triggers': ['Territorial situations', 'Resource guarding'],
        'copingStrategies': ['Professional training', 'Positive reinforcement', 'Controlled socialization'],
        'lastObserved': DateTime.now().subtract(const Duration(days: 5)),
        'isImproving': false,
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
          _buildMentalHealthSummary(),
          const SizedBox(height: 24),
          _buildMoodTracker(),
          const SizedBox(height: 24),
          _buildBehavioralMonitoring(),
          const SizedBox(height: 24),
          _buildAddMentalHealthEntry(),
        ],
      ),
    );
  }

  Widget _buildMentalHealthSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mental Health Overview',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Current Mood', 'Happy', Icons.sentiment_satisfied, Colors.green),
                _buildSummaryItem('Energy Level', 'High', Icons.trending_up, Colors.blue),
                _buildSummaryItem('Stress Level', 'Low', Icons.psychology, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
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

  Widget _buildMoodTracker() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Tracking',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._moodEntries.map((entry) => _buildMoodEntry(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEntry(Map<String, dynamic> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getMoodIcon(entry['mood']),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['mood'],
                      style: AppTheme.textStyles.titleSmall?.copyWith(
                        color: AppTheme.colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${entry['energyLevel']} Energy • ${entry['stressLevel']} Stress',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
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
          if (entry['notes'] != null) ...[
            const SizedBox(height: 8),
            Text(
              entry['notes'],
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
          if (entry['activities'] != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: entry['activities'].map<Widget>((activity) => 
                Chip(
                  label: Text(
                    activity,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getMoodIcon(String mood) {
    IconData iconData;
    Color color;
    
    switch (mood.toLowerCase()) {
      case 'happy':
        iconData = Icons.sentiment_satisfied;
        color = Colors.green;
        break;
      case 'calm':
        iconData = Icons.sentiment_neutral;
        color = Colors.blue;
        break;
      case 'anxious':
        iconData = Icons.sentiment_dissatisfied;
        color = Colors.orange;
        break;
      case 'stressed':
        iconData = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
      default:
        iconData = Icons.sentiment_neutral;
        color = Colors.grey;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildBehavioralMonitoring() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavioral Monitoring',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._behavioralNotes.map((note) => _buildBehavioralNote(note)),
          ],
        ),
      ),
    );
  }

  Widget _buildBehavioralNote(Map<String, dynamic> note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getSeverityColor(note['severity']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.psychology,
                  color: _getSeverityColor(note['severity']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['behavior'],
                      style: AppTheme.textStyles.titleSmall?.copyWith(
                        color: AppTheme.colors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(note['severity']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            note['severity'],
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: _getSeverityColor(note['severity']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          note['isImproving'] ? Icons.trending_up : Icons.trending_down,
                          color: note['isImproving'] ? Colors.green : Colors.red,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (note['triggers'] != null) ...[
            Text(
              'Triggers:',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: note['triggers'].map<Widget>((trigger) => 
                Chip(
                  label: Text(
                    trigger,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.error,
                    ),
                  ),
                  backgroundColor: AppTheme.colors.error.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ).toList(),
            ),
          ],
          const SizedBox(height: 8),
          if (note['copingStrategies'] != null) ...[
            Text(
              'Coping Strategies:',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: note['copingStrategies'].map<Widget>((strategy) => 
                Chip(
                  label: Text(
                    strategy,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.success,
                    ),
                  ),
                  backgroundColor: AppTheme.colors.success.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAddMentalHealthEntry() {
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
                  'Add Mental Health Entry',
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
              _buildMentalHealthForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMentalHealthForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Mood',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: ['Happy', 'Calm', 'Anxious', 'Stressed', 'Excited', 'Sad']
              .map((mood) => DropdownMenuItem(value: mood, child: Text(mood)))
              .toList(),
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Energy Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Low', 'Medium', 'High']
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Stress Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Low', 'Medium', 'High']
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) {},
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
              // Add mental health entry logic
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}