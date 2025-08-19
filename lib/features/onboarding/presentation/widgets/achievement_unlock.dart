import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';

class AchievementUnlockDialog extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _confettiController;
  late AnimationController _textController;
  
  bool _showConfetti = false;
  List<ConfettiPiece> _confettiPieces = [];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppTheme.durationSlow,
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _textController = AnimationController(
      duration: AppTheme.durationNormal,
      vsync: this,
    );
    
    _startCelebration();
  }

  void _startCelebration() async {
    // Haptic feedback for achievement unlock
    AppTheme.heavyImpact();
    
    // Create confetti pieces
    _createConfettiPieces();
    
    // Start animations
    _scaleController.forward();
    _rotationController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _showConfetti = true;
    });
    
    _confettiController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _textController.forward();
    
    // Auto-dismiss after celebration
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      _dismissDialog();
    }
  }

  void _createConfettiPieces() {
    final random = math.Random();
    _confettiPieces = List.generate(50, (index) {
      return ConfettiPiece(
        id: index,
        x: random.nextDouble(),
        y: random.nextDouble(),
        color: _getRandomColor(),
        size: 4 + random.nextDouble() * 8,
        angle: random.nextDouble() * 360,
        speed: 100 + random.nextDouble() * 200,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
      AppTheme.success,
      AppTheme.warning,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _dismissDialog() {
    _scaleController.reverse();
    _textController.reverse();
    
    Future.delayed(AppTheme.durationNormal, () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _dismissDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Stack(
          children: [
            // Confetti background
            if (_showConfetti) _buildConfettiBackground(),
            
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleController.value,
                    child: Container(
                      margin: const EdgeInsets.all(AppTheme.spacing32),
                      padding: const EdgeInsets.all(AppTheme.spacing32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfacePrimary,
                        borderRadius: AppTheme.radiusXLarge,
                        boxShadow: AppTheme.shadowLarge,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Achievement icon
                          _buildAchievementIcon(),
                          
                          const SizedBox(height: AppTheme.spacing24),
                          
                          // Achievement title
                          _buildAchievementTitle(),
                          
                          const SizedBox(height: AppTheme.spacing16),
                          
                          // Achievement description
                          _buildAchievementDescription(),
                          
                          const SizedBox(height: AppTheme.spacing32),
                          
                          // Continue button
                          _buildContinueButton(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiBackground() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            pieces: _confettiPieces,
            progress: _confettiController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAchievementIcon() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.achievement.color,
                  widget.achievement.color.withOpacity(0.7),
                ],
              ),
              borderRadius: AppTheme.radiusFull,
              boxShadow: [
                BoxShadow(
                  color: widget.achievement.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              widget.achievement.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    ).animate().scale(
      begin: const Offset(0, 0),
      duration: AppTheme.durationSlow,
      curve: AppTheme.easeOutBack,
    );
  }

  Widget _buildAchievementTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _textController.value)),
          child: Opacity(
            opacity: _textController.value,
            child: Column(
              children: [
                Text(
                  '🎉 Achievement Unlocked! 🎉',
                  style: AppTheme.textTheme.labelLarge?.copyWith(
                    color: widget.achievement.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  widget.achievement.title,
                  style: AppTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementDescription() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _textController.value)),
          child: Opacity(
            opacity: _textController.value,
            child: Text(
              widget.achievement.description,
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _textController.value)),
          child: Opacity(
            opacity: _textController.value,
            child: ElevatedButton(
              onPressed: _dismissDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.achievement.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing32,
                  vertical: AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
              ),
              child: Text(
                'Continue',
                style: AppTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Confetti piece model
class ConfettiPiece {
  final int id;
  final double x;
  final double y;
  final Color color;
  final double size;
  final double angle;
  final double speed;
  
  ConfettiPiece({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.angle,
    required this.speed,
  });
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;
  
  ConfettiPainter({
    required this.pieces,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;
      
      // Calculate position based on progress
      final startX = piece.x * size.width;
      final startY = piece.y * size.height;
      final endY = size.height + piece.size;
      
      final currentY = startY + (endY - startY) * progress;
      final currentX = startX + math.sin(progress * 10 + piece.id) * 50;
      
      // Draw confetti piece
      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(piece.angle * progress);
      
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.size,
        height: piece.size,
      );
      
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}