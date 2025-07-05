import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Widget to display game timer
class GameTimer extends StatefulWidget {
  final int timeRemaining; // in seconds
  final bool isRunning;
  final VoidCallback? onTimeUp;
  final Color? textColor;

  const GameTimer({
    super.key,
    required this.timeRemaining,
    this.isRunning = true,
    this.onTimeUp,
    this.textColor,
  });

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(GameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start pulsing when time is low
    if (widget.timeRemaining <= 10 && widget.timeRemaining > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Call onTimeUp when time reaches 0
    if (widget.timeRemaining <= 0 && oldWidget.timeRemaining > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimeUp?.call();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (widget.textColor != null) return widget.textColor!;
    
    if (widget.timeRemaining <= 10) {
      return Colors.red;
    } else if (widget.timeRemaining <= 30) {
      return Colors.orange;
    } else {
      return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.timeRemaining <= 10 ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  color: _getTimerColor(),
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  'TIME: ${_formatTime(widget.timeRemaining)}',
                  style: TextStyle(
                    color: _getTimerColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Circular progress timer widget
class CircularTimer extends StatefulWidget {
  final int totalTime;
  final int timeRemaining;
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;

  const CircularTimer({
    super.key,
    required this.totalTime,
    required this.timeRemaining,
    this.progressColor,
    this.backgroundColor,
    this.size = 60.0,
  });

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeRemaining != oldWidget.timeRemaining) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalTime > 0 
        ? widget.timeRemaining / widget.totalTime 
        : 0.0;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: widget.backgroundColor ?? Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.progressColor ?? _getProgressColor(progress),
            ),
          ),
          Center(
            child: Text(
              widget.timeRemaining.toString(),
              style: TextStyle(
                fontSize: widget.size * 0.25,
                fontWeight: FontWeight.bold,
                color: widget.progressColor ?? _getProgressColor(progress),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress <= 0.1) {
      return Colors.red;
    } else if (progress <= 0.3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
