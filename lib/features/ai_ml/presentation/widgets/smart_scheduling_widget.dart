+import 'package:flutter/material.dart';
+import 'package:flutter_animate/flutter_animate.dart';
+import '../../../../core/theme/app_theme.dart';
+import '../../../../shared/models/pet.dart';
+import '../../../../shared/models/ai_models.dart';
+
+class SmartSchedulingWidget extends StatefulWidget {
+  final Pet pet;
+
+  const SmartSchedulingWidget({super.key, required this.pet});
+
+  @override
+  State<SmartSchedulingWidget> createState() => _SmartSchedulingWidgetState();
+}
+
+class _SmartSchedulingWidgetState extends State<SmartSchedulingWidget> {
+  List<SmartSchedule> _schedules = [];
+  List<SmartSchedule> _upcomingSchedules = [];
+  bool _isOptimizing = false;
+
+  @override
+  void initState() {
+    super.initState();
+    _loadSchedules();
+    _loadUpcomingSchedules();
+  }
+
+  void _loadSchedules() {
+    // Mock data - in real app, this would come from AI service
+    _schedules = [
+      SmartSchedule(
+        id: '1',
+        title: 'Feeding Time',
+        description: 'Optimal feeding schedule based on ${widget.pet.name}\'s metabolism and activity patterns',
+        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
+        category: 'Nutrition',
+        priority: 0.9,
+        isRecurring: true,
+        recurrencePattern: 'Daily',
+        tags: ['feeding', 'nutrition', 'schedule'],
+      ),
+      SmartSchedule(
+        id: '2',
+        title: 'Exercise Session',
+        description: 'Best time for physical activity when ${widget.pet.name} has highest energy levels',
+        scheduledTime: DateTime.now().add(const Duration(hours: 4)),
+        category: 'Activity',
+        priority: 0.8,
+        isRecurring: true,
+        recurrencePattern: 'Daily',
+        tags: ['exercise', 'energy', 'activity'],
+      ),
+      SmartSchedule(
+        id: '3',
+        title: 'Training Session',
+        description: 'Optimal learning window when ${widget.pet.name} is most receptive to new commands',
+        scheduledTime: DateTime.now().add(const Duration(hours: 6)),
+        category: 'Training',
+        priority: 0.7,
+        isRecurring: true,
+        recurrencePattern: 'Daily',
+        tags: ['training', 'learning', 'commands'],
+      ),
+      SmartSchedule(
+        id: '4',
+        title: 'Grooming Session',
+        description: 'Best time for grooming when ${widget.pet.name} is most relaxed and cooperative',
+        scheduledTime: DateTime.now().add(const Duration(hours: 8)),
+        category: 'Care',
+        priority: 0.6,
+        isRecurring: true,
+        recurrencePattern: 'Weekly',
+        tags: ['grooming', 'care', 'relaxation'],
+      ),
+      SmartSchedule(
+        id: '5',
+        title: 'Social Time',
+        description: 'Optimal time for social interaction and bonding activities',
+        scheduledTime: DateTime.now().add(const Duration(hours: 10)),
+        category: 'Social',
+        priority: 0.8,
+        isRecurring: true,
+        recurrencePattern: 'Daily',
+        tags: ['social', 'bonding', 'interaction'],
+      ),
+    ];
+  }
+
+  void _loadUpcomingSchedules() {
+    // Mock upcoming schedules
+    _upcomingSchedules = [
+      SmartSchedule(
+        id: '6',
+        title: 'Vet Checkup',
+        description: 'Annual health examination and vaccination update',
+        scheduledTime: DateTime.now().add(const Duration(days: 7)),
+        category: 'Health',
+        priority: 0.9,
+        isRecurring: false,
+        recurrencePattern: 'One-time',
+        tags: ['health', 'vet', 'checkup'],
+      ),
+      SmartSchedule(
+        id: '7',
+        title: 'Dental Cleaning',
+        description: 'Professional dental cleaning and oral health assessment',
+        scheduledTime: DateTime.now().add(const Duration(days: 14)),
+        category: 'Health',
+        priority: 0.7,
+        isRecurring: false,
+        recurrencePattern: 'One-time',
+        tags: ['dental', 'health', 'cleaning'],
+      ),
+    ];
+  }
+
+  Future<void> _optimizeSchedule() async {
+    setState(() {
+      _isOptimizing = true;
+    });
+
+    // Simulate AI optimization
+    await Future.delayed(const Duration(seconds: 3));
+
+    // Mock optimized schedule
+    final optimizedSchedule = SmartSchedule(
+      id: DateTime.now().millisecondsSinceEpoch.toString(),
+      title: 'Optimized Evening Routine',
+      description: 'AI-optimized evening schedule for maximum bonding and relaxation',
+      scheduledTime: DateTime.now().add(const Duration(hours: 12)),
+      category: 'Routine',
+      priority: 0.95,
+      isRecurring: true,
+      recurrencePattern: 'Daily',
+      tags: ['routine', 'evening', 'optimized'],
+    );
+
+    setState(() {
+      _schedules.insert(0, optimizedSchedule);
+      _isOptimizing = false;
+    });
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return SingleChildScrollView(
+      padding: const EdgeInsets.all(16.0),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          _buildScheduleSummary(),
+          const SizedBox(height: 24),
+          _buildOptimizationSection(),
+          const SizedBox(height: 24),
+          _buildDailySchedules(),
+          const SizedBox(height: 24),
+          _buildUpcomingSchedules(),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildScheduleSummary() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Row(
+              children: [
+                Icon(
+                  Icons.schedule,
+                  color: AppTheme.colors.primary,
+                  size: 28,
+                ),
+                const SizedBox(width: 12),
+                Text(
+                  'Smart Scheduling',
+                  style: AppTheme.textStyles.headlineSmall?.copyWith(
+                    color: AppTheme.colors.textPrimary,
+                  ),
+                ),
+              ],
+            ),
+            const SizedBox(height: 16),
+            Row(
+              children: [
+                Expanded(
+                  child: _buildScheduleStat(
+                    'Daily Tasks',
+                    '${_schedules.length}',
+                    Icons.today,
+                    AppTheme.colors.primary,
+                  ),
+                ),
+                Expanded(
+                  child: _buildScheduleStat(
+                    'Upcoming',
+                    '${_upcomingSchedules.length}',
+                    Icons.upcoming,
+                    AppTheme.colors.secondary,
+                  ),
+                ),
+                Expanded(
+                  child: _buildScheduleStat(
+                    'Efficiency',
+                    '92%',
+                    Icons.trending_up,
+                    AppTheme.colors.success,
+                  ),
+                ),
+              ],
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildScheduleStat(String label, String value, IconData icon, Color color) {
+    return Column(
+      children: [
+        Icon(icon, color: color, size: 32),
+        const SizedBox(height: 8),
+        Text(
+          value,
+          style: AppTheme.textStyles.titleLarge?.copyWith(
+            color: AppTheme.colors.textPrimary,
+            fontWeight: FontWeight.bold,
+          ),
+        ),
+        Text(
+          label,
+          style: AppTheme.textStyles.bodySmall?.copyWith(
+            color: AppTheme.colors.textSecondary,
+          ),
+          textAlign: TextAlign.center,
+        ),
+      ],
+    );
+  }
+
+  Widget _buildOptimizationSection() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Optimize Schedule',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 12),
+            Text(
+              'AI will analyze ${widget.pet.name}\'s patterns and optimize your daily schedule for maximum efficiency and bonding',
+              style: AppTheme.textStyles.bodyMedium?.copyWith(
+                color: AppTheme.colors.textSecondary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            SizedBox(
+              width: double.infinity,
+              child: ElevatedButton.icon(
+                onPressed: !_isOptimizing ? _optimizeSchedule : null,
+                icon: _isOptimizing
+                    ? SizedBox(
+                        width: 16,
+                        height: 16,
+                        child: CircularProgressIndicator(
+                          strokeWidth: 2,
+                          valueColor: AlwaysStoppedAnimation<Color>(
+                            Colors.white,
+                          ),
+                        ),
+                      )
+                    : const Icon(Icons.auto_awesome),
+                label: Text(_isOptimizing ? 'Optimizing...' : 'Optimize Now'),
+                style: ElevatedButton.styleFrom(
+                  backgroundColor: AppTheme.colors.warning,
+                  foregroundColor: Colors.white,
+                  padding: const EdgeInsets.symmetric(vertical: 16),
+                ),
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildDailySchedules() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Daily Schedule',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._schedules.map((schedule) => _buildScheduleCard(schedule)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildUpcomingSchedules() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Upcoming Events',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._upcomingSchedules.map((schedule) => _buildScheduleCard(schedule, isUpcoming: true)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildScheduleCard(SmartSchedule schedule, {bool isUpcoming = false}) {
+    return Container(
+      margin: const EdgeInsets.only(bottom: 16),
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        color: AppTheme.colors.surface,
+        borderRadius: BorderRadius.circular(12),
+        border: Border.all(
+          color: isUpcoming 
+              ? AppTheme.colors.warning.withOpacity(0.3)
+              : AppTheme.colors.outline,
+        ),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Row(
+            children: [
+              Container(
+                width: 40,
+                height: 40,
+                decoration: BoxDecoration(
+                  color: _getCategoryColor(schedule.category).withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(20),
+                ),
+                child: Icon(
+                  _getCategoryIcon(schedule.category),
+                  color: _getCategoryColor(schedule.category),
+                  size: 20,
+                ),
+              ),
+              const SizedBox(width: 12),
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      schedule.title,
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      schedule.category,
+                      style: AppTheme.textStyles.bodySmall?.copyWith(
+                        color: AppTheme.colors.textSecondary,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+              Container(
+                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+                decoration: BoxDecoration(
+                  color: _getPriorityColor(schedule.priority).withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(12),
+                ),
+                child: Text(
+                  _getPriorityText(schedule.priority),
+                  style: AppTheme.textStyles.bodySmall?.copyWith(
+                    color: _getPriorityColor(schedule.priority),
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+              ),
+            ],
+          ),
+          const SizedBox(height: 12),
+          Text(
+            schedule.description,
+            style: AppTheme.textStyles.bodyMedium?.copyWith(
+              color: AppTheme.colors.textSecondary,
+            ),
+          ),
+          const SizedBox(height: 8),
+          Row(
+            children: [
+              Icon(
+                Icons.access_time,
+                color: AppTheme.colors.textSecondary,
+                size: 16,
+              ),
+              const SizedBox(width: 4),
+              Text(
+                _formatScheduleTime(schedule.scheduledTime),
+                style: AppTheme.textStyles.bodySmall?.copyWith(
+                  color: AppTheme.colors.textSecondary,
+                ),
+              ),
+              const SizedBox(width: 16),
+              Icon(
+                Icons.repeat,
+                color: AppTheme.colors.textSecondary,
+                size: 16,
+              ),
+              const SizedBox(width: 4),
+              Text(
+                schedule.recurrencePattern,
+                style: AppTheme.textStyles.bodySmall?.copyWith(
+                  color: AppTheme.colors.textSecondary,
+                ),
+              ),
+            ],
+          ),
+          const SizedBox(height: 12),
+          Wrap(
+            spacing: 8,
+            runSpacing: 4,
+            children: schedule.tags.map((tag) => Container(
+              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+              decoration: BoxDecoration(
+                color: AppTheme.colors.primary.withOpacity(0.1),
+                borderRadius: BorderRadius.circular(12),
+              ),
+              child: Text(
+                tag,
+                style: AppTheme.textStyles.bodySmall?.copyWith(
+                  color: AppTheme.colors.primary,
+                  fontSize: 10,
+                ),
+              ),
+            )).toList(),
+          ),
+          const SizedBox(height: 12),
+          Row(
+            children: [
+              Expanded(
+                child: OutlinedButton.icon(
+                  onPressed: () {
+                    // TODO: Implement schedule editing
+                  },
+                  icon: const Icon(Icons.edit),
+                  label: const Text('Edit'),
+                  style: OutlinedButton.styleFrom(
+                    foregroundColor: AppTheme.colors.primary,
+                    side: BorderSide(color: AppTheme.colors.primary),
+                  ),
+                ),
+              ),
+              const SizedBox(width: 12),
+              Expanded(
+                child: ElevatedButton.icon(
+                  onPressed: () {
+                    // TODO: Implement schedule completion
+                  },
+                  icon: const Icon(Icons.check),
+                  label: const Text('Complete'),
+                  style: ElevatedButton.styleFrom(
+                    backgroundColor: AppTheme.colors.success,
+                    foregroundColor: Colors.white,
+                  ),
+                ),
+              ),
+            ],
+          ),
+        ],
+      ),
+    ).animate().fadeIn().slideX(begin: 0.3);
+  }
+
+  Color _getCategoryColor(String category) {
+    switch (category.toLowerCase()) {
+      case 'nutrition':
+        return AppTheme.colors.success;
+      case 'activity':
+        return AppTheme.colors.secondary;
+      case 'training':
+        return AppTheme.colors.primary;
+      case 'care':
+        return AppTheme.colors.info;
+      case 'social':
+        return AppTheme.colors.warning;
+      case 'health':
+        return AppTheme.colors.error;
+      case 'routine':
+        return AppTheme.colors.primary;
+      default:
+        return AppTheme.colors.textSecondary;
+    }
+  }
+
+  IconData _getCategoryIcon(String category) {
+    switch (category.toLowerCase()) {
+      case 'nutrition':
+        return Icons.restaurant;
+      case 'activity':
+        return Icons.fitness_center;
+      case 'training':
+        return Icons.school;
+      case 'care':
+        return Icons.favorite;
+      case 'social':
+        return Icons.people;
+      case 'health':
+        return Icons.health_and_safety;
+      case 'routine':
+        return Icons.schedule;
+      default:
+        return Icons.event;
+    }
+  }
+
+  Color _getPriorityColor(double priority) {
+    if (priority >= 0.8) return AppTheme.colors.error;
+    if (priority >= 0.6) return AppTheme.colors.warning;
+    return AppTheme.colors.success;
+  }
+
+  String _getPriorityText(double priority) {
+    if (priority >= 0.8) return 'High';
+    if (priority >= 0.6) return 'Medium';
+    return 'Low';
+  }
+
+  String _formatScheduleTime(DateTime time) {
+    final now = DateTime.now();
+    final difference = time.difference(now);
+    
+    if (difference.inDays > 0) {
+      return '${difference.inDays}d ${difference.inHours % 24}h from now';
+    } else if (difference.inHours > 0) {
+      return '${difference.inHours}h ${difference.inMinutes % 60}m from now';
+    } else if (difference.inMinutes > 0) {
+      return '${difference.inMinutes}m from now';
+    } else {
+      return 'Now';
+    }
+  }
+}// Smart Scheduling Widget
