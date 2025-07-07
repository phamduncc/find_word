import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class AchievementNotification extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementNotification> createState() => _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(AppConstants.spacingM),
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.achievement.type.color,
                      widget.achievement.type.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Achievement unlocked text
                    const Text(
                      'ACHIEVEMENT UNLOCKED!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConstants.spacingM),

                    // Achievement icon and details
                    Row(
                      children: [
                        // Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.achievement.type.icon,
                            color: widget.achievement.type.color,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: AppConstants.spacingM),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.achievement.type.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingXS),
                              Text(
                                widget.achievement.type.description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Points
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingS,
                            vertical: AppConstants.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: widget.achievement.type.color,
                                size: 16,
                              ),
                              const SizedBox(width: AppConstants.spacingXS),
                              Text(
                                '+${widget.achievement.type.points}',
                                style: TextStyle(
                                  color: widget.achievement.type.color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacingM),

                    // Tap to dismiss hint
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingM,
                          vertical: AppConstants.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: const Text(
                          'Tap to dismiss',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
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
}

/// Show achievement notification as an overlay
class AchievementOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, Achievement achievement) {
    // Remove existing overlay if any
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: AchievementNotification(
          achievement: achievement,
          onDismiss: hide,
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

/// Show multiple achievements in sequence
class AchievementQueue {
  static final List<Achievement> _queue = [];
  static bool _isShowing = false;

  static void addAchievement(Achievement achievement) {
    _queue.add(achievement);
  }

  static void showNext(BuildContext context) {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;
    final achievement = _queue.removeAt(0);

    AchievementOverlay.show(context, achievement);

    // Show next achievement after delay
    Future.delayed(const Duration(seconds: 5), () {
      _isShowing = false;
      if (_queue.isNotEmpty) {
        showNext(context);
      }
    });
  }

  static void clear() {
    _queue.clear();
    _isShowing = false;
  }
}
