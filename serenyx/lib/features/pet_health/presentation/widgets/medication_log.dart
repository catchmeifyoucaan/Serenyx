import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/health_models.dart';

class MedicationLog extends StatelessWidget {
  final List<MedicationRecord> medications;
  final VoidCallback onAddMedication;
  final Function(MedicationRecord) onEditMedication;

  const MedicationLog({
    super.key,
    required this.medications,
    required this.onAddMedication,
    required this.onEditMedication,
  });

  @override
  Widget build(BuildContext context) {
    final activeMedications = medications.where((m) => m.isActive).toList();
    final inactiveMedications = medications.where((m) => !m.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Header with Add Button
        Row(
          children: [
            Expanded(
              child: Text(
                'Medication Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddMedication,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Medication'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.softPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Active Medications Summary
        if (activeMedications.isNotEmpty)
          _buildActiveMedicationsSummary(activeMedications, context),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Active Medications
        if (activeMedications.isNotEmpty) ...[
          Text(
            'Active Medications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          ...activeMedications.map((medication) => 
            _buildMedicationCard(medication, context, true)
          ).toList(),
        ],
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Inactive Medications
        if (inactiveMedications.isNotEmpty) ...[
          Text(
            'Inactive Medications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          ...inactiveMedications.map((medication) => 
            _buildMedicationCard(medication, context, false)
          ).toList(),
        ],
        
        // Empty State
        if (medications.isEmpty)
          _buildEmptyState(),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Medication Guidelines
        _buildMedicationGuidelines(context),
      ],
    );
  }

  Widget _buildActiveMedicationsSummary(List<MedicationRecord> activeMedications, BuildContext context) {
    final totalMedications = activeMedications.length;
    final dailyMedications = activeMedications.where((m) => 
      m.frequency.toLowerCase().contains('daily')
    ).length;
    final weeklyMedications = activeMedications.where((m) => 
      m.frequency.toLowerCase().contains('weekly')
    ).length;
    final monthlyMedications = activeMedications.where((m) => 
      m.frequency.toLowerCase().contains('monthly')
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
            'Medication Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total',
                  '$totalMedications',
                  Icons.medication,
                  AppTheme.softPurple,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Daily',
                  '$dailyMedications',
                  Icons.schedule,
                  AppTheme.heartPink,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Weekly',
                  '$weeklyMedications',
                  Icons.calendar_view_week,
                  AppTheme.leafGreen,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Monthly',
                  '$monthlyMedications',
                  Icons.calendar_month,
                  AppTheme.lightPink,
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color, BuildContext context) {
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
        Text(
          label,
          style: TextStyle(
            color: AppTheme.warmGrey.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMedicationCard(MedicationRecord medication, BuildContext context, bool isActive) {
    final daysSinceStart = DateTime.now().difference(medication.startDate).inDays;
    final isNew = daysSinceStart <= 7;
    
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onEditMedication(medication),
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        medication.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.leafGreen,
                          borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppConstants.smSpacing),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive 
                          ? AppTheme.softPurple.withOpacity(0.2)
                          : AppTheme.warmGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        border: Border.all(
                          color: isActive 
                            ? AppTheme.softPurple
                            : AppTheme.warmGrey.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive 
                            ? AppTheme.softPurple
                            : AppTheme.warmGrey.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Dosage and Frequency
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Dosage',
                        medication.dosage,
                        Icons.science,
                        AppTheme.heartPink,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Frequency',
                        medication.frequency,
                        Icons.schedule,
                        AppTheme.leafGreen,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo(
                        'Started',
                        medication.startDate,
                        Icons.play_circle,
                        AppTheme.softPurple,
                      ),
                    ),
                    if (medication.endDate != null)
                      Expanded(
                        child: _buildDateInfo(
                          'Ended',
                          medication.endDate!,
                          Icons.stop_circle,
                          AppTheme.lightPink,
                        ),
                      ),
                  ],
                ),
                
                if (medication.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: AppConstants.smSpacing),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smSpacing),
                    decoration: BoxDecoration(
                      color: AppTheme.softPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smRadius),
                      border: Border.all(color: AppTheme.softPink.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: AppTheme.softPink,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.xsSpacing),
                        Expanded(
                          child: Text(
                            medication.notes ?? '',
                            style: TextStyle(
                              color: AppTheme.warmGrey.withOpacity(0.8),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Duration Info
                if (isActive) ...[
                  const SizedBox(height: AppConstants.smSpacing),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smSpacing,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smRadius),
                    ),
                    child: Text(
                      'Active for ${daysSinceStart} days',
                      style: TextStyle(
                        color: AppTheme.softPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
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
          value,
          style: TextStyle(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon, Color color) {
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
          _formatDate(date),
          style: TextStyle(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.xlSpacing),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.softPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication,
              color: AppTheme.softPurple,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No medications recorded yet',
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
              'Add your pet\'s medications to track their treatment',
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

  Widget _buildMedicationGuidelines(BuildContext context) {
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
            'Medication Guidelines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          
          _buildGuidelineItem(
            'Follow Prescription',
            'Always give the exact dosage prescribed',
            Icons.check_circle,
            AppTheme.leafGreen,
          ),
          _buildGuidelineItem(
            'Timing is Important',
            'Administer at the same time each day',
            Icons.schedule,
            AppTheme.heartPink,
          ),
          _buildGuidelineItem(
            'Complete the Course',
            'Don\'t stop early, even if symptoms improve',
            Icons.timeline,
            AppTheme.softPurple,
          ),
          _buildGuidelineItem(
            'Monitor Side Effects',
            'Watch for any unusual behavior or reactions',
            Icons.warning,
            AppTheme.lightPink,
          ),
          _buildGuidelineItem(
            'Store Properly',
            'Keep medications in a cool, dry place',
            Icons.inventory,
            AppTheme.leafGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      padding: const EdgeInsets.all(AppConstants.smSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppConstants.smSpacing),
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

