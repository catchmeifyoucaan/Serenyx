import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class MoodTrendChart extends StatelessWidget {
  final List<double> moodTrend;
  final String timeRange;

  const MoodTrendChart({
    super.key,
    required this.moodTrend,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    if (moodTrend.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 200,
      child: Column(
        children: [
          // Chart
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: MoodTrendPainter(
                moodTrend: moodTrend,
                color: AppTheme.leafGreen,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(moodTrend.length, (index) {
              return Text(
                _getTimeLabel(index),
                style: TextStyle(
                  color: AppTheme.warmGrey.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
          
          const SizedBox(height: 8),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.leafGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Average Mood Rating',
                style: TextStyle(
                  color: AppTheme.warmGrey.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Mood scale
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1.0',
                style: TextStyle(
                  color: AppTheme.warmGrey.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '5.0',
                style: TextStyle(
                  color: AppTheme.warmGrey.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              color: AppTheme.warmGrey.withOpacity(0.3),
              size: 48,
            ),
            const SizedBox(height: AppConstants.smSpacing),
            Text(
              'No mood data yet',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            Text(
              'Rate your mood after sessions to see trends!',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeLabel(int index) {
    switch (timeRange) {
      case 'week':
        return 'Day ${index + 1}';
      case 'month':
        return 'Week ${index + 1}';
      case 'quarter':
        return 'Month ${index + 1}';
      case 'year':
        return 'Q${index + 1}';
      default:
        return 'Period ${index + 1}';
    }
  }
}

class MoodTrendPainter extends CustomPainter {
  final List<double> moodTrend;
  final Color color;

  MoodTrendPainter({
    required this.moodTrend,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (moodTrend.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final width = size.width;
    final height = size.height;
    final stepX = width / (moodTrend.length - 1);

    // Start the paths
    final firstY = height - (moodTrend[0] / 5.0) * height;
    path.moveTo(0, firstY);
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, firstY);

    // Draw the line and fill path
    for (int i = 1; i < moodTrend.length; i++) {
      final x = i * stepX;
      final y = height - (moodTrend[i] / 5.0) * height;
      
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
    for (int i = 0; i < moodTrend.length; i++) {
      final x = i * stepX;
      final y = height - (moodTrend[i] / 5.0) * height;
      
      final pointPaint = Paint()
        ..color = color
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