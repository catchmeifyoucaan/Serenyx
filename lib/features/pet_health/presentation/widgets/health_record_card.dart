import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class HealthRecordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? value;
  final String? description;
  final List<String>? tags;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final String? status;

  const HealthRecordCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.value,
    this.description,
    this.tags,
    this.onTap,
    this.isHighlighted = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
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
        border: isHighlighted 
          ? Border.all(color: color, width: 2)
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: AppConstants.mdSpacing),
                    
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.warmGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.warmGrey.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.smRadius),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          status!,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Value and Description
                if (value != null || description != null) ...[
                  const SizedBox(height: AppConstants.mdSpacing),
                  if (value != null)
                    Text(
                      value!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (description != null) ...[
                    if (value != null) const SizedBox(height: AppConstants.xsSpacing),
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.warmGrey.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
                
                // Tags
                if (tags != null && tags!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.mdSpacing),
                  Wrap(
                    spacing: AppConstants.xsSpacing,
                    runSpacing: AppConstants.xsSpacing,
                    children: tags!.map((tag) => 
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.smRadius),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
                
                // Action Indicator
                if (onTap != null) ...[
                  const SizedBox(height: AppConstants.smSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.warmGrey.withOpacity(0.5),
                        size: 16,
                      ),
                    ],
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
}

// Specialized Health Record Cards
class VaccinationCard extends StatelessWidget {
  final String name;
  final DateTime date;
  final DateTime nextDue;
  final String veterinarian;
  final String clinic;
  final String? notes;
  final VoidCallback? onTap;

  const VaccinationCard({
    super.key,
    required this.name,
    required this.date,
    required this.nextDue,
    required this.veterinarian,
    required this.clinic,
    this.notes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysUntilDue = nextDue.difference(now).inDays;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue <= 30 && daysUntilDue >= 0;
    
    Color statusColor;
    String statusText;
    
    if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Overdue';
    } else if (isDueSoon) {
      statusColor = AppTheme.heartPink;
      statusText = 'Due Soon';
    } else {
      statusColor = AppTheme.leafGreen;
      statusText = 'Up to Date';
    }

    return HealthRecordCard(
      title: name,
      subtitle: '$veterinarian - $clinic',
      icon: Icons.vaccines,
      color: statusColor,
      value: isOverdue 
        ? '${daysUntilDue.abs()} days overdue'
        : isDueSoon 
          ? '${daysUntilDue} days until due'
          : 'Up to date',
      description: notes?.isNotEmpty == true ? notes : null,
      tags: [
        'Last: ${_formatDate(date)}',
        'Next: ${_formatDate(nextDue)}',
      ],
      onTap: onTap,
      isHighlighted: isOverdue || isDueSoon,
      status: statusText,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class WeightCard extends StatelessWidget {
  final double weight;
  final DateTime date;
  final String? notes;
  final double? previousWeight;
  final VoidCallback? onTap;

  const WeightCard({
    super.key,
    required this.weight,
    required this.date,
    this.notes,
    this.previousWeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weightChange = previousWeight != null ? weight - previousWeight! : 0.0;
    final weightChangePercent = previousWeight != null && previousWeight! > 0
        ? (weightChange / previousWeight! * 100)
        : 0.0;
    
    final isWeightGain = weightChange > 0;
    final isWeightLoss = weightChange < 0;
    final isStable = weightChange == 0;

    Color statusColor;
    String statusText;
    String? changeText;

    if (isWeightGain) {
      statusColor = AppTheme.heartPink;
      statusText = 'Gained';
      changeText = '+${weightChange.toStringAsFixed(1)} kg (+${weightChangePercent.toStringAsFixed(1)}%)';
    } else if (isWeightLoss) {
      statusColor = AppTheme.softPurple;
      statusText = 'Lost';
      changeText = '${weightChange.toStringAsFixed(1)} kg (${weightChangePercent.toStringAsFixed(1)}%)';
    } else {
      statusColor = AppTheme.leafGreen;
      statusText = 'Stable';
      changeText = 'No change';
    }

    return HealthRecordCard(
      title: 'Weight Record',
      subtitle: _formatDate(date),
      icon: Icons.monitor_weight,
      color: statusColor,
      value: '${weight.toStringAsFixed(1)} kg',
      description: changeText,
      tags: [
        if (notes?.isNotEmpty == true) notes!,
        if (previousWeight != null) 'Previous: ${previousWeight!.toStringAsFixed(1)} kg',
      ],
      onTap: onTap,
      status: statusText,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    final isNew = daysSinceStart <= 7;

    return HealthRecordCard(
      title: name,
      subtitle: '$dosage - $frequency',
      icon: Icons.medication,
      color: isActive ? AppTheme.softPurple : AppTheme.warmGrey,
      value: isActive ? 'Active' : 'Inactive',
      description: notes?.isNotEmpty == true ? notes : null,
      tags: [
        'Started: ${_formatDate(startDate)}',
        if (endDate != null) 'Ended: ${_formatDate(endDate!)}',
        if (isActive) 'Duration: ${daysSinceStart} days',
        if (isNew) 'New',
      ],
      onTap: onTap,
      isHighlighted: isNew,
      status: isActive ? 'Active' : 'Inactive',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class VetVisitCard extends StatelessWidget {
  final String reason;
  final DateTime date;
  final String veterinarian;
  final String clinic;
  final String diagnosis;
  final String treatment;
  final DateTime? followUp;
  final double cost;
  final String? notes;
  final VoidCallback? onTap;

  const VetVisitCard({
    super.key,
    required this.reason,
    required this.date,
    required this.veterinarian,
    required this.clinic,
    required this.diagnosis,
    required this.treatment,
    this.followUp,
    required this.cost,
    this.notes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRecent = DateTime.now().difference(date).inDays <= 30;
    final hasFollowUp = followUp != null && followUp!.isAfter(DateTime.now());

    return HealthRecordCard(
      title: reason,
      subtitle: '$veterinarian - $clinic',
      icon: Icons.local_hospital,
      color: hasFollowUp ? AppTheme.leafGreen : AppTheme.lightPink,
      value: '\$${cost.toStringAsFixed(0)}',
      description: notes?.isNotEmpty == true ? notes : null,
      tags: [
        'Date: ${_formatDate(date)}',
        if (diagnosis.isNotEmpty && diagnosis != 'N/A') 'Diagnosis: $diagnosis',
        if (treatment.isNotEmpty) 'Treatment: $treatment',
        if (hasFollowUp) 'Follow-up: ${_formatDate(followUp!)}',
        if (isRecent) 'Recent',
      ],
      onTap: onTap,
      isHighlighted: hasFollowUp,
      status: hasFollowUp ? 'Follow-up' : 'Completed',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}