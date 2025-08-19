import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../widgets/premium_analytics_dashboard.dart';
import '../widgets/unlimited_pet_profiles.dart';
import '../widgets/advanced_insights.dart';
import '../widgets/premium_subscription_plans.dart';

class PremiumFeaturesScreen extends StatefulWidget {
  final Pet pet;

  const PremiumFeaturesScreen({super.key, required this.pet});

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkPremiumStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkPremiumStatus() {
    // TODO: Check actual premium status from backend
    setState(() {
      _isPremiumUser = false; // Mock: user is not premium
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: Text(
          'Premium Features',
          style: AppTheme.textStyles.headlineMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.colors.textPrimary),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isPremiumUser 
                  ? AppTheme.colors.warning 
                  : AppTheme.colors.textSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isPremiumUser ? 'PREMIUM' : 'FREE',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.colors.primary,
          unselectedLabelColor: AppTheme.colors.textSecondary,
          indicatorColor: AppTheme.colors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.pets), text: 'Pet Profiles'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
            Tab(icon: Icon(Icons.star), text: 'Upgrade'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PremiumAnalyticsDashboard(pet: widget.pet, isPremium: _isPremiumUser),
          UnlimitedPetProfiles(isPremium: _isPremiumUser),
          AdvancedInsights(pet: widget.pet, isPremium: _isPremiumUser),
          PremiumSubscriptionPlans(
            onUpgrade: () {
              setState(() {
                _isPremiumUser = true;
              });
            },
          ),
        ],
      ),
    );
  }
}// Premium Features Screen
