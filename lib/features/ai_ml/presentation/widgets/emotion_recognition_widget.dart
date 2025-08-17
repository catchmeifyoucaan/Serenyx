import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/ai_models.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EmotionRecognitionWidget extends StatefulWidget {
  final Pet pet;

  const EmotionRecognitionWidget({super.key, required this.pet});

  @override
  State<EmotionRecognitionWidget> createState() => _EmotionRecognitionWidgetState();
}

class _EmotionRecognitionWidgetState extends State<EmotionRecognitionWidget> {
  final List<EmotionAnalysis> _emotions = [];
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _loadEmotionHistory();
  }

  void _loadEmotionHistory() {
    // Load real emotion history from storage/database
    // For now, we'll start with empty list
  }

  Future<void> _analyzePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _isAnalyzing = true;
      });

      try {
        // Simulate AI analysis (replace with actual AI service call)
        await Future.delayed(const Duration(seconds: 2));
        
        final analysis = EmotionAnalysis(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          petId: widget.pet.id,
          imagePath: image.path,
          emotion: _detectEmotionFromImage(image.path),
          confidence: _generateConfidence(),
          context: _generateContext(),
          timestamp: DateTime.now(),
          recommendations: _generateRecommendations(),
        );

        setState(() {
          _emotions.insert(0, analysis);
          _isAnalyzing = false;
        });

        _showAnalysisResults(analysis);
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
        });
        _showError('Analysis failed. Please try again.');
      }
    }
  }

  PetEmotion _detectEmotionFromImage(String imagePath) {
    // Simulate emotion detection based on image characteristics
    // In production, this would call an actual AI service
    final random = DateTime.now().millisecond % 6;
    switch (random) {
      case 0: return PetEmotion.happy;
      case 1: return PetEmotion.calm;
      case 2: return PetEmotion.excited;
      case 3: return PetEmotion.anxious;
      case 4: return PetEmotion.sad;
      default: return PetEmotion.neutral;
    }
  }

  double _generateConfidence() {
    // Simulate confidence score
    return 0.7 + (DateTime.now().millisecond % 30) / 100;
  }

  String _generateContext() {
    final contexts = [
      'During playtime',
      'After feeding',
      'During training',
      'In the garden',
      'At the park',
      'During cuddles',
      'Before bedtime',
      'After exercise'
    ];
    return contexts[DateTime.now().millisecond % contexts.length];
  }

  List<String> _generateRecommendations() {
    final recommendations = [
      'Continue current activities - your pet seems happy!',
      'Consider more playtime to boost mood',
      'Try calming activities if stress persists',
      'Schedule a vet check if behavior changes',
      'Increase social interaction opportunities',
      'Maintain regular exercise routine'
    ];
    return recommendations.take(2).toList();
  }

  void _showAnalysisResults(EmotionAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analysis Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Detected Emotion: ${_getEmotionText(analysis.emotion)}'),
            const SizedBox(height: 8),
            Text('Confidence: ${(analysis.confidence * 100).toInt()}%'),
            const SizedBox(height: 16),
            Text('Recommendations:'),
            ...analysis.recommendations.map((rec) => 
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $rec', style: TextStyle(fontSize: 12)),
              )
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPhotoAnalysis(),
          const SizedBox(height: 24),
          _buildEmotionHistory(),
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
                  Icons.face,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Emotion Recognition',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Analyze photos to understand your pet\'s emotional state and get personalized recommendations.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalysis() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Analyze Pet Photos',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload a photo of your pet to analyze their emotional state and receive personalized insights.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzePhoto,
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
                    : Icon(Icons.photo_library),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Select Photo'),
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

  Widget _buildEmotionHistory() {
    if (_emotions.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AppTheme.colors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Analysis History',
                style: AppTheme.textStyles.headlineSmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start analyzing photos to build a history of your pet\'s emotional patterns.',
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
          'Recent Analysis',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._emotions.map((emotion) => _buildEmotionCard(emotion)),
      ],
    );
  }

  Widget _buildEmotionCard(EmotionAnalysis emotion) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getEmotionColor(emotion.emotion).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getEmotionIcon(emotion.emotion),
                color: _getEmotionColor(emotion.emotion),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getEmotionText(emotion.emotion),
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emotion.context,
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(emotion.confidence * 100).toInt()}% confident • ${_formatTime(emotion.timestamp)}',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Color _getEmotionColor(PetEmotion emotion) {
    switch (emotion) {
      case PetEmotion.happy:
        return AppTheme.colors.success;
      case PetEmotion.calm:
        return AppTheme.colors.primary;
      case PetEmotion.excited:
        return AppTheme.colors.warning;
      case PetEmotion.anxious:
        return AppTheme.colors.error;
      case PetEmotion.sad:
        return AppTheme.colors.secondary;
      case PetEmotion.neutral:
        return AppTheme.colors.textSecondary;
    }
  }

  IconData _getEmotionIcon(PetEmotion emotion) {
    switch (emotion) {
      case PetEmotion.happy:
        return Icons.sentiment_very_satisfied;
      case PetEmotion.calm:
        return Icons.sentiment_satisfied;
      case PetEmotion.excited:
        return Icons.sentiment_very_satisfied;
      case PetEmotion.anxious:
        return Icons.sentiment_dissatisfied;
      case PetEmotion.sad:
        return Icons.sentiment_very_dissatisfied;
      case PetEmotion.neutral:
        return Icons.sentiment_neutral;
    }
  }

  String _getEmotionText(PetEmotion emotion) {
    switch (emotion) {
      case PetEmotion.happy:
        return 'Happy';
      case PetEmotion.calm:
        return 'Calm';
      case PetEmotion.excited:
        return 'Excited';
      case PetEmotion.anxious:
        return 'Anxious';
      case PetEmotion.sad:
        return 'Sad';
      case PetEmotion.neutral:
        return 'Neutral';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
