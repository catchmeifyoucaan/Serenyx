import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/animated_pet_avatar.dart';
import '../../../../shared/widgets/custom_progress_bar.dart';
import '../../../../shared/services/session_service.dart';
import '../../../../shared/services/pet_service.dart';
import '../../../../shared/models/session.dart';
import '../../../../shared/models/pet.dart';

class TickleSessionScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const TickleSessionScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<TickleSessionScreen> createState() => _TickleSessionScreenState();
}

class _TickleSessionScreenState extends State<TickleSessionScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  PetAnimationState _petState = PetAnimationState.idle;
  int _interactionCount = 0;
  int _currentPromptIndex = 0;
  String _currentAudioFeedback = '';
  bool _isSessionActive = true;
  bool _showCelebration = false;

  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;
  
  // Services
  final SessionService _sessionService = SessionService();
  final PetService _petService = PetService();
  
  // Current session data
  Session? _currentSession;
  Pet? _currentPet;

  @override
  void initState() {
    super.initState();
    
    _celebrationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _startSession();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    try {
      // Initialize services
      await _sessionService.initialize();
      await _petService.initialize();
      
      // Get current pet
      _currentPet = _petService.currentPet;
      
      // Start new session
      _currentSession = await _sessionService.startSession(
        petId: widget.petId,
        userId: 'default-user', // TODO: Replace with real user ID
        type: SessionType.tickle,
        duration: const Duration(minutes: 10),
      );
      
      setState(() {
        _isSessionActive = true;
        _progress = 0.0;
        _interactionCount = 0;
        _petState = PetAnimationState.idle;
      });
    } catch (e) {
      print('Error starting session: $e');
      // Fallback to default behavior
      setState(() {
        _isSessionActive = true;
        _progress = 0.0;
        _interactionCount = 0;
        _petState = PetAnimationState.idle;
      });
    }
  }

  Future<void> _onPetInteraction() async {
    if (!_isSessionActive) return;

    try {
      // Add interaction to session
      if (_currentSession != null) {
        await _sessionService.addInteraction(
          'tickle',
          note: 'Pet interaction ${_interactionCount + 1}',
        );
      }
      
      setState(() {
        _interactionCount++;
        _progress = (_interactionCount / 10).clamp(0.0, 1.0);
        
        // Change pet state based on interaction
        if (_interactionCount <= 3) {
          _petState = PetAnimationState.happy;
        } else if (_interactionCount <= 6) {
          _petState = PetAnimationState.giggling;
        } else if (_interactionCount <= 9) {
          _petState = PetAnimationState.excited;
        } else {
          _petState = PetAnimationState.overjoyed;
        }

        // Update prompt and audio feedback
        _currentPromptIndex = (_interactionCount - 1) % AppConstants.interactionPrompts.length;
        _currentAudioFeedback = _getRandomAudioFeedback();
      });

      // Check if session is complete
      if (_progress >= 1.0) {
        await _completeSession();
      }
    } catch (e) {
      print('Error handling pet interaction: $e');
    }
  }

  String _getRandomAudioFeedback() {
    final feedbacks = AppConstants.audioFeedback.values.toList();
    return feedbacks[_interactionCount % feedbacks.length];
  }

  Color _getPetColor() {
    if (_currentPet == null) return AppTheme.heartPink;
    
    // Generate a consistent color based on pet ID
    final hash = _currentPet!.id.hashCode;
    final colors = [
      AppTheme.heartPink,
      AppTheme.leafGreen,
      AppTheme.softPurple,
      AppTheme.lightPink,
      AppTheme.pastelPeach,
    ];
    
    return colors[hash.abs() % colors.length];
  }

  Future<void> _completeSession() async {
    try {
      // Update pet session count
      if (_currentPet != null) {
        await _petService.updatePetSession(
          _currentPet!.id,
          sessionCount: _currentPet!.sessionCount + 1,
          lastSession: DateTime.now(),
        );
      }
      
      setState(() {
        _isSessionActive = false;
        _showCelebration = true;
      });

      _celebrationController.forward();

      // Navigate to feedback screen after celebration
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/feedback',
            arguments: {
              'petId': widget.petId,
              'sessionType': 'tickle',
              'interactionCount': _interactionCount,
            },
          );
        }
      });
    } catch (e) {
      print('Error completing session: $e');
      // Still show celebration even if there's an error
      setState(() {
        _isSessionActive = false;
        _showCelebration = true;
      });
      _celebrationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPinkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: _buildMainContent(),
              ),
              
              // Bottom Section
              _buildBottomSection(),
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
          
          // Progress Bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
              child: CustomProgressBar(
                progress: _progress,
                height: 8,
                activeColor: AppTheme.heartPink,
                inactiveColor: AppTheme.softPink,
                showHeart: true,
              ),
            ),
          ),
          
          // Session Info
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.info_outline,
              color: AppTheme.warmGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Headline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.xlSpacing),
          child: Text(
            AppConstants.appTagline,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate()
          .fadeIn(duration: AppConstants.longAnimation)
          .slideY(begin: 0.3, duration: AppConstants.longAnimation),

        const SizedBox(height: AppConstants.xxlSpacing),

        // Interactive Pet Avatar
        AnimatedPetAvatar(
          currentState: _petState,
          onTap: _onPetInteraction,
          onLongPress: _onPetInteraction,
          size: 220,
          showFloatingHearts: true,
          petName: _currentPet?.name ?? widget.petName,
          petColor: _getPetColor(),
        ).animate()
          .fadeIn(duration: AppConstants.longAnimation, delay: const Duration(milliseconds: 300))
          .scale(begin: const Offset(0.8, 0.8), duration: AppConstants.longAnimation, delay: const Duration(milliseconds: 300)),

        const SizedBox(height: AppConstants.xlSpacing),

        // Interaction Prompt
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.lgSpacing,
            vertical: AppConstants.mdSpacing,
          ),
          decoration: BoxDecoration(
            color: AppTheme.gentleCream,
            borderRadius: BorderRadius.circular(AppConstants.lgRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.warmGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app,
                color: AppTheme.leafGreen,
                size: 20,
              ),
              const SizedBox(width: AppConstants.smSpacing),
              Flexible(
                child: Text(
                  AppConstants.interactionPrompts[_currentPromptIndex],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppConstants.smSpacing),
              Icon(
                Icons.favorite,
                color: AppTheme.heartPink,
                size: 20,
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 600))
          .slideY(begin: 0.3, duration: AppConstants.mediumAnimation, delay: const Duration(milliseconds: 600)),

        const SizedBox(height: AppConstants.lgSpacing),

        // Audio Feedback
        if (_currentAudioFeedback.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.lgSpacing,
              vertical: AppConstants.smSpacing,
            ),
            decoration: BoxDecoration(
              color: AppTheme.leafGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
              border: Border.all(
                color: AppTheme.leafGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.leafGreen,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smSpacing),
                Text(
                  _currentAudioFeedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.leafGreen,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: AppConstants.shortAnimation)
            .scale(begin: const Offset(0.9, 0.9), duration: AppConstants.shortAnimation),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Session Stats
          Column(
            children: [
              Text(
                '$_interactionCount',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.heartPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Interactions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.warmGrey,
                ),
              ),
            ],
          ),
          
          // Progress Percentage
          Column(
            children: [
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.leafGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.warmGrey,
                ),
              ),
            ],
          ),
          
          // Session Type
          Column(
            children: [
              Icon(
                Icons.pets,
                color: AppTheme.heartPink,
                size: 32,
              ),
              Text(
                'Tickle',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.warmGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Celebration Overlay
  Widget _buildCelebrationOverlay() {
    if (!_showCelebration) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            color: AppTheme.heartPink.withOpacity(0.1),
            child: Center(
              child: Transform.scale(
                scale: _celebrationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.xlSpacing),
                  decoration: BoxDecoration(
                    color: AppTheme.gentleCream,
                    borderRadius: BorderRadius.circular(AppConstants.lgRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.warmGrey.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.celebration,
                        color: AppTheme.heartPink,
                        size: 64,
                      ),
                      const SizedBox(height: AppConstants.mdSpacing),
                      Text(
                        'Session Complete!',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.heartPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smSpacing),
                      Text(
                        'Your pet loved that!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.warmGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}