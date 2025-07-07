import 'package:flutter/material.dart';

/// Custom page route with smooth transitions
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;

  SmoothPageRoute({
    required this.child,
    this.transitionType = TransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
        );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
  ) {
    switch (type) {
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.fadeIn:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case TransitionType.scaleIn:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case TransitionType.rotateIn:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
    }
  }
}

/// Types of page transitions
enum TransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fadeIn,
  scaleIn,
  rotateIn,
}

/// Enhanced animated container with smooth state changes
class SmoothAnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final bool animate;

  const SmoothAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.animate = true,
  });

  @override
  State<SmoothAnimatedContainer> createState() => _SmoothAnimatedContainerState();
}

class _SmoothAnimatedContainerState extends State<SmoothAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SmoothAnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    if (widget.animate && !oldWidget.animate) {
      _controller.forward();
    } else if (!widget.animate && oldWidget.animate) {
      _controller.value = 1.0;
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
      animation: _controller,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        );

        return AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          margin: widget.margin,
          decoration: widget.decoration,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(animation),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Smooth list item animation
class SmoothListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const SmoothListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutBack,
  });

  @override
  State<SmoothListItem> createState() => _SmoothListItemState();
}

class _SmoothListItemState extends State<SmoothListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Staggered animation based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
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
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Smooth button with press animation
class SmoothButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleDown;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const SmoothButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.scaleDown = 0.95,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<SmoothButton> createState() => _SmoothButtonState();
}

class _SmoothButtonState extends State<SmoothButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Smooth state transition widget
class SmoothStateTransition extends StatefulWidget {
  final Widget child;
  final bool show;
  final Duration duration;
  final Curve curve;
  final TransitionType transitionType;

  const SmoothStateTransition({
    super.key,
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.transitionType = TransitionType.fadeIn,
  });

  @override
  State<SmoothStateTransition> createState() => _SmoothStateTransitionState();
}

class _SmoothStateTransitionState extends State<SmoothStateTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SmoothStateTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    switch (widget.transitionType) {
      case TransitionType.fadeIn:
        return FadeTransition(
          opacity: animation,
          child: widget.child,
        );

      case TransitionType.scaleIn:
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: widget.child,
          ),
        );

      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: widget.child,
          ),
        );

      default:
        return FadeTransition(
          opacity: animation,
          child: widget.child,
        );
    }
  }
}
