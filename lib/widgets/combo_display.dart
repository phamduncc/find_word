import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/combo_system.dart';

/// Widget to display current combo information
class ComboDisplay extends StatefulWidget {
  final ComboStreak? combo;
  final bool showAnimation;

  const ComboDisplay({
    super.key,
    this.combo,
    this.showAnimation = true,
  });

  @override
  State<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends State<ComboDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ComboDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.combo != null && oldWidget.combo != widget.combo) {
      if (widget.showAnimation) {
        _scaleController.forward(from: 0);
        
        // Pulse for high level combos
        if (widget.combo!.level >= 3) {
          _pulseController.repeat(reverse: true);
        }
      }
    }

    if (widget.combo == null && oldWidget.combo != null) {
      _pulseController.stop();
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.combo == null) {
      return const SizedBox.shrink();
    }

    final combo = widget.combo!;
    final color = ComboStreak.getComboColor(combo.level);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        final scale = widget.showAnimation 
            ? _scaleAnimation.value * (combo.level >= 3 ? _pulseAnimation.value : 1.0)
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getComboIcon(combo.level),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      combo.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${combo.wordsInStreak} words • ${combo.multiplier.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getComboIcon(int level) {
    switch (level) {
      case 1: return Icons.flash_on;
      case 2: return Icons.whatshot;
      case 3: return Icons.local_fire_department;
      case 4: return Icons.rocket_launch;
      case 5: return Icons.auto_awesome;
      case 6: return Icons.diamond;
      default: return Icons.flash_on;
    }
  }
}

/// Animated combo notification
class ComboNotification extends StatefulWidget {
  final ComboStreak combo;
  final VoidCallback? onComplete;

  const ComboNotification({
    super.key,
    required this.combo,
    this.onComplete,
  });

  @override
  State<ComboNotification> createState() => _ComboNotificationState();
}

class _ComboNotificationState extends State<ComboNotification>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ComboStreak.getComboColor(widget.combo.level);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value * 50,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.9),
                      color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getComboIcon(widget.combo.level),
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      widget.combo.description.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      '${widget.combo.wordsInStreak} WORDS • ${widget.combo.multiplier.toStringAsFixed(1)}X MULTIPLIER',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getComboIcon(int level) {
    switch (level) {
      case 1: return Icons.flash_on;
      case 2: return Icons.whatshot;
      case 3: return Icons.local_fire_department;
      case 4: return Icons.rocket_launch;
      case 5: return Icons.auto_awesome;
      case 6: return Icons.diamond;
      default: return Icons.flash_on;
    }
  }
}

/// Overlay for showing combo notifications
class ComboOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, ComboStreak combo) {
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.25,
        left: 0,
        right: 0,
        child: Center(
          child: ComboNotification(
            combo: combo,
            onComplete: hide,
          ),
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

/// Compact combo indicator for game UI
class ComboIndicator extends StatelessWidget {
  final ComboStreak? combo;
  final bool showMultiplier;

  const ComboIndicator({
    super.key,
    this.combo,
    this.showMultiplier = true,
  });

  @override
  Widget build(BuildContext context) {
    if (combo == null) {
      return const SizedBox.shrink();
    }

    final color = ComboStreak.getComboColor(combo!.level);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            showMultiplier 
                ? '${combo!.multiplier.toStringAsFixed(1)}x'
                : '${combo!.wordsInStreak}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
