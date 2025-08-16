import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/mood_selector.dart';

class FeedbackScreen extends StatefulWidget {
  final String petId;
  final String sessionType;
  final int interactionCount;

  const FeedbackScreen({
    super.key,
    required this.petId,
    required this.sessionType,
    required this.interactionCount,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  int _selectedMood = -1;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onMoodSelected(int moodIndex) {
    setState(() {
      _selectedMood = moodIndex;
    });
  }

  Future<void> _submitFeedback() async {
    if (_selectedMood == -1) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
      _showSuccess = true;
    });

    // Navigate back after success
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _skipFeedback() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.gentleCream,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress Bar
              _buildProgressBar(),
              
              // Main Content
              Expanded(
                child: _buildMainContent(),
              ),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.warmGrey,
            ),
          ),
          
          // Title
          Text(
            'Session Complete!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Skip Button
          TextButton(
            onPressed: _skipFeedback,
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.warmGrey.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: LinearProgressIndicator(
        value: 0.8,
        backgroundColor: AppTheme.softPink,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.leafGreen),
        minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMainContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lgSpacing),
          child: Column(
            children: [
              // Session Summary
              _buildSessionSummary(),
              
              const SizedBox(height: AppConstants.xlSpacing),
              
              // Mood Question
              _buildMoodQuestion(),
              
              const SizedBox(height: AppConstants.xlSpacing),
              
              // Mood Selector
              AnimatedMoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: _onMoodSelected,
                moodLabels: AppConstants.moodStates,
              ),
              
              const SizedBox(height: AppConstants.xxlSpacing),
              
              // Encouraging Message
              _buildEncouragingMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      decoration: BoxDecoration(
        color: AppTheme.softPink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.lgRadius),
        border: Border.all(
          color: AppTheme.heartPink.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.heartPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppConstants.mdSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.heartPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.xsSpacing),
                Text(
                  'You completed ${widget.interactionCount} interactions in your ${widget.sessionType} session.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warmGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 200))
      .slideX(begin: 0.3, duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 200));
  }

  Widget _buildMoodQuestion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: Text(
        'How do you feel after your ${widget.sessionType} session?',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppTheme.warmGrey,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 400))
      .slideY(begin: 0.3, duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 400));
  }

  Widget _buildEncouragingMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      decoration: BoxDecoration(
        color: AppTheme.leafGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        border: Border.all(
          color: AppTheme.leafGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.leafGreen,
            size: 24,
          ),
          const SizedBox(width: AppConstants.mdSpacing),
          Expanded(
            child: Text(
              'Taking time to reflect on your mood helps build a stronger bond with your pet and promotes mindfulness.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.leafGreen,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 800))
      .slideY(begin: 0.3, duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 800));
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Column(
        children: [
          // Primary Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMood == -1 || _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warmGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.lgSpacing),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.xlRadius),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Continue',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: AppConstants.mdSpacing),
          
          // Secondary Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isSubmitting ? null : () {},
              icon: Icon(
                Icons.share,
                color: AppTheme.warmGrey,
                size: 20,
              ),
              label: Text(
                'Share',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 1000))
      .slideY(begin: 0.3, duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 1000));
  }
}