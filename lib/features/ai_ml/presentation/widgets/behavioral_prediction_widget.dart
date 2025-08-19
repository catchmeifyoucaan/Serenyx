import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/ai_models.dart';

class BehavioralPredictionWidget extends StatefulWidget {
  final Pet pet;

  const BehavioralPredictionWidget({super.key, required this.pet});

  @override
  State<BehavioralPredictionWidget> createState() => _BehavioralPredictionWidgetState();
}

class _BehavioralPredictionWidgetState extends State<BehavioralPredictionWidget> {
  final List<BehavioralPrediction> _predictions = [];
  final List<BehavioralPattern> _patterns = [];
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _loadBehavioralData();
  }

  void _loadBehavioralData() {
    // Load real behavioral data from storage/database
    // For now, we'll start with empty lists for a clean slate
  }

  Future<void> _analyzeNewBehavior() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Simulate AI analysis (replace with actual AI service call)
      await Future.delayed(const Duration(seconds: 3));
      
      final prediction = BehavioralPrediction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        behavior: _generateRandomBehavior(),
        probability: _generateProbability(),
        timeframe: _generateTimeframe(),
        confidence: _generateConfidence(),
        timestamp: DateTime.now(),
        recommendations: _generateBehaviorRecommendations(),
        riskLevel: _generateRiskLevel(),
      );

      final pattern = BehavioralPattern(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        pattern: _generatePatternDescription(),
        frequency: _generateFrequency(),
        triggers: _generateTriggers(),
        impact: _generateImpact(),
        timestamp: DateTime.now(),
      );

      setState(() {
        _predictions.insert(0, prediction);
        _patterns.insert(0, pattern);
        _isAnalyzing = false;
      });

      _showAnalysisResults(prediction, pattern);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('Behavior analysis failed. Please try again.');
    }
  }

  String _generateRandomBehavior() {
    final behaviors = [
      'Increased vocalization',
      'Aggressive play behavior',
      'Separation anxiety signs',
      'Food guarding behavior',
      'Excessive grooming',
      'Destructive chewing',
      'Fear of loud noises',
      'Social withdrawal',
      'Hyperactivity',
      'Sleep pattern changes'
    ];
    return behaviors[DateTime.now().millisecond % behaviors.length];
  }

  double _generateProbability() {
    return 0.3 + (DateTime.now().millisecond % 70) / 100;
  }

  String _generateTimeframe() {
    final timeframes = [
      'Within 24 hours',
      'Within 3 days',
      'Within a week',
      'Within 2 weeks',
      'Within a month'
    ];
    return timeframes[DateTime.now().millisecond % timeframes.length];
  }

  double _generateConfidence() {
    return 0.6 + (DateTime.now().millisecond % 40) / 100;
  }

  List<String> _generateBehaviorRecommendations() {
    final recommendations = [
      'Increase daily exercise and mental stimulation',
      'Implement positive reinforcement training',
      'Create a consistent daily routine',
      'Provide safe spaces for retreat',
      'Consult with a professional trainer',
      'Monitor for any health issues',
      'Gradually expose to triggers',
      'Use calming techniques and pheromones'
    ];
    return recommendations.take(3).toList();
  }

  RiskLevel _generateRiskLevel() {
    final levels = [RiskLevel.low, RiskLevel.medium, RiskLevel.high];
    return levels[DateTime.now().millisecond % levels.length];
  }

  String _generatePatternDescription() {
    final patterns = [
      'Behavior occurs more frequently in the evening',
      'Triggered by specific sounds or movements',
      'More common when owner is away',
      'Associated with feeding times',
      'Influenced by weather conditions',
      'Related to social interactions',
      'Connected to physical activity levels',
      'Affected by environmental changes'
    ];
    return patterns[DateTime.now().millisecond % patterns.length];
  }

  String _generateFrequency() {
    final frequencies = [
      'Daily',
      '2-3 times per week',
      'Weekly',
      'Occasionally',
      'Seasonal'
    ];
    return frequencies[DateTime.now().millisecond % frequencies.length];
  }

  List<String> _generateTriggers() {
    final triggers = [
      'Loud noises',
      'Strangers',
      'Other animals',
      'Changes in routine',
      'New environments',
      'Separation from owner',
      'Physical discomfort',
      'Overstimulation'
    ];
    return triggers.take(2).toList();
  }

  String _generateImpact() {
    final impacts = [
      'Mild - manageable with training',
      'Moderate - requires intervention',
      'Significant - affects daily life',
      'Severe - needs professional help'
    ];
    return impacts[DateTime.now().millisecond % impacts.length];
  }

  void _showAnalysisResults(BehavioralPrediction prediction, BehavioralPattern pattern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Behavior Analysis Complete!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Predicted Behavior: ${prediction.behavior}'),
              const SizedBox(height: 8),
              Text('Probability: ${(prediction.probability * 100).toInt()}%'),
              Text('Timeframe: ${prediction.timeframe}'),
              Text('Risk Level: ${_getRiskLevelText(prediction.riskLevel)}'),
              const SizedBox(height: 16),
              Text('Pattern Detected:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(pattern.pattern),
              const SizedBox(height: 16),
              Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...prediction.recommendations.map((rec) => 
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• $rec', style: TextStyle(fontSize: 12)),
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
      ),
    );
  }

  String _getRiskLevelText(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  Color _getRiskLevelColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppTheme.colors.success;
      case RiskLevel.medium:
        return AppTheme.colors.warning;
      case RiskLevel.high:
        return AppTheme.colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildAnalysisSection(),
          const SizedBox(height: 24),
          _buildPredictionsSection(),
          const SizedBox(height: 24),
          _buildPatternsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Behavioral Prediction',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI-powered behavioral analysis to predict and understand your pet\'s behavior patterns.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Analyze Behavior Patterns',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get AI-powered insights into your pet\'s behavior and predictions for future actions.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeNewBehavior,
                icon: _isAnalyzing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.colors.onPrimary,
                          ),
                        ),
                      )
                    : Icon(Icons.psychology),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Behavior'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: AppTheme.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsSection() {
    if (_predictions.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.timeline,
                size: 64,
                color: AppTheme.colors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Predictions Yet',
                style: AppTheme.textStyles.headlineSmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start analyzing behavior to get AI-powered predictions and insights.',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Predictions',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._predictions.map((prediction) => _buildPredictionCard(prediction)),
      ],
    );
  }

  Widget _buildPredictionCard(BehavioralPrediction prediction) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskLevelColor(prediction.riskLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRiskLevelText(prediction.riskLevel),
                    style: TextStyle(
                      color: _getRiskLevelColor(prediction.riskLevel),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(prediction.probability * 100).toInt()}%',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prediction.behavior,
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expected: ${prediction.timeframe}',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommendations:',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...prediction.recommendations.map((rec) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.colors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildPatternsSection() {
    if (_patterns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Behavioral Patterns',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._patterns.map((pattern) => _buildPatternCard(pattern)),
      ],
    );
  }

  Widget _buildPatternCard(BehavioralPattern pattern) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pattern,
                  color: AppTheme.colors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pattern.pattern,
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPatternInfo('Frequency', pattern.frequency),
                const SizedBox(width: 24),
                _buildPatternInfo('Impact', pattern.impact),
              ],
            ),
            if (pattern.triggers.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Triggers: ${pattern.triggers.join(', ')}',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildPatternInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.textStyles.bodyMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
