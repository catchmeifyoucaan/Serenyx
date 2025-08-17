import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/advanced_ai_service.dart';
import '../../../../shared/models/ai_models.dart';
import '../../../../shared/models/pet.dart';
import '../../../../core/theme/app_theme.dart';

class TrainingTrackingScreen extends StatefulWidget {
  const TrainingTrackingScreen({super.key});

  @override
  State<TrainingTrackingScreen> createState() => _TrainingTrackingScreenState();
}

class _TrainingTrackingScreenState extends State<TrainingTrackingScreen>
    with TickerProviderStateMixin {
  final List<TrainingSession> _trainingSessions = [];
  final List<String> _trainingGoals = [];
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _sessionNotesController = TextEditingController();
  
  Pet? _selectedPet;
  TrainingProgressAnalysis? _currentAnalysis;
  bool _isAnalyzing = false;
  String _selectedLanguage = 'en';
  String _selectedTrainingType = 'obedience';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _trainingTypes = [
    'obedience',
    'tricks',
    'socialization',
    'agility',
    'therapy',
    'sports',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _goalController.dispose();
    _sessionNotesController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Initialize demo pet
    _selectedPet = Pet(
      id: 'pet1',
      name: 'Luna',
      type: 'Dog',
      breed: 'Golden Retriever',
      age: 3,
      weight: 25.5,
      ownerId: 'user1',
    );

    // Initialize mock training goals
    _trainingGoals.addAll([
      'Master basic commands (sit, stay, come)',
      'Improve leash walking behavior',
      'Learn advanced tricks (roll over, play dead)',
      'Enhance socialization with other dogs',
      'Complete agility course training',
    ]);

    // Initialize mock training sessions
    _trainingSessions.addAll([
      TrainingSession(
        id: '1',
        petId: 'pet1',
        type: 'obedience',
        description: 'Basic command training - sit, stay, come',
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        duration: 30,
        goals: ['Master basic commands'],
        results: {
          'sit': 'Excellent',
          'stay': 'Good',
          'come': 'Fair',
        },
        successRate: 0.8,
      ),
      TrainingSession(
        id: '2',
        petId: 'pet1',
        type: 'socialization',
        description: 'Dog park visit - interaction with other dogs',
        startTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        endTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        duration: 60,
        goals: ['Enhance socialization'],
        results: {
          'friendly_approach': 'Excellent',
          'play_behavior': 'Good',
          'conflict_resolution': 'Good',
        },
        successRate: 0.9,
      ),
      TrainingSession(
        id: '3',
        petId: 'pet1',
        type: 'tricks',
        description: 'Advanced trick training - roll over, shake',
        startTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        endTime: DateTime.now().subtract(const Duration(days: 3, hours: 3, minutes: 15)),
        duration: 45,
        goals: ['Learn advanced tricks'],
        results: {
          'roll_over': 'Good',
          'shake': 'Excellent',
        },
        successRate: 0.85,
      ),
    ]);
  }

  void _addTrainingGoal() {
    if (_goalController.text.trim().isEmpty) return;
    
    setState(() {
      _trainingGoals.add(_goalController.text.trim());
      _goalController.clear();
    });
  }

  void _removeTrainingGoal(int index) {
    setState(() {
      _trainingGoals.removeAt(index);
    });
  }

  void _addTrainingSession() {
    if (_sessionNotesController.text.trim().isEmpty) return;
    
    final session = TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: _selectedPet!.id,
      type: _selectedTrainingType,
      description: _sessionNotesController.text.trim(),
      startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      endTime: DateTime.now(),
      duration: 30,
      goals: _trainingGoals.take(2).toList(), // Take first 2 goals
      results: {
        'overall_performance': 'Good',
        'engagement': 'High',
        'progress': 'Steady',
      },
      successRate: 0.75,
    );
    
    setState(() {
      _trainingSessions.add(session);
      _sessionNotesController.clear();
    });
  }

  Future<void> _analyzeTrainingProgress() async {
    if (_selectedPet == null) {
      _showSnackBar('Please select a pet first');
      return;
    }

    if (_trainingSessions.isEmpty) {
      _showSnackBar('No training sessions to analyze');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final aiService = context.read<AdvancedAIService>();
      final analysis = await aiService.analyzeTrainingProgress(
        pet: _selectedPet!,
        trainingSessions: _trainingSessions,
        goals: _trainingGoals,
        language: _selectedLanguage,
      );

      setState(() {
        _currentAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('Error analyzing training progress: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Training Progress Tracker'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Selection
                _buildPetSelector(),
                
                const SizedBox(height: 24),
                
                // Training Goals Section
                _buildTrainingGoalsSection(),
                
                const SizedBox(height: 24),
                
                // Add Training Session Section
                _buildAddSessionSection(),
                
                const SizedBox(height: 24),
                
                // Analysis Button
                _buildAnalysisButton(),
                
                const SizedBox(height: 24),
                
                // Results Section
                if (_currentAnalysis != null) _buildResultsSection(),
                
                const SizedBox(height: 24),
                
                // Training Sessions History
                _buildTrainingSessionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Pet',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedPet != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.colors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.colors.primary,
                      child: Text(
                        _selectedPet!.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPet!.name,
                            style: AppTheme.textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_selectedPet!.breed} • ${_selectedPet!.age} years old',
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
                        color: AppTheme.colors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_trainingSessions.length} sessions',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.success,
                          fontWeight: FontWeight.bold,
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

  Widget _buildTrainingGoalsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Training Goals',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Add Goal Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new training goal...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addTrainingGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Goals List
            if (_trainingGoals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 48,
                        color: AppTheme.colors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No training goals set yet',
                        style: AppTheme.textStyles.bodyLarge?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first training goal to get started',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trainingGoals.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.colors.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: AppTheme.colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _trainingGoals[index],
                              style: AppTheme.textStyles.bodyMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeTrainingGoal(index),
                            icon: const Icon(Icons.delete_outline),
                            color: AppTheme.colors.error,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSessionSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Training Session',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Training Type Selector
            DropdownButtonFormField<String>(
              value: _selectedTrainingType,
              decoration: const InputDecoration(
                labelText: 'Training Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _trainingTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.capitalize()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTrainingType = value ?? 'obedience';
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Session Notes
            TextField(
              controller: _sessionNotesController,
              decoration: const InputDecoration(
                labelText: 'Session Notes',
                hintText: 'Describe what you worked on, progress made, challenges...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Add Session Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addTrainingSession,
                icon: const Icon(Icons.add),
                label: const Text('Add Training Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isAnalyzing || _trainingSessions.isEmpty ? null : _analyzeTrainingProgress,
        icon: _isAnalyzing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.analytics),
        label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Training Progress'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: AppTheme.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_currentAnalysis == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Training Progress Analysis',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pattern Analysis
            _buildAnalysisCard(
              'Training Patterns',
              Icons.timeline,
              '${_currentAnalysis!.patternAnalysis.patterns.length} patterns identified',
              'Effectiveness: ${(_currentAnalysis!.patternAnalysis.patterns.isNotEmpty ? _currentAnalysis!.patternAnalysis.patterns.first.effectiveness * 100 : 0).toStringAsFixed(1)}%',
              _currentAnalysis!.patternAnalysis.patterns.map((p) => p.name).toList(),
              _currentAnalysis!.patternAnalysis.recommendations,
            ),
            
            const SizedBox(height: 16),
            
            // Strengths and Weaknesses
            Row(
              children: [
                Expanded(
                  child: _buildStrengthsCard(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeaknessesCard(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Metrics
            if (_currentAnalysis!.progressMetrics.isNotEmpty) ...[
              Text(
                'Progress Metrics',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._currentAnalysis!.progressMetrics.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').capitalize(),
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: AppTheme.colors.outline.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(entry.value),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(entry.value * 100).toStringAsFixed(1)}%',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            const SizedBox(height: 16),
            
            // Next Milestones
            if (_currentAnalysis!.nextMilestones.isNotEmpty) ...[
              Text(
                'Next Milestones',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._currentAnalysis!.nextMilestones.map((milestone) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.colors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: AppTheme.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          milestone,
                          style: AppTheme.textStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
            
            const SizedBox(height: 16),
            
            // Recommendations
            if (_currentAnalysis!.recommendations.isNotEmpty) ...[
              Text(
                'AI Recommendations',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._currentAnalysis!.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
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
                        Icons.lightbulb,
                        color: AppTheme.colors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rec,
                          style: AppTheme.textStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    String title,
    IconData icon,
    String mainValue,
    String subtitle,
    List<String> factors,
    List<String> recommendations,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mainValue,
            style: AppTheme.textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Key Factors:',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...factors.map((factor) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    size: 8,
                    color: AppTheme.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      factor,
                      style: AppTheme.textStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.colors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Strengths',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_currentAnalysis?.patternAnalysis.strengths.isNotEmpty == true)
            ..._currentAnalysis!.patternAnalysis.strengths.map((strength) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.colors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strength,
                      style: AppTheme.textStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ))
          else
            Text(
              'No specific strengths identified yet',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeaknessesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_down,
                color: AppTheme.colors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Areas for Improvement',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_currentAnalysis?.patternAnalysis.weaknesses.isNotEmpty == true)
            ..._currentAnalysis!.patternAnalysis.weaknesses.map((weakness) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 16,
                    color: AppTheme.colors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weakness,
                      style: AppTheme.textStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ))
          else
            Text(
              'No specific weaknesses identified',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainingSessionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Sessions History',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recent training sessions and progress tracking',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_trainingSessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: AppTheme.colors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No training sessions yet',
                        style: AppTheme.textStyles.bodyLarge?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first training session to start tracking progress',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trainingSessions.length,
                itemBuilder: (context, index) {
                  final session = _trainingSessions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.colors.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _getTrainingTypeColor(session.type).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getTrainingTypeIcon(session.type),
                                  size: 16,
                                  color: _getTrainingTypeColor(session.type),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.type.capitalize(),
                                      style: AppTheme.textStyles.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getTrainingTypeColor(session.type),
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(session.startTime),
                                      style: AppTheme.textStyles.bodySmall?.copyWith(
                                        color: AppTheme.colors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getSuccessRateColor(session.successRate).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(session.successRate * 100).toStringAsFixed(0)}%',
                                  style: AppTheme.textStyles.bodySmall?.copyWith(
                                    color: _getSuccessRateColor(session.successRate),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            session.description,
                            style: AppTheme.textStyles.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Duration: ${session.duration} minutes',
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', '🇺🇸'),
            _buildLanguageOption('es', 'Español', '🇪🇸'),
            _buildLanguageOption('fr', 'Français', '🇫🇷'),
            _buildLanguageOption('de', 'Deutsch', '🇩🇪'),
            _buildLanguageOption('ja', '日本語', '🇯🇵'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: _selectedLanguage == code
          ? Icon(Icons.check, color: AppTheme.colors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        Navigator.pop(context);
      },
    );
  }

  Color _getProgressColor(double value) {
    if (value >= 0.8) return AppTheme.colors.success;
    if (value >= 0.6) return AppTheme.colors.primary;
    if (value >= 0.4) return AppTheme.colors.warning;
    return AppTheme.colors.error;
  }

  Color _getTrainingTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'obedience':
        return AppTheme.colors.primary;
      case 'tricks':
        return AppTheme.colors.secondary;
      case 'socialization':
        return AppTheme.colors.success;
      case 'agility':
        return AppTheme.colors.warning;
      case 'therapy':
        return AppTheme.colors.info;
      case 'sports':
        return AppTheme.colors.error;
      default:
        return AppTheme.colors.textSecondary;
    }
  }

  IconData _getTrainingTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'obedience':
        return Icons.school;
      case 'tricks':
        return Icons.auto_awesome;
      case 'socialization':
        return Icons.people;
      case 'agility':
        return Icons.directions_run;
      case 'therapy':
        return Icons.healing;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.pets;
    }
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.8) return AppTheme.colors.success;
    if (rate >= 0.6) return AppTheme.colors.primary;
    if (rate >= 0.4) return AppTheme.colors.warning;
    return AppTheme.colors.error;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}