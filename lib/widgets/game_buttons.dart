import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Custom game button with gradient and animations
class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: _onTapCancel,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height ?? AppConstants.buttonHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.backgroundColor != null
                      ? [widget.backgroundColor!, widget.backgroundColor!.withOpacity(0.8)]
                      : [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.textColor ?? Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.textColor ?? Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.spacingS),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: widget.textColor ?? Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Submit button for word submission
class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const SubmitButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      text: 'SUBMIT',
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled ? Colors.green.shade600 : Colors.grey.shade600,
      icon: Icons.check,
    );
  }
}

/// Clear button for clearing selection
class ClearButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const ClearButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton(
      text: 'CLEAR',
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled ? Colors.red.shade600 : Colors.grey.shade600,
      icon: Icons.clear,
    );
  }
}

/// Menu button for home screen
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final IconData? icon;

  const MenuButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: GameButton(
        text: text,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        icon: icon,
        height: 60,
      ),
    );
  }
}

/// Floating action button for game actions
class GameFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final String? tooltip;

  const GameFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppConstants.primaryColor,
      tooltip: tooltip,
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}

/// Icon button with custom styling
class GameIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  const GameIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color ?? Colors.white,
        size: size ?? 24,
      ),
      tooltip: tooltip,
    );
  }
}
