import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

enum PetAnimationState {
  idle,
  happy,
  giggling,
  sleeping,
  excited,
  overjoyed,
}

class AnimatedPetAvatar extends StatefulWidget {
  final PetAnimationState currentState;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final bool showFloatingHearts;
  final String petName;
  final Color petColor;

  const AnimatedPetAvatar({
    super.key,
    this.currentState = PetAnimationState.idle,
    this.onTap,
    this.onLongPress,
    this.size = 200.0,
    this.showFloatingHearts = true,
    this.petName = 'Buddy',
    this.petColor = AppTheme.heartPink,
  });

  @override
  State<AnimatedPetAvatar> createState() => _AnimatedPetAvatarState();
}

class _AnimatedPetAvatarState extends State<AnimatedPetAvatar>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _bounceController;
  late AnimationController _heartController;
  late AnimationController _emotionController;
  
  late Animation<double> _idleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _emotionAnimation;
  
  List<FloatingHeart> _floatingHearts = [];
  Timer? _heartTimer;
  Timer? _idleTimer;
  
  double _currentScale = 1.0;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    
    _setupAnimations();
    _startIdleAnimation();
    
    if (widget.showFloatingHearts) {
      _startHeartAnimation();
    }
  }

  void _setupAnimations() {
    // Idle breathing animation
    _idleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _idleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation for interactions
    _bounceController = AnimationController(
      duration: AppConstants.bounceAnimation,
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Heart scale animation
    _heartController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    // Emotion-based animations
    _emotionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _emotionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emotionController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startIdleAnimation() {
    _idleTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && !_isInteracting) {
        _idleController.forward().then((_) {
          _idleController.reverse();
        });
      }
    });
  }

  void _startHeartAnimation() {
    _heartTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _floatingHearts.length < 5) {
        _addFloatingHeart();
      }
    });
  }

  void _addFloatingHeart() {
    setState(() {
      _floatingHearts.add(FloatingHeart(
        key: UniqueKey(),
        onComplete: () {
          setState(() {
            _floatingHearts.removeWhere((heart) => heart.key == heart.key);
          });
        },
      ));
    });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    _heartController.dispose();
    _emotionController.dispose();
    _heartTimer?.cancel();
    _idleTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isInteracting = true;
    });

    _bounceController.forward().then((_) {
      _bounceController.reverse();
      setState(() {
        _isInteracting = false;
      });
    });

    _emotionController.forward().then((_) {
      _emotionController.reverse();
    });

    widget.onTap?.call();
  }

  void _handleLongPress() {
    _heartController.forward().then((_) {
      _heartController.reverse();
    });
    widget.onLongPress?.call();
  }

  Widget _buildPetBody() {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleAnimation, _bounceAnimation]),
      builder: (context, child) {
        final scale = _idleAnimation.value * _bounceAnimation.value;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size * 0.8,
            height: widget.size * 0.8,
            decoration: BoxDecoration(
              color: widget.petColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.petColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _buildPetFace(),
          ),
        );
      },
    );
  }

  Widget _buildPetFace() {
    return Stack(
      children: [
        // Eyes
        Positioned(
          top: widget.size * 0.25,
          left: widget.size * 0.2,
          child: _buildEye(),
        ),
        Positioned(
          top: widget.size * 0.25,
          right: widget.size * 0.2,
          child: _buildEye(),
        ),
        
        // Nose
        Positioned(
          top: widget.size * 0.4,
          left: 0,
          right: 0,
          child: _buildNose(),
        ),
        
        // Mouth
        Positioned(
          bottom: widget.size * 0.25,
          left: 0,
          right: 0,
          child: _buildMouth(),
        ),
        
        // Ears
        Positioned(
          top: -widget.size * 0.1,
          left: widget.size * 0.1,
          child: _buildEar(),
        ),
        Positioned(
          top: -widget.size * 0.1,
          right: widget.size * 0.1,
          child: _buildEar(),
        ),
      ],
    );
  }

  Widget _buildEye() {
    final eyeColor = _getEyeColor();
    final eyeSize = _getEyeSize();
    
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      width: eyeSize,
      height: eyeSize,
      decoration: BoxDecoration(
        color: eyeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: eyeSize * 0.6,
          height: eyeSize * 0.6,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildNose() {
    return Container(
      width: 12,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildMouth() {
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      width: _getMouthWidth(),
      height: _getMouthHeight(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_getMouthHeight() / 2),
      ),
    );
  }

  Widget _buildEar() {
    return Container(
      width: 20,
      height: 30,
      decoration: BoxDecoration(
        color: widget.petColor.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
    );
  }

  Color _getEyeColor() {
    switch (widget.currentState) {
      case PetAnimationState.idle:
        return Colors.blue;
      case PetAnimationState.happy:
        return Colors.green;
      case PetAnimationState.giggling:
        return Colors.orange;
      case PetAnimationState.sleeping:
        return Colors.grey;
      case PetAnimationState.excited:
        return Colors.purple;
      case PetAnimationState.overjoyed:
        return Colors.yellow;
    }
  }

  double _getEyeSize() {
    switch (widget.currentState) {
      case PetAnimationState.sleeping:
        return 8;
      case PetAnimationState.overjoyed:
        return 16;
      default:
        return 12;
    }
  }

  double _getMouthWidth() {
    switch (widget.currentState) {
      case PetAnimationState.happy:
      case PetAnimationState.giggling:
      case PetAnimationState.overjoyed:
        return 30;
      case PetAnimationState.sleeping:
        return 8;
      default:
        return 20;
    }
  }

  double _getMouthHeight() {
    switch (widget.currentState) {
      case PetAnimationState.giggling:
      case PetAnimationState.overjoyed:
        return 15;
      case PetAnimationState.sleeping:
        return 4;
      default:
        return 8;
    }
  }

  Widget _buildEmotionEffect() {
    if (widget.currentState == PetAnimationState.overjoyed) {
      return AnimatedBuilder(
        animation: _emotionAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _emotionAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Emotion effect background
          _buildEmotionEffect(),
          
          // Main pet avatar
          _buildPetBody(),
          
          // Floating hearts
          ..._floatingHearts,
          
          // Pet name
          Positioned(
            bottom: -widget.size * 0.15,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.gentleCream,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warmGrey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                widget.petName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Interaction indicator
          Positioned(
            bottom: -widget.size * 0.3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.leafGreen.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.leafGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to interact!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: AppConstants.longAnimation)
              .slideY(begin: 0.5, duration: AppConstants.longAnimation),
          ),
        ],
      ),
    );
  }
}

class FloatingHeart extends StatefulWidget {
  final VoidCallback onComplete;

  const FloatingHeart({
    super.key,
    required this.onComplete,
  });

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(Random().nextDouble() * 2 - 1, -2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.heartPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.heartPink.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
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