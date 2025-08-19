import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UnlimitedPetProfiles extends StatelessWidget {
  final bool isPremium;

  const UnlimitedPetProfiles({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (isPremium) _buildPremiumFeatures() else _buildUpgradePrompt(),
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
                  Icons.pets,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Unlimited Pet Profiles',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Create and manage unlimited pet profiles with advanced features and detailed tracking.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          'Advanced Health Tracking',
          'Comprehensive health monitoring with custom metrics and alerts',
          Icons.health_and_safety,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Behavioral Analysis',
          'AI-powered behavior insights and training recommendations',
          Icons.psychology,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Custom Reminders',
          'Personalized care schedules and medication reminders',
          Icons.notifications_active,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Social Features',
          'Connect with other pet owners and share moments',
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
            Icon(
              Icons.check_circle,
              color: AppTheme.colors.success,
              size: 20,
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
              'Upgrade to Premium',
              style: AppTheme.textStyles.headlineMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock unlimited pet profiles and advanced features to give your pets the best care possible.',
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
                child: const Text('Upgrade Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}