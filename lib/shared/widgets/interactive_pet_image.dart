import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:math' as math;

class InteractivePetImage extends StatefulWidget {
  final String imagePath;
  final String petName;
  final double size;
  final VoidCallback? onTap;
  final bool showName;
  final bool enableInteractions;
  final String? overlayText;
  final Color? borderColor;
  final double borderWidth;

  const InteractivePetImage({
    super.key,
    required this.imagePath,
    required this.petName,
    this.size = 120,
    this.onTap,
    this.showName = true,
    this.enableInteractions = true,
    this.overlayText,
    this.borderColor,
    this.borderWidth = 3,
  });

  @override
  State<InteractivePetImage> createState() => _InteractivePetImageState();
}

class _InteractivePetImageState extends State<InteractivePetImage>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _rippleController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  
  late Animation<double> _spinAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isHovered = false;
  bool _isSpinning = false;
  bool _isRippling = false;
  bool _isBouncing = false;
  bool _isPulsing = false;
  
  final List<Offset> _ripplePoints = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Spin animation
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _spinAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeInOut,
    ));

    // Ripple animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // Bounce animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _spinController.dispose();
    _rippleController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableInteractions) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _startHoverEffects();
    } else {
      _stopHoverEffects();
    }
  }

  void _startHoverEffects() {
    // Start gentle pulse on hover
    _pulseController.repeat(reverse: true);
    setState(() {
      _isPulsing = true;
    });
  }

  void _stopHoverEffects() {
    // Stop pulse animation
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isPulsing = false;
    });
  }

  void _handleTap() {
    if (!widget.enableInteractions) {
      widget.onTap?.call();
      return;
    }

    // Create random ripple points
    _ripplePoints.clear();
    for (int i = 0; i < 5; i++) {
      _ripplePoints.add(Offset(
        _random.nextDouble() * widget.size,
        _random.nextDouble() * widget.size,
      ));
    }

    // Start ripple effect
    setState(() {
      _isRippling = true;
    });
    _rippleController.forward().then((_) {
      setState(() {
        _isRippling = false;
      });
      _rippleController.reset();
    });

    // Trigger bounce effect
    setState(() {
      _isBouncing = true;
    });
    _bounceController.forward().then((_) {
      setState(() {
        _isBouncing = false;
      });
      _bounceController.reset();
    });

    // Call original onTap
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (!widget.enableInteractions) return;

    // Start spinning on long press
    setState(() {
      _isSpinning = true;
    });
    _spinController.repeat().then((_) {
      setState(() {
        _isSpinning = false;
      });
    });
  }

  void _stopSpinning() {
    if (_isSpinning) {
      _spinController.stop();
      setState(() {
        _isSpinning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        onLongPressEnd: (_) => _stopSpinning(),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _spinController,
            _rippleController,
            _bounceController,
            _pulseController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _isBouncing ? 1.0 + (_bounceAnimation.value * 0.2) : 1.0,
              child: Transform.rotate(
                angle: _isSpinning ? _spinAnimation.value : 0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getBorderColor(),
                      width: widget.borderWidth + (_isPulsing ? _pulseAnimation.value * 2 : 0),
                    ),
                    boxShadow: _isHovered ? [
                      BoxShadow(
                        color: _getBorderColor().withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ] : null,
                  ),
                  child: Stack(
                    children: [
                      // Main image
                      ClipOval(
                        child: _buildImage(),
                      ),
                      
                      // Ripple effects
                      if (_isRippling) _buildRippleEffects(),
                      
                      // Overlay text
                      if (widget.overlayText != null) _buildOverlayText(),
                      
                      // Interaction indicators
                      if (_isHovered) _buildHoverIndicators(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imagePath.startsWith('http')) {
      return Image.network(
        widget.imagePath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.size,
            height: widget.size,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return Image.file(
        File(widget.imagePath),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: widget.size,
      height: widget.size,
      color: Colors.grey[300],
      child: Icon(
        Icons.pets,
        size: widget.size * 0.4,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildRippleEffects() {
    return Stack(
      children: _ripplePoints.map((point) {
        return Positioned(
          left: point.dx - 20,
          top: point.dy - 20,
          child: AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _rippleAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getBorderColor().withOpacity(
                      1 - _rippleAnimation.value,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverlayText() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
        ),
        child: Text(
          widget.overlayText!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHoverIndicators() {
    return Positioned(
      top: -5,
      right: -5,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _getBorderColor(),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.touch_app,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (widget.borderColor != null) {
      return widget.borderColor!;
    }
    
    if (_isHovered) {
      return Colors.blue;
    } else if (_isSpinning) {
      return Colors.purple;
    } else if (_isRippling) {
      return Colors.orange;
    } else if (_isBouncing) {
      return Colors.green;
    } else if (_isPulsing) {
      return Colors.blue.withOpacity(0.7);
    }
    
    return Colors.grey[400]!;
  }
}

class PetImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final String petName;
  final double imageSize;
  final int maxImages;
  final VoidCallback? onAddImage;
  final Function(String)? onImageSelected;

  const PetImageGallery({
    super.key,
    required this.imagePaths,
    required this.petName,
    this.imageSize = 100,
    this.maxImages = 5,
    this.onAddImage,
    this.onImageSelected,
  });

  @override
  State<PetImageGallery> createState() => _PetImageGalleryState();
}

class _PetImageGalleryState extends State<PetImageGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main selected image
        if (widget.imagePaths.isNotEmpty)
          InteractivePetImage(
            imagePath: widget.imagePaths[_selectedIndex],
            petName: widget.petName,
            size: widget.imageSize * 1.5,
            onTap: () => widget.onImageSelected?.call(widget.imagePaths[_selectedIndex]),
            overlayText: '${_selectedIndex + 1}/${widget.imagePaths.length}',
          ),
        
        const SizedBox(height: 16),
        
        // Thumbnail gallery
        if (widget.imagePaths.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...widget.imagePaths.asMap().entries.map((entry) {
                final index = entry.key;
                final imagePath = entry.value;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: InteractivePetImage(
                      imagePath: imagePath,
                      petName: widget.petName,
                      size: widget.imageSize * 0.6,
                      borderColor: _selectedIndex == index ? Colors.blue : null,
                      borderWidth: _selectedIndex == index ? 4 : 2,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                );
              }),
              
              // Add image button
              if (widget.imagePaths.length < widget.maxImages)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: widget.onAddImage,
                    child: Container(
                      width: widget.imageSize * 0.6,
                      height: widget.imageSize * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(
                          color: Colors.grey[400],
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        size: widget.imageSize * 0.3,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class PetImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final String petName;
  final double imageSize;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const PetImageCarousel({
    super.key,
    required this.imagePaths,
    required this.petName,
    this.imageSize = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<PetImageCarousel> createState() => _PetImageCarouselState();
}

class _PetImageCarouselState extends State<PetImageCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _autoPlayController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.autoPlay && widget.imagePaths.length > 1) {
      _autoPlayController = AnimationController(
        duration: widget.autoPlayInterval,
        vsync: this,
      );
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextImage();
        _autoPlayController.reset();
        _autoPlayController.forward();
      }
    });
    _autoPlayController.forward();
  }

  void _nextImage() {
    if (_currentIndex < widget.imagePaths.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = widget.imagePaths.length - 1;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return Container(
        width: widget.imageSize,
        height: widget.imageSize,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(widget.imageSize / 2),
        ),
        child: Icon(
          Icons.pets,
          size: widget.imageSize * 0.4,
          color: Colors.grey[600],
        ),
      );
    }

    return Column(
      children: [
        // Main carousel
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.imageSize,
              height: widget.imageSize,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.imagePaths.length,
                itemBuilder: (context, index) {
                  return InteractivePetImage(
                    imagePath: widget.imagePaths[index],
                    petName: widget.petName,
                    size: widget.imageSize,
                    overlayText: '${index + 1}/${widget.imagePaths.length}',
                  );
                },
              ),
            ),
            
            // Navigation arrows
            if (widget.imagePaths.length > 1) ...[
              // Previous arrow
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: _previousImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              // Next arrow
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: _nextImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        
        // Page indicators
        if (widget.imagePaths.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imagePaths.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.blue
                      : Colors.grey[400],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}