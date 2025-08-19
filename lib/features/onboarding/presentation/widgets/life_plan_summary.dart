import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/onboarding_models.dart';
import 'package:intl/intl.dart';

class LifePlanSummary extends StatefulWidget {
  final OnboardingData onboardingData;

  const LifePlanSummary({
    super.key,
    required this.onboardingData,
  });

  @override
  State<LifePlanSummary> createState() => _LifePlanSummaryState();
}

class _LifePlanSummaryState extends State<LifePlanSummary>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _recommendations = [];
  final List<String> _nextSteps = [];
  final Map<String, dynamic> _personalizedMetrics = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _generateLifePlan();
    _animationController.forward();
  }

  void _generateLifePlan() {
    // Generate personalized recommendations based on onboarding data
    _generateRecommendations();
    _generateNextSteps();
    _generatePersonalizedMetrics();
  }

  void _generateRecommendations() {
    final petType = widget.onboardingData.petType;
    final petName = widget.onboardingData.petName;
    final goals = widget.onboardingData.primaryGoals;
    final challenges = widget.onboardingData.currentChallenges;
    final healthStatus = widget.onboardingData.petHealthStatus;
    final stressLevel = widget.onboardingData.ownerStressLevel;

    // Health-focused recommendations
    if (healthStatus != null && healthStatus <= 3) {
      _recommendations.add('Schedule a comprehensive health checkup within the next 2 weeks');
      _recommendations.add('Implement daily health monitoring routines');
    }

    // Stress reduction recommendations
    if (stressLevel != null && stressLevel >= 4) {
      _recommendations.add('Start with 10-minute daily mindfulness sessions with ${petName ?? 'your pet'}');
      _recommendations.add('Create a structured daily routine to reduce care-related anxiety');
    }

    // Goal-specific recommendations
    if (goals != null) {
      if (goals.contains('Improve pet health and fitness')) {
        _recommendations.add('Begin with 15-minute daily exercise sessions, gradually increasing to 30 minutes');
        _recommendations.add('Track ${petName ?? 'your pet'}\'s activity levels and energy patterns');
      }
      
      if (goals.contains('Reduce my stress and anxiety')) {
        _recommendations.add('Practice 5-minute breathing exercises before each pet interaction');
        _recommendations.add('Schedule dedicated bonding time without distractions');
      }
      
      if (goals.contains('Build pet\'s social circle')) {
        _recommendations.add('Start with controlled introductions to new pets and people');
        _recommendations.add('Join local pet groups or visit dog parks during off-peak hours');
      }
    }

    // Challenge-specific recommendations
    if (challenges != null) {
      if (challenges.contains('Forget vet appointments')) {
        _recommendations.add('Set up automated reminders for all health-related appointments');
        _recommendations.add('Create a health calendar with visual cues');
      }
      
      if (challenges.contains('Anxious about pet aging')) {
        _recommendations.add('Learn about age-appropriate care for ${petType ?? 'your pet'}');
        _recommendations.add('Focus on quality of life improvements rather than age concerns');
      }
    }

    // Default recommendations
    if (_recommendations.isEmpty) {
      _recommendations.add('Start with daily 10-minute bonding sessions');
      _recommendations.add('Establish a consistent feeding and exercise schedule');
      _recommendations.add('Begin tracking ${petName ?? 'your pet'}\'s daily activities and mood');
    }
  }

  void _generateNextSteps() {
    _nextSteps.add('Complete your pet\'s profile with photos and detailed information');
    _nextSteps.add('Set up your first wellness reminder');
    _nextSteps.add('Explore the mindfulness and bonding exercises');
    _nextSteps.add('Connect with the Serenyx community');
    _nextSteps.add('Schedule your first health tracking session');
  }

  void _generatePersonalizedMetrics() {
    final petAge = widget.onboardingData.petAge;
    final petType = widget.onboardingData.petType;
    final healthStatus = widget.onboardingData.petHealthStatus;
    final stressLevel = widget.onboardingData.ownerStressLevel;
    final timeAvailable = widget.onboardingData.timeAvailability;
    final commitment = widget.onboardingData.commitmentLevel;

    // Life stage calculation
    if (petAge != null) {
      final ageInYears = petAge / 12;
      if (petType == 'Dog') {
        if (ageInYears < 1) {
          _personalizedMetrics['lifeStage'] = 'Puppy';
          _personalizedMetrics['lifeStageDescription'] = 'Early development and training phase';
        } else if (ageInYears < 7) {
          _personalizedMetrics['lifeStage'] = 'Adult';
          _personalizedMetrics['lifeStageDescription'] = 'Prime health and activity years';
        } else {
          _personalizedMetrics['lifeStage'] = 'Senior';
          _personalizedMetrics['lifeStageDescription'] = 'Specialized care and comfort focus';
        }
      } else if (petType == 'Cat') {
        if (ageInYears < 1) {
          _personalizedMetrics['lifeStage'] = 'Kitten';
          _personalizedMetrics['lifeStageDescription'] = 'Growth and socialization phase';
        } else if (ageInYears < 11) {
          _personalizedMetrics['lifeStage'] = 'Adult';
          _personalizedMetrics['lifeStageDescription'] = 'Stable health and routine years';
        } else {
          _personalizedMetrics['lifeStage'] = 'Senior';
          _personalizedMetrics['lifeStageDescription'] = 'Gentle care and comfort focus';
        }
      }
    }

    // Wellness score
    int wellnessScore = 50; // Base score
    if (healthStatus != null) {
      wellnessScore += (healthStatus - 3) * 10; // Adjust based on health rating
    }
    if (stressLevel != null) {
      wellnessScore += (5 - stressLevel) * 5; // Lower stress = higher score
    }
    if (commitment != null) {
      wellnessScore += (commitment - 3) * 5; // Higher commitment = higher score
    }
    
    _personalizedMetrics['wellnessScore'] = wellnessScore.clamp(0, 100);
    _personalizedMetrics['wellnessLevel'] = _getWellnessLevel(_personalizedMetrics['wellnessScore']);

    // Time optimization
    if (timeAvailable != null) {
      switch (timeAvailable) {
        case '15-30 minutes':
          _personalizedMetrics['dailyRoutine'] = 'Quick bonding and health check';
          _personalizedMetrics['focusAreas'] = ['Efficient exercise', 'Quick health monitoring', 'Mindful interactions'];
          break;
        case '30-60 minutes':
          _personalizedMetrics['dailyRoutine'] = 'Balanced care and training';
          _personalizedMetrics['focusAreas'] = ['Structured exercise', 'Training sessions', 'Health tracking'];
          break;
        case '1-2 hours':
          _personalizedMetrics['dailyRoutine'] = 'Comprehensive wellness program';
          _personalizedMetrics['focusAreas'] = ['Extended activities', 'Socialization', 'Advanced training'];
          break;
        case '2+ hours':
          _personalizedMetrics['dailyRoutine'] = 'Premium wellness experience';
          _personalizedMetrics['focusAreas'] = ['Luxury care', 'Extensive training', 'Community activities'];
          break;
        default:
          _personalizedMetrics['dailyRoutine'] = 'Flexible wellness approach';
          _personalizedMetrics['focusAreas'] = ['Adaptive routines', 'Health monitoring', 'Quality time'];
      }
    }

    // Personalized insights
    _personalizedMetrics['keyInsights'] = [
      'Your commitment level suggests great potential for success',
      'Focus on building consistent daily routines',
      'Mindfulness practices will enhance your bond',
      'Regular health tracking will provide valuable insights',
    ];
  }

  String _getWellnessLevel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // Wellness Score
              _buildWellnessScore(),
              
              const SizedBox(height: 24),
              
              // Life Stage Info
              _buildLifeStageInfo(),
              
              const SizedBox(height: 24),
              
              // Recommendations
              _buildRecommendations(),
              
              const SizedBox(height: 24),
              
              // Next Steps
              _buildNextSteps(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.colors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.celebration,
                size: 60,
                color: AppTheme.colors.success,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Your Pet Life Plan is Ready!',
              style: AppTheme.textStyles.headlineMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Congratulations on completing your wellness consultation! Here\'s your personalized plan for ${widget.onboardingData.petName ?? 'your pet'}\'s best life.',
              style: AppTheme.textStyles.bodyLarge?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessScore() {
    final score = _personalizedMetrics['wellnessScore'] ?? 0;
    final level = _personalizedMetrics['wellnessLevel'] ?? 'Good';
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colors.outline),
        ),
        child: Column(
          children: [
            Text(
              'Your Wellness Score',
              style: AppTheme.textStyles.titleLarge?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: AppTheme.colors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(score),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      score.toString(),
                      style: AppTheme.textStyles.headlineLarge?.copyWith(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      level,
                      style: AppTheme.textStyles.titleSmall?.copyWith(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'This score reflects your current wellness foundation and potential for improvement.',
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

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.colors.success;
    if (score >= 60) return AppTheme.colors.primary;
    if (score >= 40) return AppTheme.colors.warning;
    return AppTheme.colors.error;
  }

  Widget _buildLifeStageInfo() {
    final lifeStage = _personalizedMetrics['lifeStage'];
    final description = _personalizedMetrics['lifeStageDescription'];
    
    if (lifeStage == null) return const SizedBox.shrink();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colors.primary),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: AppTheme.colors.primary,
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Life Stage: $lifeStage',
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
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

  Widget _buildRecommendations() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Recommendations',
            style: AppTheme.textStyles.titleLarge?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._recommendations.map((recommendation) => 
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.colors.outline),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.colors.primary,
                    size: 24,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Next Steps',
            style: AppTheme.textStyles.titleLarge?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._nextSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.colors.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Text(
                      step,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Start Journey Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to main app
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start Your Wellness Journey',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Share Plan Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Share plan functionality
                _sharePlan();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.colors.primary,
                side: BorderSide(color: AppTheme.colors.primary),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Share Your Plan',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePlan() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing your personalized plan...'),
        backgroundColor: AppTheme.colors.primary,
      ),
    );
  }
}