import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/onboarding_models.dart';
import '../widgets/onboarding_step_widget.dart';
import '../widgets/pet_wellness_consultation.dart';
import '../widgets/life_plan_summary.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;
  final OnboardingData _onboardingData = OnboardingData();
  bool _isLoading = false;

  final List<OnboardingStep> _steps = [
    // Step 1: Aspirational Welcome
    OnboardingStep(
      id: 1,
      title: "Your pet's happiest, healthiest life is within reach",
      subtitle: "Welcome to Serenyx - where every pet gets the care they deserve",
      description: "Let's create a personalized wellness plan that will transform your pet's life and strengthen your bond.",
      type: OnboardingStepType.welcome,
      image: "assets/images/onboarding/welcome_dog.png",
      showProgress: false,
    ),

    // Step 2: Pet Type Selection
    OnboardingStep(
      id: 2,
      title: "What type of pet do you have?",
      subtitle: "We'll customize everything for your specific companion",
      description: "Select the type of pet you'd like to care for with Serenyx.",
      type: OnboardingStepType.selection,
      image: "assets/images/onboarding/pet_types.png",
      options: ["Dog", "Cat", "Bird", "Fish", "Other"],
      showProgress: true,
    ),

    // Step 3: Pet Breed
    OnboardingStep(
      id: 3,
      title: "What's your pet's breed?",
      subtitle: "This helps us provide breed-specific health insights",
      description: "Knowing your pet's breed allows us to offer tailored health recommendations and care tips.",
      type: OnboardingStepType.input,
      image: "assets/images/onboarding/breed_selection.png",
      inputHint: "Enter breed (e.g., Golden Retriever, Persian Cat)",
      showProgress: true,
    ),

    // Step 4: Pet Name
    OnboardingStep(
      id: 4,
      title: "What's your pet's name?",
      subtitle: "Let's make this personal",
      description: "We'll use your pet's name throughout the app to create a personalized experience.",
      type: OnboardingStepType.input,
      image: "assets/images/onboarding/pet_name.png",
      inputHint: "Enter your pet's name",
      showProgress: true,
    ),

    // Step 5: Pet Age
    OnboardingStep(
      id: 5,
      title: "How old is your pet?",
      subtitle: "Age helps us track life stages and health milestones",
      description: "This information helps us provide age-appropriate care recommendations and track important milestones.",
      type: OnboardingStepType.ageInput,
      image: "assets/images/onboarding/age_selection.png",
      showProgress: true,
    ),

    // Step 6: Pet Photos
    OnboardingStep(
      id: 6,
      title: "Let's see your beautiful pet!",
      subtitle: "Photos help us personalize your experience",
      description: "Upload a few photos of your pet. We'll use these to create a personalized profile and track changes over time.",
      type: OnboardingStepType.photoUpload,
      image: "assets/images/onboarding/photo_upload.png",
      showProgress: true,
    ),

    // Step 7: Primary Goals
    OnboardingStep(
      id: 7,
      title: "What are your primary goals?",
      subtitle: "We'll focus on what matters most to you",
      description: "Select the areas you'd like to improve most for your pet's wellness journey.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/goals.png",
      options: [
        "Improve pet health and fitness",
        "Reduce my stress and anxiety",
        "Build pet's social circle",
        "Better training and behavior",
        "Track health metrics",
        "Create mindfulness routines"
      ],
      maxSelections: 3,
      showProgress: true,
    ),

    // Step 8: Current Challenges
    OnboardingStep(
      id: 8,
      title: "What challenges do you face?",
      subtitle: "Understanding your struggles helps us help you better",
      description: "Let us know what's been difficult so we can provide targeted solutions.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/challenges.png",
      options: [
        "Forget vet appointments",
        "Anxious about pet aging",
        "Struggle with pet anxiety",
        "Hard to maintain routines",
        "Worry about pet health",
        "Feel overwhelmed with care"
      ],
      maxSelections: 3,
      showProgress: true,
    ),

    // Step 9: Daily Routine
    OnboardingStep(
      id: 9,
      title: "What's your pet's daily routine like?",
      subtitle: "Understanding current habits helps us optimize",
      description: "Tell us about your pet's typical day so we can suggest improvements.",
      type: OnboardingStepType.routineInput,
      image: "assets/images/onboarding/daily_routine.png",
      showProgress: true,
    ),

    // Step 10: Mindfulness Practices
    OnboardingStep(
      id: 10,
      title: "How do you practice mindfulness?",
      subtitle: "We'll integrate these with pet bonding",
      description: "Your mindfulness practices can be enhanced through pet bonding activities.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/mindfulness.png",
      options: [
        "Meditation",
        "Deep breathing",
        "Yoga",
        "Nature walks",
        "Journaling",
        "I'm new to mindfulness"
      ],
      maxSelections: 2,
      showProgress: true,
    ),

    // Step 11: Pet Health Status
    OnboardingStep(
      id: 11,
      title: "How would you rate your pet's current health?",
      subtitle: "This helps us set realistic goals",
      description: "Be honest - we're here to help improve whatever the current situation.",
      type: OnboardingStepType.rating,
      image: "assets/images/onboarding/health_status.png",
      ratingLabels: ["Poor", "Fair", "Good", "Very Good", "Excellent"],
      showProgress: true,
    ),

    // Step 12: Owner Stress Level
    OnboardingStep(
      id: 12,
      title: "How stressed do you feel about pet care?",
      subtitle: "Your wellbeing matters too",
      description: "We'll help reduce your stress through better pet care routines and mindfulness practices.",
      type: OnboardingStepType.rating,
      image: "assets/images/onboarding/stress_level.png",
      ratingLabels: ["Very Low", "Low", "Moderate", "High", "Very High"],
      showProgress: true,
    ),

    // Step 13: Time Availability
    OnboardingStep(
      id: 13,
      title: "How much time can you dedicate daily?",
      subtitle: "We'll create realistic routines",
      description: "We'll design activities that fit your schedule and lifestyle.",
      type: OnboardingStepType.selection,
      image: "assets/images/onboarding/time_availability.png",
      options: [
        "15-30 minutes",
        "30-60 minutes",
        "1-2 hours",
        "2+ hours",
        "Varies daily"
      ],
      showProgress: true,
    ),

    // Step 14: Social Goals
    OnboardingStep(
      id: 14,
      title: "What are your social goals for your pet?",
      subtitle: "Building connections enriches lives",
      description: "Social interaction is crucial for your pet's mental and emotional wellbeing.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/social_goals.png",
      options: [
        "Play with other pets",
        "Meet new people",
        "Visit dog parks",
        "Join pet groups",
        "Attend training classes",
        "Home socialization only"
      ],
      maxSelections: 3,
      showProgress: true,
    ),

    // Step 15: Special Events
    OnboardingStep(
      id: 15,
      title: "Any special events coming up?",
      subtitle: "We'll help you prepare",
      description: "Planning for special occasions helps ensure your pet is ready and comfortable.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/special_events.png",
      options: [
        "Pet's birthday",
        "Vacation with pet",
        "Moving homes",
        "New family member",
        "Training milestones",
        "Health checkups"
      ],
      maxSelections: 2,
      showProgress: true,
    ),

    // Step 16: Pet Personality
    OnboardingStep(
      id: 16,
      title: "How would you describe your pet's personality?",
      subtitle: "Understanding temperament helps with care",
      description: "Personality traits influence how we approach training, socialization, and health routines.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/pet_personality.png",
      options: [
        "Energetic and playful",
        "Calm and relaxed",
        "Shy and reserved",
        "Confident and bold",
        "Curious and adventurous",
        "Loyal and protective"
      ],
      maxSelections: 3,
      showProgress: true,
    ),

    // Step 17: Health Concerns
    OnboardingStep(
      id: 17,
      title: "Any specific health concerns?",
      subtitle: "We'll create targeted care plans",
      description: "Knowing about health issues helps us provide better monitoring and care recommendations.",
      type: OnboardingStepType.multiSelection,
      image: "assets/images/onboarding/health_concerns.png",
      options: [
        "Weight management",
        "Joint health",
        "Dental care",
        "Skin conditions",
        "Allergies",
        "None currently"
      ],
      maxSelections: 2,
      showProgress: true,
    ),

    // Step 18: Lifestyle Preferences
    OnboardingStep(
      id: 18,
      title: "What's your preferred lifestyle approach?",
      subtitle: "We'll align with your values",
      description: "Your lifestyle preferences help us create routines that feel natural and sustainable.",
      type: OnboardingStepType.selection,
      image: "assets/images/onboarding/lifestyle.png",
      options: [
        "Active and outdoorsy",
        "Home-focused and cozy",
        "Social and community-oriented",
        "Minimalist and simple",
        "Luxury and premium care",
        "Balanced and moderate"
      ],
      showProgress: true,
    ),

    // Step 19: Commitment Level
    OnboardingStep(
      id: 19,
      title: "How committed are you to this journey?",
      subtitle: "Your dedication determines success",
      description: "We're here to support you every step of the way, no matter your commitment level.",
      type: OnboardingStepType.rating,
      image: "assets/images/onboarding/commitment.png",
      ratingLabels: ["Just exploring", "Somewhat interested", "Moderately committed", "Very committed", "All in!"],
      showProgress: true,
    ),

    // Step 20: Final Preparation
    OnboardingStep(
      id: 20,
      title: "Almost there! Let's create your Pet Life Plan",
      subtitle: "Your personalized wellness journey awaits",
      description: "We're analyzing all your responses to create a comprehensive, personalized plan for your pet's best life.",
      type: OnboardingStepType.final,
      image: "assets/images/onboarding/final_preparation.png",
      showProgress: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to life plan summary
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LifePlanSummary(
              onboardingData: _onboardingData,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateOnboardingData(String key, dynamic value) {
    setState(() {
      _onboardingData.updateData(key, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            _buildProgressHeader(),
            
            // Main Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return OnboardingStepWidget(
                    step: _steps[index],
                    onboardingData: _onboardingData,
                    onDataUpdate: _updateOnboardingData,
                    onNext: _nextStep,
                    onPrevious: _previousStep,
                    isLastStep: index == _steps.length - 1,
                    isLoading: _isLoading,
                  );
                },
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: AppTheme.colors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
            minHeight: 8,
          ),
          
          const SizedBox(height: 12),
          
          // Step Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Step ${_currentStep + 1} of ${_steps.length}",
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
              Text(
                "${((_currentStep + 1) / _steps.length * 100).toInt()}% Complete",
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Previous Button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.colors.primary,
                  side: BorderSide(color: AppTheme.colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          // Next/Complete Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentStep == _steps.length - 1 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}