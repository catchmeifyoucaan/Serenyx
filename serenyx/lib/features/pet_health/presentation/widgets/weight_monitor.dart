import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/health_models.dart';

class WeightMonitor extends StatelessWidget {
  final List<WeightRecord> weightRecords;
  final VoidCallback onAddWeight;
  final Function(WeightRecord) onEditWeight;

  const WeightMonitor({
    super.key,
    required this.weightRecords,
    required this.onAddWeight,
    required this.onEditWeight,
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
                'Weight Monitoring',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddWeight,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Weight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.heartPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Weight Chart
        if (weightRecords.isNotEmpty)
          _buildWeightChart(context),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Weight Summary
        _buildWeightSummary(context),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Weight Records List
        if (weightRecords.isEmpty)
          _buildEmptyState()
        else
          ...weightRecords.map((record) => 
            _buildWeightRecordCard(record, context)
          ).toList(),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Weight Guidelines
        _buildWeightGuidelines(context),
      ],
    );
  }

  Widget _buildWeightChart(BuildContext context) {
    if (weightRecords.length < 2) return const SizedBox.shrink();

    final sortedRecords = List<WeightRecord>.from(weightRecords)
      ..sort((a, b) => a.date.compareTo(b.date));

    final minWeight = sortedRecords.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedRecords.map((r) => r.weight).reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;

    return Container(
      height: 200,
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
            'Weight Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: WeightChartPainter(
                weightRecords: sortedRecords,
                minWeight: minWeight,
                maxWeight: maxWeight,
                weightRange: weightRange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSummary(BuildContext context) {
    if (weightRecords.isEmpty) return const SizedBox.shrink();

    final currentWeight = weightRecords.first.weight;
    final previousWeight = weightRecords.length > 1 ? weightRecords[1].weight : currentWeight;
    final weightChange = currentWeight - previousWeight;
    final weightChangePercent = (weightChange / previousWeight * 100);
    
    final isWeightGain = weightChange > 0;
    final isWeightLoss = weightChange < 0;
    final isStable = weightChange == 0;

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
            'Current Status',
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
                  'Current Weight',
                  '${currentWeight.toStringAsFixed(1)} kg',
                  Icons.monitor_weight,
                  AppTheme.heartPink,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Change',
                  isStable 
                    ? 'No change'
                    : '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                  isWeightGain ? Icons.trending_up : Icons.trending_down,
                  isWeightGain ? AppTheme.leafGreen : AppTheme.heartPink,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Percentage',
                  isStable 
                    ? '0%'
                    : '${weightChangePercent > 0 ? '+' : ''}${weightChangePercent.toStringAsFixed(1)}%',
                  isWeightGain ? Icons.trending_up : Icons.trending_down,
                  isWeightGain ? AppTheme.leafGreen : AppTheme.heartPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
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

  Widget _buildEmptyState() {
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
              Icons.monitor_weight,
              color: AppTheme.heartPink,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No weight records yet',
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
              'Start tracking your pet\'s weight to monitor their health',
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

  Widget _buildWeightRecordCard(WeightRecord record, BuildContext context) {
    final isLatest = weightRecords.indexOf(record) == 0;
    
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
          onTap: () => onEditWeight(record),
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Row(
              children: [
                // Weight Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLatest ? AppTheme.heartPink.withOpacity(0.2) : AppTheme.softPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.smRadius),
                  ),
                  child: Icon(
                    Icons.monitor_weight,
                    color: isLatest ? AppTheme.heartPink : AppTheme.softPink,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: AppConstants.mdSpacing),
                
                // Weight Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${record.weight.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.warmGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLatest) ...[
                            const SizedBox(width: AppConstants.smSpacing),
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
                                'Latest',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppConstants.xsSpacing),
                      Text(
                        _formatDate(record.date),
                        style: TextStyle(
                          color: AppTheme.warmGrey.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      if (record.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: AppConstants.xsSpacing),
                        Text(
                          record.notes!,
                          style: TextStyle(
                            color: AppTheme.warmGrey.withOpacity(0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Edit Icon
                Icon(
                  Icons.edit,
                  color: AppTheme.warmGrey.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation);
  }

  Widget _buildWeightGuidelines(BuildContext context) {
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
            'Weight Guidelines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          
          _buildGuidelineItem(
            'Healthy Weight Range',
            'Based on breed and age standards',
            Icons.check_circle,
            AppTheme.leafGreen,
          ),
          _buildGuidelineItem(
            'Weight Gain',
            'Monitor for overfeeding or health issues',
            Icons.trending_up,
            AppTheme.heartPink,
          ),
          _buildGuidelineItem(
            'Weight Loss',
            'Check for appetite changes or illness',
            Icons.trending_down,
            AppTheme.softPurple,
          ),
          _buildGuidelineItem(
            'Consistent Monitoring',
            'Weigh monthly for accurate tracking',
            Icons.schedule,
            AppTheme.lightPink,
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

// Weight Chart Painter
class WeightChartPainter extends CustomPainter {
  final List<WeightRecord> weightRecords;
  final double minWeight;
  final double maxWeight;
  final double weightRange;

  WeightChartPainter({
    required this.weightRecords,
    required this.minWeight,
    required this.maxWeight,
    required this.weightRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weightRecords.length < 2) return;

    final paint = Paint()
      ..color = AppTheme.heartPink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.heartPink.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final width = size.width;
    final height = size.height;
    final stepX = width / (weightRecords.length - 1);

    // Start the paths
    final firstY = height - ((weightRecords[0].weight - minWeight) / weightRange) * height;
    path.moveTo(0, firstY);
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, firstY);

    // Draw the line and fill path
    for (int i = 1; i < weightRecords.length; i++) {
      final x = i * stepX;
      final y = height - ((weightRecords[i].weight - minWeight) / weightRange) * height;
      
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Complete the fill path
    fillPath.lineTo(width, height);
    fillPath.close();

    // Draw the fill first
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw the line on top
    canvas.drawPath(path, paint);

    // Draw data points
    for (int i = 0; i < weightRecords.length; i++) {
      final x = i * stepX;
      final y = height - ((weightRecords[i].weight - minWeight) / weightRange) * height;
      
      final pointPaint = Paint()
        ..color = AppTheme.heartPink
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      
      // Add a white center to make it look like a ring
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 2, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

