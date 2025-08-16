import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class MoodSelector extends StatefulWidget {
  final int selectedMood;
  final Function(int) onMoodSelected;
  final List<String> moodLabels;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.moodLabels = const [],
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: AppConstants.bounceAnimation,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    if (widget.selectedMood != index) {
      widget.onMoodSelected(index);
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  Widget _buildMoodEmoji(int index, bool isSelected) {
    final emojiData = _getEmojiData(index);
    final scale = isSelected ? 1.0 : 0.8;
    final opacity = isSelected ? 1.0 : 0.6;

    return GestureDetector(
      onTap: () => _selectMood(index),
      child: AnimatedContainer(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(scale),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.leafGreen : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.leafGreen : AppTheme.warmGrey.withOpacity(0.3),
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Center(
              child: Text(
                emojiData['emoji']!,
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _getEmojiData(int index) {
    const emojis = [
      {'emoji': '😊', 'label': 'Overjoyed'},
      {'emoji': '😄', 'label': 'Happy'},
      {'emoji': '😌', 'label': 'Content'},
      {'emoji': '😐', 'label': 'Calm'},
      {'emoji': '😴', 'label': 'Relaxed'},
    ];

    if (index >= 0 && index < emojis.length) {
      return emojis[index];
    }
    return {'emoji': '😊', 'label': 'Happy'};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected Mood Display
        if (widget.selectedMood >= 0)
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.leafGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.leafGreen.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getEmojiData(widget.selectedMood)['emoji']!,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmojiData(widget.selectedMood)['label']!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.leafGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate()
                  .fadeIn(duration: AppConstants.mediumAnimation)
                  .slideY(begin: 0.3, duration: AppConstants.mediumAnimation),
              ],
            ),
          ),

        // Mood Selection Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final isSelected = widget.selectedMood == index;
            return _buildMoodEmoji(index, isSelected);
          }),
        ).animate()
          .fadeIn(duration: AppConstants.longAnimation)
          .slideY(begin: 0.5, duration: AppConstants.longAnimation),

        // Mood Labels
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = widget.selectedMood == index;
            final label = _getEmojiData(index)['label']!;
            
            return AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.5,
              duration: AppConstants.mediumAnimation,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppTheme.leafGreen : AppTheme.warmGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ).animate()
          .fadeIn(duration: AppConstants.longAnimation, delay: const Duration(milliseconds: 200))
          .slideY(begin: 0.3, duration: AppConstants.longAnimation, delay: const Duration(milliseconds: 200)),
      ],
    );
  }
}

class AnimatedMoodSelector extends StatefulWidget {
  final int selectedMood;
  final Function(int) onMoodSelected;
  final List<String> moodLabels;

  const AnimatedMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.moodLabels = const [],
  });

  @override
  State<AnimatedMoodSelector> createState() => _AnimatedMoodSelectorState();
}

class _AnimatedMoodSelectorState extends State<AnimatedMoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MoodSelector(
          selectedMood: widget.selectedMood,
          onMoodSelected: widget.onMoodSelected,
          moodLabels: widget.moodLabels,
        ),
      ),
    );
  }
}