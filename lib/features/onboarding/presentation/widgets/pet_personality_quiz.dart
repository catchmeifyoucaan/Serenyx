import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/achievement_unlock.dart';

class PetPersonalityQuiz extends StatefulWidget {
  const PetPersonalityQuiz({super.key});

  @override
  State<PetPersonalityQuiz> createState() => _PetPersonalityQuizState();
}

class _PetPersonalityQuizState extends State<PetPersonalityQuiz>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _questionController;
  late AnimationController _answerController;
  
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  List<String> _selectedTraits = [];
  
  final List<PersonalityQuestion> _questions = [
    PersonalityQuestion(
      id: 'energy_level',
      question: "How would you describe your pet's energy level?",
      options: [
        PersonalityOption(
          id: 'high_energy',
          text: 'Very energetic - always ready to play!',
          icon: Icons.flash_on,
          color: AppTheme.accent,
          traits: ['energetic', 'playful', 'active'],
        ),
        PersonalityOption(
          id: 'moderate_energy',
          text: 'Moderate - enjoys both play and rest',
          icon: Icons.balance,
          color: AppTheme.secondary,
          traits: ['balanced', 'adaptable', 'social'],
        ),
        PersonalityOption(
          id: 'low_energy',
          text: 'Calm and relaxed - prefers quiet time',
          icon: Icons.spa,
          color: AppTheme.primary,
          traits: ['calm', 'gentle', 'peaceful'],
        ),
      ],
    ),
    PersonalityQuestion(
      id: 'social_style',
      question: "How does your pet interact with others?",
      options: [
        PersonalityOption(
          id: 'very_social',
          text: 'Extremely friendly - loves everyone!',
          icon: Icons.favorite,
          color: AppTheme.primary,
          traits: ['friendly', 'outgoing', 'loving'],
        ),
        PersonalityOption(
          id: 'selective_social',
          text: 'Selective - bonds with specific people',
          icon: Icons.people,
          color: AppTheme.secondary,
          traits: ['loyal', 'protective', 'selective'],
        ),
        PersonalityOption(
          id: 'independent',
          text: 'Independent - enjoys alone time',
          icon: Icons.self_improvement,
          color: AppTheme.accent,
          traits: ['independent', 'confident', 'self-assured'],
        ),
      ],
    ),
    PersonalityQuestion(
      id: 'learning_style',
      question: "How does your pet learn new things?",
      options: [
        PersonalityOption(
          id: 'quick_learner',
          text: 'Learns quickly - picks up commands fast',
          icon: Icons.psychology,
          color: AppTheme.accent,
          traits: ['intelligent', 'quick_learner', 'focused'],
        ),
        PersonalityOption(
          id: 'patient_learner',
          text: 'Patient - needs time but gets it right',
          icon: Icons.timer,
          color: AppTheme.secondary,
          traits: ['patient', 'determined', 'careful'],
        ),
        PersonalityOption(
          id: 'playful_learner',
          text: 'Learns through play and fun',
          icon: Icons.sports_esports,
          color: AppTheme.primary,
          traits: ['playful', 'creative', 'fun-loving'],
        ),
      ],
    ),
    PersonalityQuestion(
      id: 'comfort_zone',
      question: "What makes your pet most comfortable?",
      options: [
        PersonalityOption(
          id: 'routine',
          text: 'Consistent routine and structure',
          icon: Icons.schedule,
          color: AppTheme.secondary,
          traits: ['organized', 'reliable', 'structured'],
        ),
        PersonalityOption(
          id: 'adventure',
          text: 'New experiences and adventures',
          icon: Icons.explore,
          color: AppTheme.accent,
          traits: ['adventurous', 'curious', 'explorer'],
        ),
        PersonalityOption(
          id: 'comfort',
          text: 'Familiar places and cozy spots',
          icon: Icons.home,
          color: AppTheme.primary,
          traits: ['comfortable', 'content', 'homebody'],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _questionController = AnimationController(
      duration: AppTheme.durationSlow,
      vsync: this,
    );
    _answerController = AnimationController(
      duration: AppTheme.durationNormal,
      vsync: this,
    );
    
    _startQuiz();
  }

  void _startQuiz() async {
    // Haptic feedback for quiz start
    AppTheme.mediumImpact();
    
    // Animate first question in
    _questionController.forward();
  }

  void _selectAnswer(String questionId, PersonalityOption option) async {
    // Haptic feedback for selection
    AppTheme.lightImpact();
    
    setState(() {
      _answers[questionId] = option.id;
      _selectedTraits.addAll(option.traits);
    });
    
    // Animate answer selection
    _answerController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Move to next question or finish
    if (_currentQuestionIndex < _questions.length - 1) {
      _nextQuestion();
    } else {
      _finishQuiz();
    }
  }

  void _nextQuestion() async {
    setState(() {
      _currentQuestionIndex++;
    });
    
    // Haptic feedback for question transition
    AppTheme.lightImpact();
    
    // Reset animations
    _questionController.reset();
    _answerController.reset();
    
    // Animate to next question
    await _pageController.animateToPage(
      _currentQuestionIndex,
      duration: AppTheme.durationSlow,
      curve: AppTheme.easeInOutCubic,
    );
    
    // Start new question animation
    _questionController.forward();
  }

  void _finishQuiz() async {
    // Haptic feedback for completion
    AppTheme.heavyImpact();
    
    // Calculate personality profile
    final personalityProfile = _calculatePersonalityProfile();
    
    // Show achievement unlock
    await _showAchievementUnlock(personalityProfile);
    
    // Navigate to next step
    _navigateToNextStep(personalityProfile);
  }

  Map<String, dynamic> _calculatePersonalityProfile() {
    // Count trait frequencies
    final traitCounts = <String, int>{};
    for (final trait in _selectedTraits) {
      traitCounts[trait] = (traitCounts[trait] ?? 0) + 1;
    }
    
    // Get top traits
    final sortedTraits = traitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topTraits = sortedTraits.take(5).map((e) => e.key).toList();
    
    // Determine personality type
    String personalityType = 'balanced';
    if (topTraits.contains('energetic') && topTraits.contains('playful')) {
      personalityType = 'adventurer';
    } else if (topTraits.contains('calm') && topTraits.contains('gentle')) {
      personalityType = 'sage';
    } else if (topTraits.contains('friendly') && topTraits.contains('loving')) {
      personalityType = 'companion';
    } else if (topTraits.contains('intelligent') && topTraits.contains('focused')) {
      personalityType = 'scholar';
    } else if (topTraits.contains('independent') && topTraits.contains('confident')) {
      personalityType = 'explorer';
    }
    
    return {
      'type': personalityType,
      'traits': topTraits,
      'answers': _answers,
    };
  }

  Future<void> _showAchievementUnlock(Map<String, dynamic> profile) async {
    final achievement = _getAchievementForProfile(profile);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  Achievement _getAchievementForProfile(Map<String, dynamic> profile) {
    final type = profile['type'] as String;
    
    final achievements = {
      'adventurer': Achievement(
        id: 'adventurer',
        title: 'Adventure Seeker',
        description: 'Your pet loves excitement and new experiences!',
        icon: Icons.explore,
        color: AppTheme.accent,
        rarity: 'rare',
      ),
      'sage': Achievement(
        id: 'sage',
        title: 'Wise Companion',
        description: 'Your pet brings calm wisdom to your life.',
        icon: Icons.spa,
        color: AppTheme.primary,
        rarity: 'rare',
      ),
      'companion': Achievement(
        id: 'companion',
        title: 'Loving Friend',
        description: 'Your pet\'s heart is full of love and friendship.',
        icon: Icons.favorite,
        color: AppTheme.primary,
        rarity: 'common',
      ),
      'scholar': Achievement(
        id: 'scholar',
        title: 'Quick Learner',
        description: 'Your pet\'s intelligence shines through!',
        icon: Icons.psychology,
        color: AppTheme.accent,
        rarity: 'rare',
      ),
      'explorer': Achievement(
        id: 'explorer',
        title: 'Independent Spirit',
        description: 'Your pet marches to their own beat.',
        icon: Icons.self_improvement,
        color: AppTheme.secondary,
        rarity: 'uncommon',
      ),
    };
    
    return achievements[type] ?? achievements['companion']!;
  }

  void _navigateToNextStep(Map<String, dynamic> profile) {
    // Navigate to pet setup with personality data
    Navigator.pushReplacementNamed(
      context,
      '/pet-setup',
      arguments: profile,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              // Questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestion(_questions[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfacePrimary,
              foregroundColor: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personality Quiz',
                  style: AppTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Let\'s discover your pet\'s unique personality',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.neutral200,
              borderRadius: AppTheme.radiusFull,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentQuestionIndex + 1) / _questions.length,
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
          
          // Question counter
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: AppTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(PersonalityQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: AnimatedBuilder(
        animation: _questionController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _questionController.value)),
            child: Opacity(
              opacity: _questionController.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Text(
                    question.question,
                    style: AppTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ).animate().slideInX(
                    begin: -0.3,
                    duration: AppTheme.durationNormal,
                    curve: AppTheme.easeOutBack,
                  ),
                  
                  const SizedBox(height: AppTheme.spacing40),
                  
                  // Options
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _answers[question.id] == option.id;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                      child: _buildOptionCard(
                        option: option,
                        isSelected: isSelected,
                        onTap: () => _selectAnswer(question.id, option),
                        delay: Duration(milliseconds: 200 * (index + 1)),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionCard({
    required PersonalityOption option,
    required bool isSelected,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        curve: AppTheme.easeInOutCubic,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: isSelected 
              ? option.color.withOpacity(0.1)
              : AppTheme.surfacePrimary,
          borderRadius: AppTheme.radiusLarge,
          border: Border.all(
            color: isSelected 
                ? option.color
                : AppTheme.neutral200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? AppTheme.shadowMedium
              : AppTheme.shadowSmall,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.1),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(
                option.icon,
                color: option.color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: AppTheme.spacing16),
            
            // Text
            Expanded(
              child: Text(
                option.text,
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? option.color
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: option.color,
                size: 24,
              ).animate().scale(
                begin: const Offset(0, 0),
                duration: AppTheme.durationFast,
                curve: AppTheme.easeOutBack,
              ),
          ],
        ),
      ).animate().slideInX(
        begin: 0.3,
        duration: AppTheme.durationNormal,
        delay: delay,
        curve: AppTheme.easeOutBack,
      ),
    );
  }
}

// Models
class PersonalityQuestion {
  final String id;
  final String question;
  final List<PersonalityOption> options;
  
  PersonalityQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class PersonalityOption {
  final String id;
  final String text;
  final IconData icon;
  final Color color;
  final List<String> traits;
  
  PersonalityOption({
    required this.id,
    required this.text,
    required this.icon,
    required this.color,
    required this.traits,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String rarity;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.rarity,
  });
}