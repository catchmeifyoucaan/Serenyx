import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';

class PreventiveCareSystem extends StatefulWidget {
  final Pet pet;

  const PreventiveCareSystem({super.key, required this.pet});

  @override
  State<PreventiveCareSystem> createState() => _PreventiveCareSystemState();
}

class _PreventiveCareSystemState extends State<PreventiveCareSystem> {
  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _checkups = [];
  List<Map<String, dynamic>> _medications = [];
  bool _isAddingVaccination = false;
  bool _isAddingCheckup = false;
  bool _isAddingMedication = false;

  @override
  void initState() {
    super.initState();
    _loadPreventiveCareData();
  }

  void _loadPreventiveCareData() {
    // Mock data - in real app, this would come from database
    _vaccinations = [
      {
        'id': '1',
        'name': 'Rabies',
        'dateGiven': DateTime.now().subtract(const Duration(days: 30)),
        'nextDue': DateTime.now().add(const Duration(days: 335)),
        'type': 'Core',
        'vet': 'Dr. Smith',
        'clinic': 'PetCare Clinic',
        'notes': '${widget.pet.name} handled the vaccination well',
      },
      {
        'id': '2',
        'name': 'DHPP',
        'dateGiven': DateTime.now().subtract(const Duration(days: 45)),
        'nextDue': DateTime.now().add(const Duration(days: 320)),
        'type': 'Core',
        'vet': 'Dr. Johnson',
        'clinic': 'PetCare Clinic',
        'notes': 'Annual booster shot',
      },
    ];

    _checkups = [
      {
        'id': '1',
        'type': 'Annual Physical',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'vet': 'Dr. Smith',
        'clinic': 'PetCare Clinic',
        'findings': 'Healthy weight, good dental health, clear eyes and ears',
        'recommendations': ['Continue current diet', 'Daily exercise', 'Dental cleaning in 6 months'],
        'nextDue': DateTime.now().add(const Duration(days: 305)),
      },
      {
        'id': '2',
        'type': 'Dental Checkup',
        'date': DateTime.now().subtract(const Duration(days: 90)),
        'vet': 'Dr. Johnson',
        'clinic': 'PetCare Clinic',
        'findings': 'Minor tartar buildup, no cavities',
        'recommendations': ['Daily teeth brushing', 'Dental chews', 'Professional cleaning in 3 months'],
        'nextDue': DateTime.now().add(const Duration(days: 275)),
      },
    ];

    _medications = [
      {
        'id': '1',
        'name': 'Heartgard Plus',
        'type': 'Preventive',
        'dosage': '1 chewable',
        'frequency': 'Monthly',
        'startDate': DateTime.now().subtract(const Duration(days: 120)),
        'endDate': null,
        'notes': 'Heartworm prevention',
        'isActive': true,
      },
      {
        'id': '2',
        'name': 'Frontline Plus',
        'type': 'Preventive',
        'dosage': '1 application',
        'frequency': 'Monthly',
        'startDate': DateTime.now().subtract(const Duration(days: 90)),
        'endDate': null,
        'notes': 'Flea and tick prevention',
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
          _buildPreventiveCareSummary(),
          const SizedBox(height: 24),
          _buildVaccinationTracker(),
          const SizedBox(height: 24),
          _buildCheckupScheduler(),
          const SizedBox(height: 24),
          _buildMedicationTracker(),
        ],
      ),
    );
  }

  Widget _buildPreventiveCareSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preventive Care Overview',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Vaccinations', '2 Active', Icons.vaccines, Colors.blue),
                _buildSummaryItem('Checkups', '2 Scheduled', Icons.medical_services, Colors.green),
                _buildSummaryItem('Medications', '2 Active', Icons.medication, Colors.orange),
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

  Widget _buildVaccinationTracker() {
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
                  'Vaccination Tracker',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingVaccination = !_isAddingVaccination;
                    });
                  },
                  icon: Icon(
                    _isAddingVaccination ? Icons.remove : Icons.add,
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
            if (_isAddingVaccination) ...[
              const SizedBox(height: 16),
              _buildVaccinationForm(),
            ],
            const SizedBox(height: 16),
            ..._vaccinations.map((vaccination) => _buildVaccinationItem(vaccination)),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Vaccination Name',
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
                  labelText: 'Date Given',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Next Due',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
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
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isAddingVaccination = false;
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
            child: const Text('Add Vaccination'),
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationItem(Map<String, dynamic> vaccination) {
    final daysUntilDue = vaccination['nextDue'].difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue <= 30 && daysUntilDue >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOverdue 
              ? AppTheme.colors.error.withOpacity(0.1)
              : isDueSoon 
                  ? AppTheme.colors.warning.withOpacity(0.1)
                  : AppTheme.colors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOverdue 
                ? AppTheme.colors.error
                : isDueSoon 
                    ? AppTheme.colors.warning
                    : AppTheme.colors.success,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vaccines,
                  color: isOverdue 
                      ? AppTheme.colors.error
                      : isDueSoon 
                          ? AppTheme.colors.warning
                          : AppTheme.colors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination['name'],
                        style: AppTheme.textStyles.titleSmall?.copyWith(
                          color: AppTheme.colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Given: ${_formatDate(vaccination['dateGiven'])}',
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
                    color: isOverdue 
                        ? AppTheme.colors.error
                        : isDueSoon 
                            ? AppTheme.colors.warning
                            : AppTheme.colors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverdue 
                        ? 'Overdue'
                        : isDueSoon 
                            ? 'Due Soon'
                            : 'Up to Date',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Next Due: ${_formatDate(vaccination['nextDue'])}',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            if (vaccination['notes'] != null) ...[
              const SizedBox(height: 8),
              Text(
                vaccination['notes'],
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckupScheduler() {
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
                  'Checkup Scheduler',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingCheckup = !_isAddingCheckup;
                    });
                  },
                  icon: Icon(
                    _isAddingCheckup ? Icons.remove : Icons.add,
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
            if (_isAddingCheckup) ...[
              const SizedBox(height: 16),
              _buildCheckupForm(),
            ],
            const SizedBox(height: 16),
            ..._checkups.map((checkup) => _buildCheckupItem(checkup)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckupForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Checkup Type',
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
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Next Due',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Findings',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isAddingCheckup = false;
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
            child: const Text('Add Checkup'),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckupItem(Map<String, dynamic> checkup) {
    final daysUntilDue = checkup['nextDue'].difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue <= 30 && daysUntilDue >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOverdue 
              ? AppTheme.colors.error.withOpacity(0.1)
              : isDueSoon 
                  ? AppTheme.colors.warning.withOpacity(0.1)
                  : AppTheme.colors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOverdue 
                ? AppTheme.colors.error
                : isDueSoon 
                    ? AppTheme.colors.warning
                    : AppTheme.colors.success,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: isOverdue 
                      ? AppTheme.colors.error
                      : isDueSoon 
                          ? AppTheme.colors.warning
                          : AppTheme.colors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkup['type'],
                        style: AppTheme.textStyles.titleSmall?.copyWith(
                          color: AppTheme.colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Last: ${_formatDate(checkup['date'])}',
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
                    color: isOverdue 
                        ? AppTheme.colors.error
                        : isDueSoon 
                            ? AppTheme.colors.warning
                            : AppTheme.colors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverdue 
                        ? 'Overdue'
                        : isDueSoon 
                            ? 'Due Soon'
                            : 'Up to Date',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Next Due: ${_formatDate(checkup['nextDue'])}',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            if (checkup['findings'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Findings: ${checkup['findings']}',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationTracker() {
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
                  'Medication Tracker',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingMedication = !_isAddingMedication;
                    });
                  },
                  icon: Icon(
                    _isAddingMedication ? Icons.remove : Icons.add,
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
            if (_isAddingMedication) ...[
              const SizedBox(height: 16),
              _buildMedicationForm(),
            ],
            const SizedBox(height: 16),
            ..._medications.map((medication) => _buildMedicationItem(medication)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Medication Name',
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
                  labelText: 'Dosage',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isAddingMedication = false;
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
            child: const Text('Add Medication'),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: medication['isActive'] 
              ? AppTheme.colors.primary.withOpacity(0.1)
              : AppTheme.colors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: medication['isActive'] 
                ? AppTheme.colors.primary
                : AppTheme.colors.textSecondary,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.medication,
              color: medication['isActive'] 
                  ? AppTheme.colors.primary
                  : AppTheme.colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication['name'],
                    style: AppTheme.textStyles.titleSmall?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${medication['dosage']} ${medication['frequency']}',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                  if (medication['notes'] != null)
                    Text(
                      medication['notes'],
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: medication['isActive'],
              onChanged: (value) {
                setState(() {
                  medication['isActive'] = value;
                });
              },
              activeColor: AppTheme.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}