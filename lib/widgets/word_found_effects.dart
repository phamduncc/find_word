import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/word.dart';
// import '../models/combo_system.dart'; // Combo display disabled

/// Enhanced word found animation with multiple effects
class WordFoundEffect extends StatefulWidget {
  final Word word;
  // final ComboStreak? combo; // Combo display disabled
  final VoidCallback? onComplete;
  final Offset? position;

  const WordFoundEffect({
    super.key,
    required this.word,
    // this.combo, // Combo display disabled
    this.onComplete,
    this.position,
  });

  @override
  State<WordFoundEffect> createState() => _WordFoundEffectState();
}

class _WordFoundEffectState extends State<WordFoundEffect>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _scoreController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scoreSlideAnimation;
  late Animation<double> _scoreOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800), // Reduced from 2000ms for faster response
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300), // Reduced from 600ms
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduced from 1500ms
      vsync: this,
    );

    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main word animation
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.4, curve: Curves.easeInOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // Pulse animation for combo
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Score animation
    _scoreSlideAnimation = Tween<double>(
      begin: 0,
      end: -50,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOut,
    ));

    _scoreOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() {
    _mainController.forward();
    _scoreController.forward();

    // Combo pulse animation disabled

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Color _getWordColor() {
    final length = widget.word.text.length;
    if (length <= 3) return Colors.green;
    if (length <= 5) return Colors.blue;
    if (length <= 7) return Colors.purple;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _pulseController,
        _scoreController,
      ]),
      builder: (context, child) {
        final comboScale = 1.0; // Combo scaling disabled

        return Transform.scale(
          scale: _scaleAnimation.value * comboScale,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.translate(
              offset: _slideAnimation.value * 50,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main word container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                        vertical: AppConstants.spacingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getWordColor().withOpacity(0.8),
                            _getWordColor(),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: _getWordColor().withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.word.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Combo text display disabled
                        ],
                      ),
                    ),

                    // Score popup
                    Positioned(
                      top: _scoreSlideAnimation.value,
                      right: -10,
                      child: Opacity(
                        opacity: _scoreOpacityAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade600,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '+${widget.word.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Combo level indicator disabled
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Overlay for showing word found effects
class WordFoundOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context,
    Word word, {
    // ComboStreak? combo, // Combo display disabled
    Offset? position,
  }) {
    hide();

    final screenSize = MediaQuery.of(context).size;
    final defaultPosition = Offset(
      screenSize.width * 0.5,
      screenSize.height * 0.4,
    );

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: (position?.dx ?? defaultPosition.dx) - 100,
        top: (position?.dy ?? defaultPosition.dy) - 50,
        child: WordFoundEffect(
          word: word,
          // combo: combo, // Combo display disabled
          position: position ?? defaultPosition,
          onComplete: hide,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// Simple word highlight effect for found words list
class WordHighlightEffect extends StatefulWidget {
  final Widget child;
  final bool highlight;
  final Color highlightColor;
  final Duration duration;

  const WordHighlightEffect({
    super.key,
    required this.child,
    this.highlight = false,
    this.highlightColor = Colors.yellow,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<WordHighlightEffect> createState() => _WordHighlightEffectState();
}

class _WordHighlightEffectState extends State<WordHighlightEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(WordHighlightEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.highlight && !oldWidget.highlight) {
      _controller.forward().then((_) {
        if (mounted) {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.highlightColor.withOpacity(_animation.value * 0.3),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: widget.child,
        );
      },
    );
  }
}
