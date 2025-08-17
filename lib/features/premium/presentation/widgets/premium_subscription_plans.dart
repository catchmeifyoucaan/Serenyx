import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumSubscriptionPlans extends StatelessWidget {
  final VoidCallback onUpgrade;

  const PremiumSubscriptionPlans({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPlans(),
          const SizedBox(height: 24),
          _buildFeatures(),
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
                  Icons.star,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Choose Your Plan',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select the perfect plan for your pet care needs and unlock premium features.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Column(
      children: [
        _buildPlanCard(
          'Monthly',
          '\$9.99',
          'month',
          'Perfect for trying out premium features',
          false,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          'Annual',
          '\$99.99',
          'year',
          'Best value - Save 17%',
          true,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          'Lifetime',
          '\$299.99',
          'one-time',
          'One-time payment, forever access',
          false,
        ),
      ],
    );
  }

  Widget _buildPlanCard(String title, String price, String period, String description, bool isRecommended) {
    return Card(
      elevation: isRecommended ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended 
            ? BorderSide(color: AppTheme.colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isRecommended) const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTheme.textStyles.displaySmall?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/$period',
                  style: AppTheme.textStyles.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecommended 
                      ? AppTheme.colors.primary 
                      : AppTheme.colors.surface,
                  foregroundColor: isRecommended 
                      ? AppTheme.colors.onPrimary 
                      : AppTheme.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isRecommended ? 'Choose Plan' : 'Select Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium Features Include:',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Unlimited pet profiles', Icons.pets),
            _buildFeatureItem('Advanced health analytics', Icons.analytics),
            _buildFeatureItem('AI-powered insights', Icons.psychology),
            _buildFeatureItem('Custom care schedules', Icons.schedule),
            _buildFeatureItem('Priority support', Icons.support_agent),
            _buildFeatureItem('Ad-free experience', Icons.block),
            _buildFeatureItem('Cloud backup', Icons.cloud),
            _buildFeatureItem('Family sharing', Icons.family_restroom),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.colors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: AppTheme.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}