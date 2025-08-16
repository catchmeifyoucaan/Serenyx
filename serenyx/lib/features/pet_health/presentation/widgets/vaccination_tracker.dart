import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/health_models.dart';

class VaccinationTracker extends StatelessWidget {
  final List<VaccinationRecord> vaccinations;
  final VoidCallback onAddVaccination;
  final Function(VaccinationRecord) onEditVaccination;

  const VaccinationTracker({
    super.key,
    required this.vaccinations,
    required this.onAddVaccination,
    required this.onEditVaccination,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Header with Add Button
        Row(
          children: [
            Expanded(
              child: Text(
                'Vaccination Records',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddVaccination,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Vaccination'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.leafGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Due Soon Alert
        if (_hasUpcomingVaccinations())
          _buildDueSoonAlert(),
        
        const SizedBox(height: AppConstants.mdSpacing),
        
        // Vaccination List
        if (vaccinations.isEmpty)
          _buildEmptyState()
        else
          ...vaccinations.map((vaccination) => 
            _buildVaccinationCard(vaccination, context)
          ).toList(),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Vaccination Schedule
        _buildVaccinationSchedule(context),
      ],
    );
  }

  bool _hasUpcomingVaccinations() {
    final now = DateTime.now();
    return vaccinations.any((v) => 
      v.nextDue != null && v.nextDue!.difference(now).inDays <= 30 && 
      v.nextDue!.difference(now).inDays > 0
    );
  }

  Widget _buildDueSoonAlert() {
    final upcomingVaccinations = vaccinations.where((v) {
      final daysUntilDue = v.nextDue?.difference(DateTime.now()).inDays;
      return daysUntilDue != null && daysUntilDue <= 30 && daysUntilDue > 0;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: AppTheme.heartPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        border: Border.all(color: AppTheme.heartPink.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.heartPink,
            size: 24,
          ),
          const SizedBox(width: AppConstants.smSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaccinations Due Soon',
                  style: TextStyle(
                    color: AppTheme.heartPink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${upcomingVaccinations.length} vaccination(s) due within 30 days',
                  style: TextStyle(
                    color: AppTheme.heartPink.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              color: AppTheme.leafGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.vaccines,
              color: AppTheme.leafGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No vaccinations recorded yet',
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
              'Add your pet\'s vaccination records to track their health',
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

  Widget _buildVaccinationCard(VaccinationRecord vaccination, BuildContext context) {
    final now = DateTime.now();
    final daysUntilDue = vaccination.nextDue?.difference(now).inDays;
    final isOverdue = daysUntilDue != null && daysUntilDue < 0;
    final isDueSoon = daysUntilDue != null && daysUntilDue <= 30 && daysUntilDue >= 0;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Overdue';
      statusIcon = Icons.warning;
    } else if (isDueSoon) {
      statusColor = AppTheme.heartPink;
      statusText = 'Due Soon';
      statusIcon = Icons.schedule;
    } else {
      statusColor = AppTheme.leafGreen;
      statusText = 'Up to Date';
      statusIcon = Icons.check_circle;
    }

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
          onTap: () => onEditVaccination(vaccination),
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
                        vaccination.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.smSpacing,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                        'Last Given',
                        vaccination.date,
                        Icons.calendar_today,
                        AppTheme.softPurple,
                      ),
                    ),
                    if (vaccination.nextDue != null)
                      Expanded(
                        child: _buildDateInfo(
                          'Next Due',
                          vaccination.nextDue!,
                          Icons.schedule,
                          isOverdue ? Colors.red : AppTheme.leafGreen,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Veterinarian Info
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: AppTheme.warmGrey.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vaccination.veterinarian,
                      style: TextStyle(
                        color: AppTheme.warmGrey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smSpacing),
                    Icon(
                      Icons.location_on,
                      color: AppTheme.warmGrey.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vaccination.clinic,
                      style: TextStyle(
                        color: AppTheme.warmGrey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                if (vaccination.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: AppConstants.smSpacing),
                  Text(
                    vaccination.notes!,
                    style: TextStyle(
                      color: AppTheme.warmGrey.withOpacity(0.7),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                // Days Until Due
                if (daysUntilDue != 0) ...[
                  const SizedBox(height: AppConstants.smSpacing),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smSpacing,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smRadius),
                    ),
                    child: Text(
                      isOverdue 
                        ? '${daysUntilDue.abs()} days overdue'
                        : '${daysUntilDue} days until due',
                      style: TextStyle(
                        color: statusColor,
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

  Widget _buildVaccinationSchedule(BuildContext context) {
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
            'Vaccination Schedule',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          
          // Schedule Items
          _buildScheduleItem(
            'Rabies',
            'Annual',
            'Every 12 months',
            AppTheme.heartPink,
          ),
          _buildScheduleItem(
            'DHPP',
            'Annual',
            'Every 12 months',
            AppTheme.leafGreen,
          ),
          _buildScheduleItem(
            'Bordetella',
            'Annual',
            'Every 12 months',
            AppTheme.softPurple,
          ),
          _buildScheduleItem(
            'Lyme Disease',
            'Annual',
            'Every 12 months',
            AppTheme.lightPink,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String name, String frequency, String description, Color color) {
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.smSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$frequency - $description',
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

