import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showHeart;
  final VoidCallback? onTap;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.height = 12.0,
    this.activeColor,
    this.inactiveColor,
    this.showHeart = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = this.activeColor ?? AppTheme.heartPink;
    final inactiveColor = this.inactiveColor ?? AppTheme.softPink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: inactiveColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            // Progress Bar
            AnimatedContainer(
              duration: AppConstants.mediumAnimation,
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: AppConstants.shortAnimation)
              .slideX(begin: 0.1, duration: AppConstants.mediumAnimation),

            // Heart Icon at the end of progress
            if (showHeart && progress > 0)
              Positioned(
                right: 0,
                top: -height / 2,
                child: Container(
                  width: height * 2,
                  height: height * 2,
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
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: height,
                  ),
                ).animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: AppConstants.bounceAnimation,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shake(
                    duration: AppConstants.shortAnimation,
                    hz: 4,
                  ),
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double targetProgress;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showHeart;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const AnimatedProgressBar({
    super.key,
    required this.targetProgress,
    this.height = 12.0,
    this.activeColor,
    this.inactiveColor,
    this.showHeart = true,
    this.onTap,
    this.onComplete,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _currentProgress,
      end: widget.targetProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation.addListener(() {
      setState(() {
        _currentProgress = _animation.value;
      });
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetProgress != widget.targetProgress) {
      _animation = Tween<double>(
        begin: _currentProgress,
        end: widget.targetProgress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressBar(
      progress: _currentProgress,
      height: widget.height,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      showHeart: widget.showHeart,
      onTap: widget.onTap,
    );
  }
}