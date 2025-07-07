import 'package:flutter/material.dart';

/// Indicator widget to show Learning Mode status
class LearningModeIndicator extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback? onTap;
  final bool showLabel;
  final double size;

  const LearningModeIndicator({
    Key? key,
    required this.isEnabled,
    this.onTap,
    this.showLabel = true,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<LearningModeIndicator> createState() => _LearningModeIndicatorState();
}

class _LearningModeIndicatorState extends State<LearningModeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LearningModeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isEnabled ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.isEnabled ? _rotationAnimation.value : 0.0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isEnabled 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isEnabled ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                child: widget.showLabel
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isEnabled ? Icons.school : Icons.school_outlined,
                            size: widget.size,
                            color: widget.isEnabled ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Learning Mode',
                            style: TextStyle(
                              fontSize: widget.size * 0.6,
                              fontWeight: FontWeight.w600,
                              color: widget.isEnabled ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        widget.isEnabled ? Icons.school : Icons.school_outlined,
                        size: widget.size,
                        color: widget.isEnabled ? Colors.green : Colors.grey,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Floating Learning Mode toggle button
class LearningModeToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final String? tooltip;

  const LearningModeToggle({
    Key? key,
    required this.isEnabled,
    required this.onChanged,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'Toggle Learning Mode',
      child: FloatingActionButton.small(
        onPressed: () => onChanged(!isEnabled),
        backgroundColor: isEnabled ? Colors.green : Colors.grey[300],
        foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
        heroTag: 'learning_mode_toggle',
        child: Icon(
          isEnabled ? Icons.school : Icons.school_outlined,
          size: 20,
        ),
      ),
    );
  }
}

/// Learning progress indicator for words
class WordLearningProgress extends StatelessWidget {
  final int timesEncountered;
  final double accuracy;
  final String masteryLevel;
  final bool isCompact;

  const WordLearningProgress({
    Key? key,
    required this.timesEncountered,
    required this.accuracy,
    required this.masteryLevel,
    this.isCompact = false,
  }) : super(key: key);

  Color get _masteryColor {
    switch (masteryLevel.toLowerCase()) {
      case 'mastered':
        return Colors.green;
      case 'proficient':
        return Colors.blue;
      case 'learning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get _masteryIcon {
    switch (masteryLevel.toLowerCase()) {
      case 'mastered':
        return Icons.star;
      case 'proficient':
        return Icons.trending_up;
      case 'learning':
        return Icons.school;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _masteryIcon,
            size: 16,
            color: _masteryColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${accuracy.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _masteryColor,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _masteryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _masteryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _masteryIcon,
                size: 20,
                color: _masteryColor,
              ),
              const SizedBox(width: 8),
              Text(
                masteryLevel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _masteryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encountered: $timesEncountered times',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: accuracy / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_masteryColor),
                strokeWidth: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge to show new words learned
class NewWordBadge extends StatefulWidget {
  final int count;
  final VoidCallback? onTap;

  const NewWordBadge({
    Key? key,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  State<NewWordBadge> createState() => _NewWordBadgeState();
}

class _NewWordBadgeState extends State<NewWordBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.count > 0) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NewWordBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      if (widget.count > 0) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fiber_new,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.count}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
