import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/ai_models.dart';

class EmotionRecognitionWidget extends StatefulWidget {
  final Pet pet;

  const EmotionRecognitionWidget({super.key, required this.pet});

  @override
  State<EmotionRecognitionWidget> createState() => _EmotionRecognitionWidgetState();
}

class _EmotionRecognitionWidgetState extends State<EmotionRecognitionWidget> {
  List<Map<String, dynamic>> _emotionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadEmotionHistory();
  }

  void _loadEmotionHistory() {
    // Mock data - in real app, this would come from AI service
    _emotionHistory = [
      {
        'emotion': PetEmotion.happy,
        'confidence': 0.89,
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'imageUrl': 'assets/images/happy_pet.jpg',
        'context': 'After playtime session',
      },
      {
        'emotion': PetEmotion.calm,
        'confidence': 0.76,
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'imageUrl': 'assets/images/calm_pet.jpg',
        'context': 'During grooming session',
      },
      {
        'emotion': PetEmotion.excited,
        'confidence': 0.92,
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'imageUrl': 'assets/images/excited_pet.jpg',
        'context': 'Before meal time',
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
          _buildEmotionSummary(),
          const SizedBox(height: 24),
          _buildAnalyzeNewPhoto(),
          const SizedBox(height: 24),
          _buildEmotionHistory(),
        ],
      ),
    );
  }

  Widget _buildEmotionSummary() {
    final recentEmotion = _emotionHistory.isNotEmpty ? _emotionHistory.first : null;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  'Current Mood',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentEmotion != null) ...[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getEmotionColor(recentEmotion['emotion']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getEmotionIcon(recentEmotion['emotion']),
                      color: _getEmotionColor(recentEmotion['emotion']),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getEmotionText(recentEmotion['emotion']),
                          style: AppTheme.textStyles.headlineMedium?.copyWith(
                            color: AppTheme.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(recentEmotion['confidence'] * 100).toInt()}% confident',
                          style: AppTheme.textStyles.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                        Text(
                          recentEmotion['context'],
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No recent emotion data available',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeNewPhoto() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyze New Photo',
              style: AppTheme.textStyles.titleLarge?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.colors.outline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: AppTheme.colors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to take or select a photo',
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _analyzePhoto();
                    },
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Analyze Emotion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emotion History',
              style: AppTheme.textStyles.titleLarge?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._emotionHistory.map((emotion) => _buildEmotionHistoryCard(emotion)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionHistoryCard(Map<String, dynamic> emotion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getEmotionColor(emotion['emotion']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _getEmotionIcon(emotion['emotion']),
              color: _getEmotionColor(emotion['emotion']),
              size: 25,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEmotionText(emotion['emotion']),
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    color: AppTheme.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  emotion['context'],
                  style: AppTheme.textStyles.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                Text(
                  '${(emotion['confidence'] * 100).toInt()}% confident • ${_formatTime(emotion['timestamp'])}',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  void _analyzePhoto() {
    // TODO: Implement photo analysis
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo analysis feature coming soon!'),
        backgroundColor: AppTheme.colors.primary,
      ),
    );
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
