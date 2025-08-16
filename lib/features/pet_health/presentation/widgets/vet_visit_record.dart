import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/health_models.dart';

class VetVisitRecordWidget extends StatelessWidget {
  final List<VetVisitRecord> vetVisits;
  final VoidCallback onAddVetVisit;
  final Function(VetVisitRecord) onEditVetVisit;

  const VetVisitRecordWidget({
    super.key,
    required this.vetVisits,
    required this.onAddVetVisit,
    required this.onEditVetVisit,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingVisits = vetVisits.where((v) => 
      v.followUp != null && v.followUp!.isAfter(DateTime.now())
    ).toList();
    
    final pastVisits = vetVisits.where((v) => 
      v.followUp == null || v.followUp!.isBefore(DateTime.now())
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Header with Add Button
        Row(
          children: [
            Expanded(
              child: Text(
                'Vet Visit Records',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddVetVisit,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Visit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Upcoming Follow-ups
        if (upcomingVisits.isNotEmpty)
          _buildUpcomingFollowUps(upcomingVisits),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Visit Summary
        _buildVisitSummary(context),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Past Visits
        if (pastVisits.isNotEmpty) ...[
          Text(
            'Visit History',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          ...pastVisits.map((visit) => 
            _buildVetVisitCard(visit, context)
          ).toList(),
        ],
        
        // Empty State
        if (vetVisits.isEmpty)
          _buildEmptyState(),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Vet Visit Guidelines
        _buildVetVisitGuidelines(context),
      ],
    );
  }

  Widget _buildUpcomingFollowUps(List<VetVisitRecord> upcomingVisits) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: AppTheme.leafGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        border: Border.all(color: AppTheme.leafGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppTheme.leafGreen,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smSpacing),
              Text(
                'Upcoming Follow-ups',
                style: TextStyle(
                  color: AppTheme.leafGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smSpacing),
          ...upcomingVisits.map((visit) => 
            _buildFollowUpItem(visit)
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildFollowUpItem(VetVisitRecord visit) {
    final daysUntilFollowUp = visit.followUp!.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.smSpacing),
      padding: const EdgeInsets.all(AppConstants.smSpacing),
      decoration: BoxDecoration(
        color: AppTheme.leafGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smRadius),
        border: Border.all(color: AppTheme.leafGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.reason,
                  style: TextStyle(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${visit.veterinarian} - ${visit.clinic}',
                  style: TextStyle(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: daysUntilFollowUp <= 7 
                ? AppTheme.heartPink 
                : AppTheme.leafGreen,
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
            ),
            child: Text(
              daysUntilFollowUp <= 7 
                ? '${daysUntilFollowUp} days'
                : '${daysUntilFollowUp} days',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitSummary(BuildContext context) {
    if (vetVisits.isEmpty) return const SizedBox.shrink();

    final totalVisits = vetVisits.length;
    final totalCost = vetVisits.fold(0.0, (sum, visit) => sum + visit.cost);
    final averageCost = totalCost / totalVisits;
    final lastVisit = vetVisits.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final daysSinceLastVisit = DateTime.now().difference(lastVisit.date).inDays;

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
            'Visit Summary',
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
                  'Total Visits',
                  '$totalVisits',
                  Icons.local_hospital,
                  AppTheme.lightPink,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Cost',
                  '\$${totalCost.toStringAsFixed(0)}',
                  Icons.attach_money,
                  AppTheme.leafGreen,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Avg Cost',
                  '\$${averageCost.toStringAsFixed(0)}',
                  Icons.calculate,
                  AppTheme.softPurple,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Last Visit',
                  '${daysSinceLastVisit}d ago',
                  Icons.history,
                  AppTheme.heartPink,
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

  Widget _buildVetVisitCard(VetVisitRecord visit, BuildContext context) {
    final isRecent = DateTime.now().difference(visit.date).inDays <= 30;
    
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
          onTap: () => onEditVetVisit(visit),
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Date and Cost
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        visit.reason,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isRecent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.heartPink,
                          borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        ),
                        child: const Text(
                          'Recent',
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
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.leafGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smRadius),
                        border: Border.all(color: AppTheme.leafGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        '\$${visit.cost.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppTheme.leafGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Date and Veterinarian
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Date',
                        _formatDate(visit.date),
                        Icons.calendar_today,
                        AppTheme.softPurple,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Veterinarian',
                        visit.veterinarian,
                        Icons.person,
                        AppTheme.heartPink,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Clinic
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.warmGrey.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        visit.clinic,
                        style: TextStyle(
                          color: AppTheme.warmGrey.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smSpacing),
                
                // Diagnosis and Treatment
                if (visit.diagnosis.isNotEmpty && visit.diagnosis != 'N/A') ...[
                  _buildDetailRow('Diagnosis', visit.diagnosis, Icons.healing),
                  const SizedBox(height: AppConstants.xsSpacing),
                ],
                if (visit.treatment.isNotEmpty) ...[
                  _buildDetailRow('Treatment', visit.treatment, Icons.medical_services),
                  const SizedBox(height: AppConstants.xsSpacing),
                ],
                
                // Notes
                if (visit.notes?.isNotEmpty == true) ...[
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
                            visit.notes!,
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
                
                // Follow-up Info
                if (visit.followUp != null) ...[
                  const SizedBox(height: AppConstants.smSpacing),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smSpacing,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.leafGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppTheme.leafGreen,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.xsSpacing),
                        Text(
                          'Follow-up: ${_formatDate(visit.followUp!)}',
                          style: TextStyle(
                            color: AppTheme.leafGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.warmGrey.withOpacity(0.6),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppTheme.warmGrey.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.warmGrey,
              fontSize: 14,
            ),
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
              color: AppTheme.lightPink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_hospital,
              color: AppTheme.lightPink,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No vet visits recorded yet',
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
              'Add your pet\'s vet visits to track their health history',
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

  Widget _buildVetVisitGuidelines(BuildContext context) {
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
            'Vet Visit Guidelines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          
          _buildGuidelineItem(
            'Annual Checkups',
            'Schedule yearly wellness exams',
            Icons.calendar_today,
            AppTheme.leafGreen,
          ),
          _buildGuidelineItem(
            'Vaccination Schedule',
            'Keep vaccinations up to date',
            Icons.vaccines,
            AppTheme.heartPink,
          ),
          _buildGuidelineItem(
            'Emergency Preparedness',
            'Know your nearest emergency vet',
            Icons.emergency,
            AppTheme.softPurple,
          ),
          _buildGuidelineItem(
            'Health Records',
            'Keep detailed visit notes',
            Icons.folder,
            AppTheme.lightPink,
          ),
          _buildGuidelineItem(
            'Follow-up Care',
            'Attend all recommended follow-ups',
            Icons.schedule,
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

