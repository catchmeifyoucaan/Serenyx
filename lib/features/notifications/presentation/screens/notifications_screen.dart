import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/notification_models.dart';
import '../widgets/reminder_card.dart';
import '../widgets/smart_suggestions.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  final Pet pet;

  const NotificationsScreen({super.key, required this.pet});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Reminder> _reminders = [];
  final List<SmartSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  void _loadNotifications() {
    // Load real notifications from storage/database
    // For now, we'll start with empty lists for a clean slate
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: Text(
          'Notifications & Reminders',
          style: AppTheme.textStyles.headlineMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.colors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.colors.primary,
          unselectedLabelColor: AppTheme.colors.textSecondary,
          indicatorColor: AppTheme.colors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.notifications), text: 'Reminders'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Suggestions'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.colors.primary),
            onPressed: _showAddReminderDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersTab(),
          SmartSuggestions(
            suggestions: _suggestions,
            onSuggestionAction: _handleSuggestionAction,
          ),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: AppTheme.colors.primary,
        child: Icon(Icons.add, color: AppTheme.colors.onPrimary),
      ),
    );
  }

  Widget _buildRemindersTab() {
    if (_reminders.isEmpty) {
      return _buildEmptyState(
        'No Reminders Yet',
        'Create reminders to never miss important pet care tasks!',
        Icons.notifications,
        () => _showAddReminderDialog(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        return ReminderCard(
          reminder: _reminders[index],
          onToggle: (isActive) => _toggleReminder(_reminders[index], isActive),
          onEdit: () => _editReminder(_reminders[index]),
          onDelete: () => _deleteReminder(_reminders[index]),
          onSnooze: () => _snoozeReminder(_reminders[index]),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: AppTheme.textStyles.headlineSmall?.copyWith(
              color: AppTheme.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSettingCard(
            'Push Notifications',
            'Receive notifications on your device',
            Icons.notifications_active,
            true,
            (value) => _updateNotificationSetting('push', value),
          ),
          
          _buildSettingCard(
            'Email Notifications',
            'Get reminders via email',
            Icons.email,
            false,
            (value) => _updateNotificationSetting('email', value),
          ),
          
          _buildSettingCard(
            'SMS Notifications',
            'Receive text message reminders',
            Icons.sms,
            false,
            (value) => _updateNotificationSetting('sms', value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSettingCard(
            'Quiet Hours',
            'Mute notifications during sleep hours',
            Icons.bedtime,
            true,
            (value) => _updateNotificationSetting('quiet_hours', value),
          ),
          
          _buildSettingCard(
            'Weekly Summary',
            'Get a weekly report of all activities',
            Icons.summarize,
            true,
            (value) => _updateNotificationSetting('weekly_summary', value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String description, IconData icon, bool value, Function(bool) onChanged) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.colors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, VoidCallback onAction) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppTheme.colors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTheme.textStyles.headlineMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: AppTheme.colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Create Reminder'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        pet: widget.pet,
        onReminderAdded: (reminder) {
          setState(() {
            _reminders.add(reminder);
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _toggleReminder(Reminder reminder, bool isActive) {
    setState(() {
      reminder.isActive = isActive;
    });
    // Update in storage/database
  }

  void _editReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => EditReminderDialog(
        reminder: reminder,
        onReminderUpdated: (updatedReminder) {
          setState(() {
            final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
            if (index != -1) {
              _reminders[index] = updatedReminder;
            }
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reminders.removeWhere((r) => r.id == reminder.id);
              });
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.colors.error)),
          ),
        ],
      ),
    );
  }

  void _snoozeReminder(Reminder reminder) {
    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 15));
    
    setState(() {
      reminder.nextReminder = snoozeTime;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder snoozed for 15 minutes'),
        backgroundColor: AppTheme.colors.success,
      ),
    );
  }

  void _handleSuggestionAction(SmartSuggestion suggestion) {
    // Handle different suggestion actions
    switch (suggestion.type) {
      case SuggestionType.reminder:
        _showAddReminderDialog();
        break;
      case SuggestionType.health:
        // Navigate to health screen
        break;
      case SuggestionType.activity:
        // Navigate to activity screen
        break;
    }
  }

  void _updateNotificationSetting(String setting, bool value) {
    // Update notification settings in storage/database
    print('Updated $setting to $value');
  }
}

class AddReminderDialog extends StatefulWidget {
  final Pet pet;
  final Function(Reminder) onReminderAdded;

  const AddReminderDialog({
    super.key,
    required this.pet,
    required this.onReminderAdded,
  });

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ReminderType _selectedType = ReminderType.feeding;
  ReminderFrequency _selectedFrequency = ReminderFrequency.daily;
  bool _isRepeating = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReminder() {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        frequency: _selectedFrequency,
        isRepeating: _isRepeating,
        isActive: true,
        nextReminder: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        petId: widget.pet.id,
        createdAt: DateTime.now(),
      );
      
      widget.onReminderAdded(reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Reminder',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Type dropdown
                DropdownButtonFormField<ReminderType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Reminder Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ReminderType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getReminderTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                ),

                // Time picker
                ListTile(
                  title: Text(
                    'Time: ${_selectedTime.format(context)}',
                    style: AppTheme.textStyles.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                  ),
                ),

                // Repeating toggle
                SwitchListTile(
                  title: Text('Repeating Reminder'),
                  value: _isRepeating,
                  onChanged: (value) {
                    setState(() {
                      _isRepeating = value;
                    });
                  },
                ),

                // Frequency dropdown (only show if repeating)
                if (_isRepeating) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ReminderFrequency>(
                    value: _selectedFrequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ReminderFrequency.values.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(_getFrequencyText(frequency)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submitReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.primary,
                        foregroundColor: AppTheme.colors.onPrimary,
                      ),
                      child: Text('Create Reminder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getReminderTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.feeding:
        return 'Feeding';
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.vaccination:
        return 'Vaccination';
      case ReminderType.grooming:
        return 'Grooming';
      case ReminderType.exercise:
        return 'Exercise';
      case ReminderType.vet:
        return 'Vet Visit';
      case ReminderType.training:
        return 'Training';
      case ReminderType.other:
        return 'Other';
    }
  }

  String _getFrequencyText(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.yearly:
        return 'Yearly';
    }
  }
}

class EditReminderDialog extends StatefulWidget {
  final Reminder reminder;
  final Function(Reminder) onReminderUpdated;

  const EditReminderDialog({
    super.key,
    required this.reminder,
    required this.onReminderUpdated,
  });

  @override
  State<EditReminderDialog> createState() => _EditReminderDialogState();
}

class _EditReminderDialogState extends State<EditReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late ReminderType _selectedType;
  late ReminderFrequency _selectedFrequency;
  late bool _isRepeating;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder.title);
    _descriptionController = TextEditingController(text: widget.reminder.description);
    _selectedDate = widget.reminder.nextReminder;
    _selectedTime = TimeOfDay.fromDateTime(widget.reminder.nextReminder);
    _selectedType = widget.reminder.type;
    _selectedFrequency = widget.reminder.frequency;
    _isRepeating = widget.reminder.isRepeating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateReminder() {
    if (_formKey.currentState!.validate()) {
      final updatedReminder = Reminder(
        id: widget.reminder.id,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        frequency: _selectedFrequency,
        isRepeating: _isRepeating,
        isActive: widget.reminder.isActive,
        nextReminder: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        petId: widget.reminder.petId,
        createdAt: widget.reminder.createdAt,
      );
      
      widget.onReminderUpdated(updatedReminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Reminder',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Type dropdown
                DropdownButtonFormField<ReminderType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Reminder Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ReminderType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getReminderTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                ),

                // Time picker
                ListTile(
                  title: Text(
                    'Time: ${_selectedTime.format(context)}',
                    style: AppTheme.textStyles.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                  ),
                ),

                // Repeating toggle
                SwitchListTile(
                  title: Text('Repeating Reminder'),
                  value: _isRepeating,
                  onChanged: (value) {
                    setState(() {
                      _isRepeating = value;
                    });
                  },
                ),

                // Frequency dropdown (only show if repeating)
                if (_isRepeating) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ReminderFrequency>(
                    value: _selectedFrequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ReminderFrequency.values.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(_getFrequencyText(frequency)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updateReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.primary,
                        foregroundColor: AppTheme.colors.onPrimary,
                      ),
                      child: Text('Update Reminder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getReminderTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.feeding:
        return 'Feeding';
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.vaccination:
        return 'Vaccination';
      case ReminderType.grooming:
        return 'Grooming';
      case ReminderType.exercise:
        return 'Exercise';
      case ReminderType.vet:
        return 'Vet Visit';
      case ReminderType.training:
        return 'Training';
      case ReminderType.other:
        return 'Other';
    }
  }

  String _getFrequencyText(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.yearly:
        return 'Yearly';
    }
  }
}

