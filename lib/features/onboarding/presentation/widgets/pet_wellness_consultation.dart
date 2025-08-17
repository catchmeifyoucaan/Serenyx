import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/onboarding_models.dart';

class PetWellnessConsultation extends StatelessWidget {
  final OnboardingData consultationData;
  final VoidCallback onStartConsultation;

  const PetWellnessConsultation({
    super.key,
    required this.consultationData,
    required this.onStartConsultation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  size: 30,
                  color: AppTheme.colors.primary,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet Wellness Consultation',
                      style: AppTheme.textStyles.titleLarge?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Personalized care plan creation',
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Benefits
          _buildBenefits(),
          
          const SizedBox(height: 24),
          
          // What to expect
          _buildExpectations(),
          
          const SizedBox(height: 24),
          
          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Begin Consultation',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {
        'icon': Icons.auto_awesome,
        'title': 'Personalized Care',
        'description': 'Tailored recommendations based on your pet\'s unique needs',
      },
      {
        'icon': Icons.psychology,
        'title': 'Mindfulness Integration',
        'description': 'Reduce stress and strengthen your bond through mindful practices',
      },
      {
        'icon': Icons.timeline,
        'title': 'Life Stage Guidance',
        'description': 'Age-appropriate care and milestone tracking',
      },
      {
        'icon': Icons.health_and_safety,
        'title': 'Health Optimization',
        'description': 'Proactive health monitoring and preventive care',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What You\'ll Get',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...benefits.map((benefit) => 
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    benefit['icon'] as IconData,
                    size: 20,
                    color: AppTheme.colors.primary,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: AppTheme.textStyles.titleSmall?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        benefit['description'] as String,
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
        ),
      ],
    );
  }

  Widget _buildExpectations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What to Expect',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.colors.info),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.colors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '20 thoughtful questions',
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'The consultation takes about 5-10 minutes and covers everything from basic pet information to your wellness goals and challenges. Your responses help us create a truly personalized experience.',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}