import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

enum PetAnimationState {
  idle,
  happy,
  giggling,
  sleeping,
  excited,
}

class InteractivePetAvatar extends StatefulWidget {
  final String avatarPath;
  final PetAnimationState currentState;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final bool showFloatingHearts;

  const InteractivePetAvatar({
    super.key,
    required this.avatarPath,
    this.currentState = PetAnimationState.idle,
    this.onTap,
    this.onLongPress,
    this.size = 200.0,
    this.showFloatingHearts = true,
  });

  @override
  State<InteractivePetAvatar> createState() => _InteractivePetAvatarState();
}

class _InteractivePetAvatarState extends State<InteractivePetAvatar>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _heartController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  
  List<FloatingHeart> _floatingHearts = [];
  Timer? _heartTimer;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: AppConstants.bounceAnimation,
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    if (widget.showFloatingHearts) {
      _startHeartAnimation();
    }
  }

  void _startHeartAnimation() {
    _heartTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _addFloatingHeart();
      }
    });
  }

  void _addFloatingHeart() {
    if (_floatingHearts.length < 5) {
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
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _heartController.dispose();
    _heartTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onTap?.call();
  }

  void _handleLongPress() {
    _heartController.forward().then((_) {
      _heartController.reverse();
    });
    widget.onLongPress?.call();
  }

  String _getAnimationPath() {
    switch (widget.currentState) {
      case PetAnimationState.idle:
        return '${widget.avatarPath}/idle.json';
      case PetAnimationState.happy:
        return '${widget.avatarPath}/happy.json';
      case PetAnimationState.giggling:
        return '${widget.avatarPath}/giggling.json';
      case PetAnimationState.sleeping:
        return '${widget.avatarPath}/sleeping.json';
      case PetAnimationState.excited:
        return '${widget.avatarPath}/excited.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Pet Avatar
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.heartPink.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Lottie.asset(
                      _getAnimationPath(),
                      fit: BoxFit.cover,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating Hearts
          ..._floatingHearts,

          // Interaction Indicator
          Positioned(
            bottom: -20,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: AppTheme.leafGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to interact!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.warmGrey,
                      fontWeight: FontWeight.w500,
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
      end: const Offset(0, -2),
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
        );
      },
    );
  }
}