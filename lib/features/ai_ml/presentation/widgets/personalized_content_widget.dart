import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/ai_models.dart';

class PersonalizedContentWidget extends StatefulWidget {
  final Pet pet;

  const PersonalizedContentWidget({super.key, required this.pet});

  @override
  State<PersonalizedContentWidget> createState() => _PersonalizedContentWidgetState();
}

class _PersonalizedContentWidgetState extends State<PersonalizedContentWidget> {
  final List<ContentRecommendation> _recommendations = [];
  final List<LearningPath> _learningPaths = [];
  final List<PersonalizedExperience> _experiences = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadPersonalizedContent();
  }

  void _loadPersonalizedContent() {
    // Load real personalized content from storage/database
    // For now, we'll start with empty lists for a clean slate
  }

  Future<void> _generatePersonalizedContent() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate AI content generation (replace with actual AI service call)
      await Future.delayed(const Duration(seconds: 3));
      
      final recommendation = ContentRecommendation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        type: _generateContentType(),
        title: _generateContentTitle(),
        description: _generateContentDescription(),
        category: _generateContentCategory(),
        difficulty: _generateDifficulty(),
        estimatedTime: _generateEstimatedTime(),
        tags: _generateTags(),
        timestamp: DateTime.now(),
        isRecommended: true,
        userRating: 0.0,
      );

      final learningPath = LearningPath(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        title: _generateLearningPathTitle(),
        description: _generateLearningPathDescription(),
        steps: _generateLearningSteps(),
        difficulty: _generateDifficulty(),
        estimatedDuration: _generatePathDuration(),
        progress: 0.0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final experience = PersonalizedExperience(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        type: _generateExperienceType(),
        title: _generateExperienceTitle(),
        description: _generateExperienceDescription(),
        activities: _generateExperienceActivities(),
        duration: _generateExperienceDuration(),
        mood: _generateMood(),
        timestamp: DateTime.now(),
      );

      setState(() {
        _recommendations.insert(0, recommendation);
        _learningPaths.insert(0, learningPath);
        _experiences.insert(0, experience);
        _isGenerating = false;
      });

      _showContentGenerated(recommendation, learningPath, experience);
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Content generation failed. Please try again.');
    }
  }

  ContentType _generateContentType() {
    final types = [ContentType.training, ContentType.health, ContentType.activity, ContentType.social];
    return types[DateTime.now().millisecond % types.length];
  }

  String _generateContentTitle() {
    final titles = [
      'Advanced Obedience Training',
      'Interactive Puzzle Games',
      'Socialization Exercises',
      'Health Monitoring Guide',
      'Behavioral Enrichment',
      'Physical Fitness Program'
    ];
    return titles[DateTime.now().millisecond % titles.length];
  }

  String _generateContentDescription() {
    final descriptions = [
      'Tailored training exercises designed specifically for your pet\'s learning style and current skill level.',
      'Brain-stimulating activities that challenge your pet\'s problem-solving abilities and keep them engaged.',
      'Structured social interactions to improve your pet\'s confidence and social skills in various environments.',
      'Comprehensive health tracking and monitoring techniques to ensure your pet\'s well-being.',
      'Activities designed to address specific behavioral needs and promote positive mental health.',
      'Customized exercise routines that match your pet\'s energy level and physical capabilities.'
    ];
    return descriptions[DateTime.now().millisecond % descriptions.length];
  }

  String _generateContentCategory() {
    final categories = ['Training', 'Health', 'Activity', 'Social', 'Behavior', 'Fitness'];
    return categories[DateTime.now().millisecond % categories.length];
  }

  Difficulty _generateDifficulty() {
    final difficulties = [Difficulty.beginner, Difficulty.intermediate, Difficulty.advanced];
    return difficulties[DateTime.now().millisecond % difficulties.length];
  }

  int _generateEstimatedTime() {
    return 20 + (DateTime.now().millisecond % 40);
  }

  List<String> _generateTags() {
    final allTags = [
      'training', 'health', 'exercise', 'social', 'behavior', 'enrichment',
      'puzzle', 'obedience', 'fitness', 'wellness', 'bonding', 'development'
    ];
    final selectedTags = <String>[];
    final random = DateTime.now().millisecond;
    
    for (int i = 0; i < 3; i++) {
      final index = (random + i) % allTags.length;
      if (!selectedTags.contains(allTags[index])) {
        selectedTags.add(allTags[index]);
      }
    }
    
    return selectedTags;
  }

  String _generateLearningPathTitle() {
    final titles = [
      'Complete Obedience Mastery',
      'Health & Wellness Journey',
      'Social Confidence Builder',
      'Behavioral Excellence Path',
      'Fitness & Agility Program'
    ];
    return titles[DateTime.now().millisecond % titles.length];
  }

  String _generateLearningPathDescription() {
    final descriptions = [
      'A comprehensive learning journey from basic commands to advanced obedience skills.',
      'Step-by-step guide to maintaining optimal health and preventing common issues.',
      'Progressive socialization program to build confidence in various situations.',
      'Systematic approach to addressing and improving behavioral patterns.',
      'Gradual fitness progression to build strength, agility, and endurance.'
    ];
    return descriptions[DateTime.now().millisecond % descriptions.length];
  }

  List<LearningStep> _generateLearningSteps() {
    return [
      LearningStep(
        id: '1',
        title: 'Foundation Skills',
        description: 'Build basic understanding and trust',
        duration: 15,
        isCompleted: false,
      ),
      LearningStep(
        id: '2',
        title: 'Intermediate Development',
        description: 'Expand skills and increase complexity',
        duration: 20,
        isCompleted: false,
      ),
      LearningStep(
        id: '3',
        title: 'Advanced Application',
        description: 'Master complex scenarios and challenges',
        duration: 25,
        isCompleted: false,
      ),
      LearningStep(
        id: '4',
        title: 'Real-world Practice',
        description: 'Apply skills in everyday situations',
        duration: 30,
        isCompleted: false,
      ),
    ];
  }

  int _generatePathDuration() {
    return 90 + (DateTime.now().millisecond % 60);
  }

  ExperienceType _generateExperienceType() {
    final types = [ExperienceType.training, ExperienceType.play, ExperienceType.social, ExperienceType.health];
    return types[DateTime.now().millisecond % types.length];
  }

  String _generateExperienceTitle() {
    final titles = [
      'Morning Training Session',
      'Interactive Play Time',
      'Socialization Adventure',
      'Health Check Routine',
      'Evening Bonding Session'
    ];
    return titles[DateTime.now().millisecond % titles.length];
  }

  String _generateExperienceDescription() {
    final descriptions = [
      'Personalized training activities designed for your pet\'s current skill level and learning pace.',
      'Engaging play activities that stimulate both physical and mental development.',
      'Controlled social interactions to build confidence and improve social skills.',
      'Regular health monitoring and preventive care activities.',
      'Quality bonding time with activities that strengthen your relationship.'
    ];
    return descriptions[DateTime.now().millisecond % descriptions.length];
  }

  List<String> _generateExperienceActivities() {
    final activities = [
      'Command practice',
      'Treat-based learning',
      'Interactive toys',
      'Social encounters',
      'Health monitoring',
      'Gentle grooming'
    ];
    return activities.take(3).toList();
  }

  int _generateExperienceDuration() {
    return 25 + (DateTime.now().millisecond % 35);
  }

  PetMood _generateMood() {
    final moods = [PetMood.happy, PetMood.excited, PetMood.calm, PetMood.curious];
    return moods[DateTime.now().millisecond % moods.length];
  }

  void _showContentGenerated(ContentRecommendation recommendation, LearningPath learningPath, PersonalizedExperience experience) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Personalized Content Generated!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Content: ${recommendation.title}'),
              const SizedBox(height: 8),
              Text('Category: ${recommendation.category}'),
              Text('Difficulty: ${_getDifficultyText(recommendation.difficulty)}'),
              Text('Time: ${recommendation.estimatedTime} minutes'),
              const SizedBox(height: 16),
              Text('Learning Path: ${learningPath.title}'),
              Text('Steps: ${learningPath.steps.length}'),
              Text('Duration: ${learningPath.estimatedDuration} minutes'),
              const SizedBox(height: 16),
              Text('Experience: ${experience.title}'),
              Text('Activities: ${experience.activities.join(', ')}'),
              Text('Duration: ${experience.duration} minutes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
      ),
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return AppTheme.colors.success;
      case Difficulty.intermediate:
        return AppTheme.colors.warning;
      case Difficulty.advanced:
        return AppTheme.colors.error;
    }
  }

  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.training:
        return AppTheme.colors.primary;
      case ContentType.health:
        return AppTheme.colors.success;
      case ContentType.activity:
        return AppTheme.colors.warning;
      case ContentType.social:
        return AppTheme.colors.secondary;
      case ContentType.behavior:
        return AppTheme.colors.info;
      case ContentType.fitness:
        return AppTheme.colors.error;
    }
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.training:
        return Icons.school;
      case ContentType.health:
        return Icons.health_and_safety;
      case ContentType.activity:
        return Icons.fitness_center;
      case ContentType.social:
        return Icons.people;
      case ContentType.behavior:
        return Icons.psychology;
      case ContentType.fitness:
        return Icons.directions_run;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildGenerationSection(),
          const SizedBox(height: 24),
          _buildRecommendationsSection(),
          const SizedBox(height: 24),
          _buildLearningPathsSection(),
          const SizedBox(height: 24),
          _buildExperiencesSection(),
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
                  Icons.person_pin,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Personalized Content',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI-generated content tailored specifically to your pet\'s needs, preferences, and learning style.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Generate Personalized Content',
              style: AppTheme.textStyles.headlineSmall?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get AI-powered content recommendations, learning paths, and personalized experiences designed specifically for your pet.',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePersonalizedContent,
                icon: _isGenerating 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.colors.onPrimary,
                          ),
                        ),
                      )
                    : Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Content'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: AppTheme.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_recommendations.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.recommend,
                size: 64,
                color: AppTheme.colors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Recommendations Yet',
                style: AppTheme.textStyles.headlineSmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start generating content to get personalized recommendations for your pet.',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Recommendations',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._recommendations.map((recommendation) => _buildRecommendationCard(recommendation)),
      ],
    );
  }

  Widget _buildRecommendationCard(ContentRecommendation recommendation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: _getContentTypeColor(recommendation.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getContentTypeIcon(recommendation.type),
                    color: _getContentTypeColor(recommendation.type),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        recommendation.category,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(recommendation.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyText(recommendation.difficulty),
                    style: TextStyle(
                      color: _getDifficultyColor(recommendation.difficulty),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              recommendation.description,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${recommendation.estimatedTime} min',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (recommendation.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: recommendation.tags.take(2).map((tag) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppTheme.colors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement content viewing
                    },
                    child: Text('View Content'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement content starting
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: AppTheme.colors.onPrimary,
                    ),
                    child: Text('Start'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildLearningPathsSection() {
    if (_learningPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Paths',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._learningPaths.map((path) => _buildLearningPathCard(path)),
      ],
    );
  }

  Widget _buildLearningPathCard(LearningPath path) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.title,
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${path.steps.length} steps • ${path.estimatedDuration} min',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(path.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyText(path.difficulty),
                    style: TextStyle(
                      color: _getDifficultyColor(path.difficulty),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              path.description,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: path.progress,
              backgroundColor: AppTheme.colors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '${(path.progress * 100).toInt()}% Complete',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement path continuation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
              ),
              child: Text('Continue Path'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildExperiencesSection() {
    if (_experiences.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Experiences',
          style: AppTheme.textStyles.headlineSmall?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._experiences.map((experience) => _buildExperienceCard(experience)),
      ],
    );
  }

  Widget _buildExperienceCard(PersonalizedExperience experience) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppTheme.colors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.title,
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${experience.duration} min • ${experience.activities.length} activities',
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
            Text(
              experience.description,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: experience.activities.map((activity) => 
                Chip(
                  label: Text(activity),
                  backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.colors.primary),
                ),
              ).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement experience start
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
              ),
              child: Text('Start Experience'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }
}
