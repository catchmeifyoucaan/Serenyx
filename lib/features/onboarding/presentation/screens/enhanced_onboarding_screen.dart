import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/onboarding_models.dart';
import '../widgets/pet_personality_quiz.dart';
import '../widgets/emotional_connection_builder.dart';
import '../widgets/storytelling_widget.dart';
import '../widgets/achievement_unlock.dart';

class EnhancedOnboardingScreen extends StatefulWidget {
  const EnhancedOnboardingScreen({super.key});

  @override
  State<EnhancedOnboardingScreen> createState() => _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState extends State<EnhancedOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late AnimationController _particleController;
  
  int _currentStep = 0;
  bool _isLoading = false;
  double _progress = 0.0;
  
  // Emotional state tracking
  String _userEmotionalState = 'excited';
  List<String> _userPreferences = [];
  Map<String, dynamic> _petPersonality = {};
  
  final List<OnboardingStory> _stories = [
    OnboardingStory(
      id: 'welcome',
      title: "Every pet deserves a hero",
      subtitle: "And every hero needs a companion",
      description: "Your journey to becoming the ultimate pet parent starts here. Let's create something extraordinary together.",
      backgroundImage: "assets/images/onboarding/hero_pet.jpg",
      mood: "inspiring",
      duration: const Duration(seconds: 4),
    ),
    OnboardingStory(
      id: 'connection',
      title: "The bond that changes everything",
      subtitle: "Understanding your pet's unique personality",
      description: "We'll discover what makes your pet special and create a care plan that celebrates their individuality.",
      backgroundImage: "assets/images/onboarding/pet_bond.jpg",
      mood: "warm",
      duration: const Duration(seconds: 5),
    ),
    OnboardingStory(
      id: 'transformation',
      title: "From good to extraordinary",
      subtitle: "AI-powered insights that transform care",
      description: "Watch as your pet's health, happiness, and behavior reach new heights with personalized AI guidance.",
      backgroundImage: "assets/images/onboarding/transformation.jpg",
      mood: "magical",
      duration: const Duration(seconds: 4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _backgroundController = AnimationController(
      duration: AppTheme.durationSlow,
      vsync: this,
    );
    _textController = AnimationController(
      duration: AppTheme.durationNormal,
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _startOnboarding();
  }

  void _startOnboarding() async {
    // Haptic feedback for start
    AppTheme.mediumImpact();
    
    // Start background animation
    _backgroundController.forward();
    
    // Begin storytelling sequence
    await _playStorySequence();
  }

  Future<void> _playStorySequence() async {
    for (int i = 0; i < _stories.length; i++) {
      await _showStory(_stories[i]);
      if (i < _stories.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    // Transition to personality quiz
    _navigateToPersonalityQuiz();
  }

  Future<void> _showStory(OnboardingStory story) async {
    setState(() {
      _currentStep = _stories.indexOf(story);
    });
    
    // Haptic feedback for story transition
    AppTheme.lightImpact();
    
    // Animate text in
    _textController.reset();
    _textController.forward();
    
    // Wait for story duration
    await Future.delayed(story.duration);
  }

  void _navigateToPersonalityQuiz() {
    setState(() {
      _isLoading = true;
    });
    
    // Haptic feedback for transition
    AppTheme.mediumImpact();
    
    // Navigate to personality quiz
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PetPersonalityQuiz(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppTheme.easeOutBack,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: AppTheme.durationSlow,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Story Content
          _buildStoryContent(),
          
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Skip Button
          _buildSkipButton(),
          
          // Particle Effects
          _buildParticleEffects(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    if (_currentStep >= _stories.length) return const SizedBox.shrink();
    
    final story = _stories[_currentStep];
    
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(story.backgroundImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4 * _backgroundController.value),
                BlendMode.darken,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: AppTheme.durationSlow);
  }

  Widget _buildStoryContent() {
    if (_currentStep >= _stories.length) return const SizedBox.shrink();
    
    final story = _stories[_currentStep];
    
    return Positioned(
      bottom: 120,
      left: AppTheme.spacing24,
      right: AppTheme.spacing24,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _textController.value)),
            child: Opacity(
              opacity: _textController.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood indicator
                  _buildMoodIndicator(story.mood),
                  
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Title
                  Text(
                    story.title,
                    style: AppTheme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().slideInX(
                    begin: -0.3,
                    duration: AppTheme.durationNormal,
                    curve: AppTheme.easeOutBack,
                  ),
                  
                  const SizedBox(height: AppTheme.spacing12),
                  
                  // Subtitle
                  Text(
                    story.subtitle,
                    style: AppTheme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().slideInX(
                    begin: -0.3,
                    duration: AppTheme.durationNormal,
                    delay: const Duration(milliseconds: 200),
                    curve: AppTheme.easeOutBack,
                  ),
                  
                  const SizedBox(height: AppTheme.spacing20),
                  
                  // Description
                  Text(
                    story.description,
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ).animate().slideInX(
                    begin: -0.3,
                    duration: AppTheme.durationNormal,
                    delay: const Duration(milliseconds: 400),
                    curve: AppTheme.easeOutBack,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodIndicator(String mood) {
    final moodData = {
      'inspiring': {
        'icon': Icons.star,
        'color': AppTheme.accent,
        'text': 'Inspiring',
      },
      'warm': {
        'icon': Icons.favorite,
        'color': AppTheme.primary,
        'text': 'Warm',
      },
      'magical': {
        'icon': Icons.auto_awesome,
        'color': AppTheme.secondary,
        'text': 'Magical',
      },
    };
    
    final data = moodData[mood] ?? moodData['inspiring']!;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: data['color']!.withOpacity(0.2),
        borderRadius: AppTheme.radiusFull,
        border: Border.all(
          color: data['color']!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data['icon'] as IconData,
            color: data['color'] as Color,
            size: 16,
          ),
          const SizedBox(width: AppTheme.spacing6),
          Text(
            data['text'] as String,
            style: AppTheme.textTheme.labelMedium?.copyWith(
              color: data['color'] as Color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      duration: AppTheme.durationNormal,
      curve: AppTheme.easeOutBack,
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppTheme.spacing20,
      left: AppTheme.spacing24,
      right: AppTheme.spacing24,
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppTheme.radiusFull,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / _stories.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.radiusFull,
                ),
              ),
            ),
          ).animate().scaleX(
            begin: 0,
            duration: AppTheme.durationNormal,
            curve: AppTheme.easeOutQuart,
          ),
          
          const SizedBox(height: AppTheme.spacing8),
          
          // Step indicator
          Text(
            '${_currentStep + 1} of ${_stories.length}',
            style: AppTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppTheme.spacing16,
      right: AppTheme.spacing24,
      child: TextButton(
        onPressed: _navigateToPersonalityQuiz,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
        ),
        child: Text(
          'Skip',
          style: AppTheme.textTheme.labelMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ).animate().fadeIn(
        duration: AppTheme.durationSlow,
        delay: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildParticleEffects() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              progress: _particleController.value,
              mood: _currentStep < _stories.length 
                  ? _stories[_currentStep].mood 
                  : 'inspiring',
            ),
          );
        },
      ),
    );
  }
}

// Particle animation painter
class ParticlePainter extends CustomPainter {
  final double progress;
  final String mood;
  
  ParticlePainter({
    required this.progress,
    required this.mood,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final particleCount = 20;
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < particleCount; i++) {
      final x = (random + i * 123) % size.width;
      final y = size.height - ((random + i * 456) % size.height * progress);
      
      final color = _getMoodColor(mood);
      paint.color = color.withOpacity(0.3);
      
      canvas.drawCircle(
        Offset(x, y),
        2 + (i % 3) * 2,
        paint,
      );
    }
  }
  
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'inspiring':
        return AppTheme.accent;
      case 'warm':
        return AppTheme.primary;
      case 'magical':
        return AppTheme.secondary;
      default:
        return AppTheme.accent;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Story model
class OnboardingStory {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String backgroundImage;
  final String mood;
  final Duration duration;
  
  OnboardingStory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.backgroundImage,
    required this.mood,
    required this.duration,
  });
}