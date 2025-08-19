import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../shared/services/advanced_ai_service.dart';
import '../../../../shared/models/ai_models.dart';
import '../../../../shared/models/pet.dart';
import '../../../../core/theme/app_theme.dart';

class BehavioralAnalysisScreen extends StatefulWidget {
  const BehavioralAnalysisScreen({super.key});

  @override
  State<BehavioralAnalysisScreen> createState() => _BehavioralAnalysisScreenState();
}

class _BehavioralAnalysisScreenState extends State<BehavioralAnalysisScreen>
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final List<BehavioralData> _behavioralData = [];
  final List<String> _photoPaths = [];
  final List<String> _videoPaths = [];
  
  Pet? _selectedPet;
  BehavioralAnalysis? _currentAnalysis;
  bool _isAnalyzing = false;
  String _selectedLanguage = 'en';
  
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
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

    // Initialize mock behavioral data
    _behavioralData.addAll([
      BehavioralData(
        id: '1',
        petId: 'pet1',
        type: 'activity',
        description: 'Morning walk - high energy, playful behavior',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {'duration': 30, 'energy_level': 'high', 'mood': 'excited'},
        confidence: 0.9,
      ),
      BehavioralData(
        id: '2',
        petId: 'pet1',
        type: 'social',
        description: 'Interaction with other dogs - friendly, curious',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        metadata: {'other_pets': 2, 'duration': 15, 'behavior': 'friendly'},
        confidence: 0.85,
      ),
      BehavioralData(
        id: '3',
        petId: 'pet1',
        type: 'rest',
        description: 'Afternoon nap - relaxed, peaceful',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        metadata: {'duration': 45, 'position': 'curled', 'breathing': 'slow'},
        confidence: 0.8,
      ),
    ]);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _photoPaths.add(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        setState(() {
          _videoPaths.add(video.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e');
    }
  }

  Future<void> _analyzeBehavior() async {
    if (_selectedPet == null) {
      _showSnackBar('Please select a pet first');
      return;
    }

    if (_photoPaths.isEmpty && _videoPaths.isEmpty) {
      _showSnackBar('Please add photos or videos for analysis');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final aiService = context.read<AdvancedAIService>();
      final analysis = await aiService.analyzePetBehavior(
        photoPaths: _photoPaths,
        videoPaths: _videoPaths,
        pet: _selectedPet!,
        behavioralData: _behavioralData,
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
      _showSnackBar('Error analyzing behavior: $e');
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
        title: const Text('Behavioral Analysis'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Selection
              _buildPetSelector(),
              
              const SizedBox(height: 24),
              
              // Media Input Section
              _buildMediaInputSection(),
              
              const SizedBox(height: 24),
              
              // Analysis Button
              _buildAnalysisButton(),
              
              const SizedBox(height: 24),
              
              // Results Section
              if (_currentAnalysis != null) _buildResultsSection(),
              
              const SizedBox(height: 24),
              
              // Behavioral Data History
              _buildBehavioralDataSection(),
            ],
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
              'Select Pet for Analysis',
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaInputSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Photos & Videos',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos and videos to analyze your pet\'s behavior, mood, and stress levels',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Photo Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Video Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.camera),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.gallery),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Video Library'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.warning,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Media Preview
            if (_photoPaths.isNotEmpty || _videoPaths.isNotEmpty) ...[
              Text(
                'Selected Media:',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Photos
              if (_photoPaths.isNotEmpty) ...[
                Text(
                  'Photos (${_photoPaths.length}):',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoPaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_photoPaths[index]),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photoPaths.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              // Videos
              if (_videoPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Videos (${_videoPaths.length}):',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _videoPaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.colors.secondary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.colors.secondary.withOpacity(0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.videocam,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _videoPaths.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return Center(
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: ElevatedButton.icon(
          onPressed: _isAnalyzing || _photoPaths.isEmpty ? null : _analyzeBehavior,
          icon: _isAnalyzing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.psychology),
          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Behavior'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTheme.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
                  'Analysis Results',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall Assessment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAssessmentColor(_currentAnalysis!.overallAssessment).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAssessmentColor(_currentAnalysis!.overallAssessment).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Assessment',
                    style: AppTheme.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentAnalysis!.overallAssessment,
                    style: AppTheme.textStyles.bodyLarge?.copyWith(
                      color: _getAssessmentColor(_currentAnalysis!.overallAssessment),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mood Analysis
            _buildAnalysisCard(
              'Mood Analysis',
              Icons.sentiment_satisfied,
              _currentAnalysis!.moodAnalysis.dominantMood,
              'Confidence: ${(_currentAnalysis!.moodAnalysis.confidence * 100).toStringAsFixed(1)}%',
              _currentAnalysis!.moodAnalysis.moodFactors,
              _currentAnalysis!.moodAnalysis.recommendations,
            ),
            
            const SizedBox(height: 16),
            
            // Stress Analysis
            _buildAnalysisCard(
              'Stress Analysis',
              Icons.psychology,
              'Level: ${(_currentAnalysis!.stressAnalysis.stressLevel * 100).toStringAsFixed(1)}%',
              'Factors: ${_currentAnalysis!.stressAnalysis.stressFactors.length} identified',
              _currentAnalysis!.stressAnalysis.stressFactors,
              _currentAnalysis!.stressAnalysis.copingMechanisms,
            ),
            
            const SizedBox(height: 16),
            
            // Social Interaction
            _buildAnalysisCard(
              'Social Interaction',
              Icons.people,
              'Skills: ${(_currentAnalysis!.socialAnalysis.socialSkills * 100).toStringAsFixed(1)}%',
              'Patterns: ${_currentAnalysis!.socialAnalysis.interactionPatterns.length} identified',
              _currentAnalysis!.socialAnalysis.interactionPatterns.map((p) => p.name).toList(),
              _currentAnalysis!.socialAnalysis.recommendations,
            ),
            
            const SizedBox(height: 16),
            
            // Recommendations
            if (_currentAnalysis!.recommendations.isNotEmpty) ...[
              Text(
                'Recommendations',
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

  Widget _buildBehavioralDataSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavioral Data History',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recent behavioral observations and patterns',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_behavioralData.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: AppTheme.colors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No behavioral data yet',
                        style: AppTheme.textStyles.bodyLarge?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your pet\'s behavior to see patterns and insights',
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
                itemCount: _behavioralData.length,
                itemBuilder: (context, index) {
                  final data = _behavioralData[index];
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
                                  color: _getBehaviorTypeColor(data.type).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getBehaviorTypeIcon(data.type),
                                  size: 16,
                                  color: _getBehaviorTypeColor(data.type),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.type.toUpperCase(),
                                      style: AppTheme.textStyles.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getBehaviorTypeColor(data.type),
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(data.timestamp),
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
                                  color: AppTheme.colors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(data.confidence * 100).toStringAsFixed(0)}%',
                                  style: AppTheme.textStyles.bodySmall?.copyWith(
                                    color: AppTheme.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.description,
                            style: AppTheme.textStyles.bodyMedium,
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

  Color _getAssessmentColor(String assessment) {
    switch (assessment.toLowerCase()) {
      case 'excellent':
        return AppTheme.colors.success;
      case 'good':
        return AppTheme.colors.primary;
      case 'fair':
        return AppTheme.colors.warning;
      case 'needs attention':
        return AppTheme.colors.error;
      default:
        return AppTheme.colors.textSecondary;
    }
  }

  Color _getBehaviorTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'activity':
        return AppTheme.colors.success;
      case 'social':
        return AppTheme.colors.primary;
      case 'rest':
        return AppTheme.colors.secondary;
      case 'feeding':
        return AppTheme.colors.warning;
      default:
        return AppTheme.colors.textSecondary;
    }
  }

  IconData _getBehaviorTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'activity':
        return Icons.directions_run;
      case 'social':
        return Icons.people;
      case 'rest':
        return Icons.bedtime;
      case 'feeding':
        return Icons.restaurant;
      default:
        return Icons.pets;
    }
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