import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/notification_models.dart';
import '../../../../shared/services/pet_service.dart';
import '../widgets/reminder_card.dart';
import '../widgets/smart_suggestions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  
  List<Pet> _pets = [];
  List<Reminder> _reminders = [];
  List<SmartSuggestion> _smartSuggestions = [];
  
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String _selectedTimeRange = 'Today';

  @override
  void initState() {
    super.initState();
    _loadNotificationsData();
  }

  Future<void> _loadNotificationsData() async {
    try {
      await _loadPets();
      await _loadReminders();
      await _generateSmartSuggestions();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPets() async {
    _pets = await _petService.getPets();
  }

  Future<void> _loadReminders() async {
    // Simulate loading reminders
    _reminders = [
      Reminder(
        id: 'r1',
        title: 'Bonding Time with Luna',
        description: 'Time for your daily bonding session with Luna',
        time: DateTime.now().add(const Duration(hours: 2)), // Added missing time parameter
        type: ReminderType.bonding,
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        petId: 'pet1',
        isActive: true,
        frequency: ReminderFrequency.daily,
        icon: Icons.favorite,
        color: AppTheme.heartPink,
      ),
      Reminder(
        id: 'r2',
        title: 'Vaccination Due',
        description: 'Luna\'s rabies vaccination is due in 5 days',
        time: DateTime.now().add(const Duration(days: 5)), // Added missing time parameter
        type: ReminderType.health,
        scheduledTime: DateTime.now().add(const Duration(days: 5)),
        petId: 'pet1',
        isActive: true,
        frequency: ReminderFrequency.monthly, // Changed from oneTime to monthly
        icon: Icons.vaccines,
        color: AppTheme.leafGreen,
      ),
      Reminder(
        id: 'r3',
        title: 'Weight Check',
        description: 'Monthly weight monitoring for Luna',
        time: DateTime.now().add(const Duration(days: 7)), // Added missing time parameter
        type: ReminderType.health,
        scheduledTime: DateTime.now().add(const Duration(days: 7)),
        petId: 'pet1',
        isActive: true,
        frequency: ReminderFrequency.monthly,
        icon: Icons.monitor_weight,
        color: AppTheme.softPurple,
      ),
      Reminder(
        id: 'r4',
        title: 'Medication Reminder',
        description: 'Give Luna her heartworm medication',
        time: DateTime.now().add(const Duration(hours: 1)), // Added missing time parameter
        type: ReminderType.medication,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        petId: 'pet1',
        isActive: true,
        frequency: ReminderFrequency.monthly,
        icon: Icons.medication,
        color: AppTheme.lightPink,
      ),
    ];
  }

  Future<void> _generateSmartSuggestions() async {
    // Simulate AI-generated smart suggestions
    _smartSuggestions = [
      SmartSuggestion(
        id: 's1',
        title: 'Optimal Bonding Time',
        description: 'Based on Luna\'s activity patterns, 6-8 PM is her most energetic time. Consider scheduling bonding sessions during this window.',
        type: SuggestionType.bonding, // Changed from timing to bonding
        priority: SuggestionPriority.high,
        createdAt: DateTime.now(), // Added missing createdAt parameter
        isRead: false, // Added missing isRead parameter
        icon: Icons.schedule,
        color: AppTheme.heartPink,
      ),
      SmartSuggestion(
        id: 's2',
        title: 'Health Check Reminder',
        description: 'Luna hasn\'t had a weight check in 45 days. Regular monitoring helps detect health changes early.',
        type: SuggestionType.health,
        priority: SuggestionPriority.medium,
        createdAt: DateTime.now(), // Added missing createdAt parameter
        isRead: false, // Added missing isRead parameter
        icon: Icons.health_and_safety,
        color: AppTheme.leafGreen,
      ),
      SmartSuggestion(
        id: 's3',
        title: 'Social Activity Boost',
        description: 'Luna\'s mood ratings have been lower this week. Consider adding a park visit or playdate to boost her spirits.',
        type: SuggestionType.social, // Changed from behavior to social
        priority: SuggestionPriority.medium,
        createdAt: DateTime.now(), // Added missing createdAt parameter
        isRead: false, // Added missing isRead parameter
        icon: Icons.psychology,
        color: AppTheme.softPurple,
      ),
      SmartSuggestion(
        id: 's4',
        title: 'Training Opportunity',
        description: 'Luna shows high engagement during morning sessions. This might be the best time to introduce new commands.',
        type: SuggestionType.training,
        priority: SuggestionPriority.low,
        createdAt: DateTime.now(), // Added missing createdAt parameter
        isRead: false, // Added missing isRead parameter
        icon: Icons.school,
        color: AppTheme.lightPink,
      ),
    ];
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsEnabled 
            ? 'Notifications enabled! 🔔'
            : 'Notifications disabled! 🔕'
        ),
        backgroundColor: _notificationsEnabled ? AppTheme.leafGreen : AppTheme.warmGrey,
      ),
    );
  }

  void _addNewReminder() {
    // TODO: Implement add new reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add Reminder feature coming soon! ⏰'),
        backgroundColor: AppTheme.leafGreen,
      ),
    );
  }

  void _toggleReminder(String reminderId) {
    setState(() {
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      reminder.isActive = !reminder.isActive;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _reminders.firstWhere((r) => r.id == reminderId).isActive
            ? 'Reminder activated! ⏰'
            : 'Reminder deactivated! 🔕'
        ),
        backgroundColor: AppTheme.leafGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPinkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTimeRangeSelector(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildNotificationsContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewReminder,
        backgroundColor: AppTheme.heartPink,
        icon: const Icon(Icons.add_alarm, color: Colors.white),
        label: const Text(
          'Add Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.warmGrey),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Notifications & Reminders',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Stay on top of pet care',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) => _toggleNotifications(),
            activeColor: AppTheme.leafGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final timeRanges = ['Today', 'Tomorrow', 'This Week', 'This Month'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeRanges.length,
        itemBuilder: (context, index) {
          final timeRange = timeRanges[index];
          final isSelected = _selectedTimeRange == timeRange;
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.smSpacing),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeRange = timeRange;
                });
              },
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mdSpacing,
                  vertical: AppConstants.smSpacing,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.heartPink : AppTheme.softPink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                  border: Border.all(
                    color: isSelected ? AppTheme.heartPink : AppTheme.softPink,
                  ),
                ),
                child: Text(
                  timeRange,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.heartPink,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Quick Stats
        _buildQuickStats(),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Smart Suggestions
        if (_smartSuggestions.isNotEmpty) ...[
          Text(
            'Smart Suggestions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          ..._smartSuggestions.map((suggestion) => 
            SmartSuggestionCard(suggestion: suggestion)
          ).toList(),
          
          const SizedBox(height: AppConstants.xlSpacing),
        ],
        
        // Active Reminders
        Text(
          'Active Reminders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.mdSpacing),
        
        if (_reminders.where((r) => r.isActive).isEmpty)
          _buildEmptyReminders()
        else
          ..._reminders.where((r) => r.isActive).map((reminder) => 
            ReminderCard(
              reminder: reminder,
              pet: _pets.firstWhere((p) => p.id == reminder.petId, orElse: () => Pet.empty()),
              onToggle: () => _toggleReminder(reminder.id),
            ),
          ).toList(),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Notification Settings
        NotificationSettingsCard(
          notificationsEnabled: _notificationsEnabled,
          onToggleNotifications: _toggleNotifications,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final activeReminders = _reminders.where((r) => r.isActive).length;
    final upcomingReminders = _reminders.where((r) => 
      r.isActive && r.scheduledTime.isAfter(DateTime.now())
    ).length;
    final overdueReminders = _reminders.where((r) => 
      r.isActive && r.scheduledTime.isBefore(DateTime.now())
    ).length;

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
            'Reminder Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Active',
                  '$activeReminders',
                  Icons.notifications_active,
                  AppTheme.heartPink,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Upcoming',
                  '$upcomingReminders',
                  Icons.schedule,
                  AppTheme.leafGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Overdue',
                  '$overdueReminders',
                  Icons.warning,
                  overdueReminders > 0 ? Colors.orange : AppTheme.warmGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.warmGrey.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReminders() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.xlSpacing),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.heartPink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off,
              color: AppTheme.heartPink,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No active reminders',
            style: TextStyle(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          SizedBox(
            width: double.infinity,
            child: Text(
              'Add reminders to stay on top of your pet\'s care schedule',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

