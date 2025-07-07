import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'time_bonus_animation.dart';

/// Enhanced game timer that can show time bonus animations
class EnhancedGameTimer extends StatefulWidget {
  final int timeRemaining; // in seconds
  final bool isRunning;
  final VoidCallback? onTimeUp;
  final Color? textColor;
  final int? lastTimeBonus; // New bonus seconds to animate

  const EnhancedGameTimer({
    super.key,
    required this.timeRemaining,
    this.isRunning = true,
    this.onTimeUp,
    this.textColor,
    this.lastTimeBonus,
  });

  @override
  State<EnhancedGameTimer> createState() => _EnhancedGameTimerState();
}

class _EnhancedGameTimerState extends State<EnhancedGameTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // For time bonus animation
  late AnimationController _bonusController;
  late Animation<double> _bonusScaleAnimation;
  late Animation<double> _bonusOpacityAnimation;
  
  int? _currentBonus;
  bool _showingBonus = false;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for low time warning
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

    // Bonus animation
    _bonusController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bonusScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bonusController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _bonusOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bonusController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(EnhancedGameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle time bonus animation
    if (widget.lastTimeBonus != null && 
        widget.lastTimeBonus != oldWidget.lastTimeBonus &&
        widget.lastTimeBonus! > 0) {
      _showTimeBonus(widget.lastTimeBonus!);
    }
    
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

  void _showTimeBonus(int bonus) {
    setState(() {
      _currentBonus = bonus;
      _showingBonus = true;
    });

    _bonusController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _showingBonus = false;
          _currentBonus = null;
        });
        _bonusController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bonusController.dispose();
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
      animation: Listenable.merge([_pulseAnimation, _bonusController]),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main timer
            Transform.scale(
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
            ),

            // Time bonus indicator
            if (_showingBonus && _currentBonus != null)
              Positioned(
                top: -30,
                right: 0,
                child: Transform.scale(
                  scale: _bonusScaleAnimation.value,
                  child: Opacity(
                    opacity: _bonusOpacityAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingS,
                        vertical: AppConstants.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                          Text(
                            '${_currentBonus}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Timer with time bonus tracking
class TimerWithBonus extends StatefulWidget {
  final int timeRemaining;
  final bool isRunning;
  final VoidCallback? onTimeUp;
  final Color? textColor;

  const TimerWithBonus({
    super.key,
    required this.timeRemaining,
    this.isRunning = true,
    this.onTimeUp,
    this.textColor,
  });

  @override
  State<TimerWithBonus> createState() => _TimerWithBonusState();
}

class _TimerWithBonusState extends State<TimerWithBonus> {
  int? _lastTimeBonus;
  int _previousTime = 0;

  @override
  void didUpdateWidget(TimerWithBonus oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detect time increase (bonus)
    if (widget.timeRemaining > oldWidget.timeRemaining) {
      final bonus = widget.timeRemaining - oldWidget.timeRemaining;
      setState(() {
        _lastTimeBonus = bonus;
      });
      
      // Clear bonus after a delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _lastTimeBonus = null;
          });
        }
      });
    }
    
    _previousTime = oldWidget.timeRemaining;
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedGameTimer(
      timeRemaining: widget.timeRemaining,
      isRunning: widget.isRunning,
      onTimeUp: widget.onTimeUp,
      textColor: widget.textColor,
      lastTimeBonus: _lastTimeBonus,
    );
  }
}
