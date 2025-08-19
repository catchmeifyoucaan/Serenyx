import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';

class NutritionTracker extends StatefulWidget {
  final Pet pet;

  const NutritionTracker({super.key, required this.pet});

  @override
  State<NutritionTracker> createState() => _NutritionTrackerState();
}

class _NutritionTrackerState extends State<NutritionTracker> {
  List<Map<String, dynamic>> _nutritionEntries = [];
  List<Map<String, dynamic>> _feedingSchedules = [];
  bool _isAddingEntry = false;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  void _loadNutritionData() {
    // Mock data - in real app, this would come from database
    _nutritionEntries = [
      {
        'id': '1',
        'foodName': 'Premium Dog Food',
        'quantity': 1.5,
        'unit': 'cups',
        'calories': 450,
        'protein': 22.0,
        'fat': 12.0,
        'carbs': 45.0,
        'feedingTime': DateTime.now().subtract(const Duration(hours: 2)),
        'mealType': 'Breakfast',
        'notes': '${widget.pet.name} ate well, seemed satisfied',
      },
      {
        'id': '2',
        'foodName': 'Chicken Treats',
        'quantity': 2,
        'unit': 'pieces',
        'calories': 80,
        'protein': 8.0,
        'fat': 4.0,
        'carbs': 2.0,
        'feedingTime': DateTime.now().subtract(const Duration(hours: 4)),
        'mealType': 'Snack',
        'notes': 'Training reward, good behavior',
      },
    ];

    _feedingSchedules = [
      {
        'id': '1',
        'mealType': 'Breakfast',
        'time': '7:00 AM',
        'quantity': 1.5,
        'unit': 'cups',
        'isActive': true,
      },
      {
        'id': '2',
        'mealType': 'Lunch',
        'time': '12:00 PM',
        'quantity': 1.0,
        'unit': 'cups',
        'isActive': true,
      },
      {
        'id': '3',
        'mealType': 'Dinner',
        'time': '6:00 PM',
        'quantity': 1.5,
        'unit': 'cups',
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
          _buildNutritionSummary(),
          const SizedBox(height: 24),
          _buildFeedingSchedule(),
          const SizedBox(height: 24),
          _buildAddNutritionEntry(),
          const SizedBox(height: 24),
          _buildNutritionHistory(),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final todayEntries = _nutritionEntries.where(
      (entry) => entry['feedingTime'].day == DateTime.now().day,
    ).toList();

    final totalCalories = todayEntries.fold<double>(
      0, (sum, entry) => sum + entry['calories']);
    final totalProtein = todayEntries.fold<double>(
      0, (sum, entry) => sum + entry['protein']);
    final totalFat = todayEntries.fold<double>(
      0, (sum, entry) => sum + entry['fat']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Today\'s Nutrition',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionStat(
                    'Calories',
                    '${totalCalories.toInt()}',
                    'kcal',
                    Icons.local_fire_department,
                    AppTheme.colors.warning,
                  ),
                ),
                Expanded(
                  child: _buildNutritionStat(
                    'Protein',
                    '${totalProtein.toInt()}',
                    'g',
                    Icons.fitness_center,
                    AppTheme.colors.success,
                  ),
                ),
                Expanded(
                  child: _buildNutritionStat(
                    'Fat',
                    '${totalFat.toInt()}',
                    'g',
                    Icons.water_drop,
                    AppTheme.colors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStat(String label, String value, String unit, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          '$value $unit',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeedingSchedule() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feeding Schedule',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._feedingSchedules.map((schedule) => _buildScheduleItem(schedule)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule) {
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
              Icons.schedule,
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
                  schedule['mealType'],
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                Text(
                  '${schedule['time']} • ${schedule['quantity']} ${schedule['unit']}',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: schedule['isActive'],
            onChanged: (value) {
              setState(() {
                schedule['isActive'] = value;
              });
            },
            activeColor: AppTheme.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddNutritionEntry() {
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
                  'Add Nutrition Entry',
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
              _buildNutritionForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Food Name',
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
                  labelText: 'Quantity',
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
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Meal Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
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
              // Add nutrition entry logic
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

  Widget _buildNutritionHistory() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Entries',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._nutritionEntries.map((entry) => _buildHistoryItem(entry)),
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
              Icons.restaurant,
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
                  entry['foodName'],
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                Text(
                  '${entry['quantity']} ${entry['unit']} • ${entry['calories']} cal',
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
            _formatTime(entry['feedingTime']),
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}