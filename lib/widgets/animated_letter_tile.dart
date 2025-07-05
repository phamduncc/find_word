import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AnimatedLetterTile extends StatefulWidget {
  final String letter;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final VoidCallback? onTap;
  final int index;

  const AnimatedLetterTile({
    super.key,
    required this.letter,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.onTap,
    required this.index,
  });

  @override
  State<AnimatedLetterTile> createState() => _AnimatedLetterTileState();
}

class _AnimatedLetterTileState extends State<AnimatedLetterTile>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.blue.shade100,
    ).animate(_colorController);

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void didUpdateWidget(AnimatedLetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate selection state
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
        _colorController.forward();
      } else {
        _scaleController.reverse();
        _colorController.reverse();
      }
    }
    
    // Animate correct/incorrect feedback
    if (widget.isCorrect && !oldWidget.isCorrect) {
      _animateCorrect();
    } else if (widget.isIncorrect && !oldWidget.isIncorrect) {
      _animateIncorrect();
    }
  }

  void _animateCorrect() {
    _colorController.animateTo(1.0);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _colorController.animateTo(0.0);
      }
    });
  }

  void _animateIncorrect() {
    _shakeController.forward().then((_) {
      if (mounted) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _colorAnimation,
        _shakeAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _shakeAnimation.value * 10 * (widget.index % 2 == 0 ? 1 : -1),
              0,
            ),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: widget.isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: widget.isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.letter.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (widget.isCorrect) {
      return Colors.green.shade100;
    } else if (widget.isIncorrect) {
      return Colors.red.shade100;
    } else if (widget.isSelected) {
      return _colorAnimation.value ?? Colors.blue.shade100;
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (widget.isCorrect) {
      return Colors.green;
    } else if (widget.isIncorrect) {
      return Colors.red;
    } else if (widget.isSelected) {
      return Colors.blue;
    }
    return Colors.grey.shade300;
  }

  Color _getTextColor() {
    if (widget.isCorrect) {
      return Colors.green.shade800;
    } else if (widget.isIncorrect) {
      return Colors.red.shade800;
    } else if (widget.isSelected) {
      return Colors.blue.shade800;
    }
    return Colors.black87;
  }
}
