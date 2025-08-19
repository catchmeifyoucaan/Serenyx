import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';

class AdvancedInsights extends StatelessWidget {
  final Pet pet;
  final bool isPremium;

  const AdvancedInsights({super.key, required this.pet, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (isPremium) _buildInsights() else _buildUpgradePrompt(),
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
                  Icons.lightbulb,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Advanced Insights',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI-powered insights and recommendations to optimize your pet\'s care and well-being.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
    return Column(
      children: [
        _buildInsightCard(
          'Health Trends',
          'Your pet\'s health metrics show a positive trend over the last 30 days',
          Icons.trending_up,
          Colors.green,
          'Continue current care routine',
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          'Behavioral Patterns',
          'Activity levels peak between 6-8 PM, consider evening exercise sessions',
          Icons.schedule,
          Colors.blue,
          'Schedule evening playtime',
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          'Nutrition Optimization',
          'Current diet provides 95% of recommended nutrients',
          Icons.restaurant,
          Colors.orange,
          'Diet is well-balanced',
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          'Social Interaction',
          'Social engagement has increased by 20% this month',
          Icons.people,
          Colors.purple,
          'Great progress!',
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color, String recommendation) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.colors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.colors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.colors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.success,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildUpgradePrompt() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              color: AppTheme.colors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock Advanced Insights',
              style: AppTheme.textStyles.headlineMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get AI-powered insights, personalized recommendations, and predictive analytics to optimize your pet\'s care.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle upgrade action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: AppTheme.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}