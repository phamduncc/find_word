import 'package:flutter/material.dart';

class WordValidationAnimation extends StatefulWidget {
  final String word;
  final bool isValid;
  final int points;
  final VoidCallback? onComplete;

  const WordValidationAnimation({
    super.key,
    required this.word,
    required this.isValid,
    this.points = 0,
    this.onComplete,
  });

  @override
  State<WordValidationAnimation> createState() => _WordValidationAnimationState();
}

class _WordValidationAnimationState extends State<WordValidationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _colorAnimation = ColorTween(
      begin: widget.isValid ? Colors.green : Colors.red,
      end: widget.isValid ? Colors.green.shade300 : Colors.red.shade300,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onComplete?.call();
        }
      });
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
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isValid ? Icons.check_circle : Icons.cancel,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.word.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isValid && widget.points > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${widget.points} points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (!widget.isValid) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Invalid word',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class LetterConnectionAnimation extends StatefulWidget {
  final List<Offset> letterPositions;
  final Duration duration;

  const LetterConnectionAnimation({
    super.key,
    required this.letterPositions,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<LetterConnectionAnimation> createState() => _LetterConnectionAnimationState();
}

class _LetterConnectionAnimationState extends State<LetterConnectionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: LetterConnectionPainter(
            letterPositions: widget.letterPositions,
            progress: _progressAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class LetterConnectionPainter extends CustomPainter {
  final List<Offset> letterPositions;
  final double progress;

  LetterConnectionPainter({
    required this.letterPositions,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (letterPositions.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(letterPositions.first.dx, letterPositions.first.dy);

    for (int i = 1; i < letterPositions.length; i++) {
      final currentProgress = (progress * letterPositions.length - i + 1).clamp(0.0, 1.0);
      
      if (currentProgress > 0) {
        final start = letterPositions[i - 1];
        final end = letterPositions[i];
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * currentProgress,
          start.dy + (end.dy - start.dy) * currentProgress,
        );
        
        path.lineTo(currentEnd.dx, currentEnd.dy);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots at letter positions
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < letterPositions.length; i++) {
      final dotProgress = (progress * letterPositions.length - i).clamp(0.0, 1.0);
      if (dotProgress > 0) {
        canvas.drawCircle(
          letterPositions[i],
          6 * dotProgress,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(LetterConnectionPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.letterPositions != letterPositions;
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with TickerProviderStateMixin {
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
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
