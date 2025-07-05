import 'package:flutter/material.dart';
import '../widgets/animated_letter_tile.dart';
import '../services/sound_service.dart';
import '../utils/performance_utils.dart';
import '../constants/app_constants.dart';

class OptimizedLetterGrid extends StatefulWidget {
  final List<String> letters;
  final List<int> selectedIndices;
  final List<int> correctIndices;
  final List<int> incorrectIndices;
  final Function(int index) onLetterTap;
  final bool isInteractive;

  const OptimizedLetterGrid({
    super.key,
    required this.letters,
    required this.selectedIndices,
    this.correctIndices = const [],
    this.incorrectIndices = const [],
    required this.onLetterTap,
    this.isInteractive = true,
  });

  @override
  State<OptimizedLetterGrid> createState() => _OptimizedLetterGridState();
}

class _OptimizedLetterGridState extends State<OptimizedLetterGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = AnimationUtils.createStaggeredControllers(
      vsync: this,
      count: widget.letters.length,
      duration: const Duration(milliseconds: 300),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    // Start staggered entrance animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnimationUtils.startStaggeredAnimations(_controllers);
    });
  }

  @override
  void dispose() {
    AnimationUtils.disposeControllers(_controllers);
    super.dispose();
  }

  void _handleLetterTap(int index) async {
    if (!widget.isInteractive) return;

    // Performance measurement
    await PerformanceUtils.measureAsync('letter_tap', () async {
      // Haptic feedback
      await HapticService.letterSelect();
      
      // Sound effect
      await SoundService.playLetterSelect();
      
      // Call the callback
      widget.onLetterTap(index);
    });
  }

  int _getGridSize() {
    return UIUtils.getOptimalGridSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = _getGridSize();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = UIUtils.isTablet(context);
    
    // Calculate responsive sizing
    final padding = UIUtils.getResponsiveSpacing(16.0, screenWidth);
    final spacing = UIUtils.getResponsiveSpacing(8.0, screenWidth);
    
    return Container(
      padding: EdgeInsets.all(padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - (padding * 2);
          final tileSize = (availableWidth - (spacing * (gridSize - 1))) / gridSize;
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.letters.length,
            itemBuilder: (context, index) {
              return _buildLetterTile(index, tileSize);
            },
          );
        },
      ),
    );
  }

  Widget _buildLetterTile(int index, double size) {
    final isSelected = widget.selectedIndices.contains(index);
    final isCorrect = widget.correctIndices.contains(index);
    final isIncorrect = widget.incorrectIndices.contains(index);

    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _animations[index].value,
          child: Opacity(
            opacity: _animations[index].value,
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedLetterTile(
                letter: widget.letters[index],
                index: index,
                isSelected: isSelected,
                isCorrect: isCorrect,
                isIncorrect: isIncorrect,
                onTap: widget.isInteractive ? () => _handleLetterTap(index) : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LetterConnectionOverlay extends StatefulWidget {
  final List<int> selectedIndices;
  final List<String> letters;
  final int gridSize;
  final double tileSize;
  final double spacing;

  const LetterConnectionOverlay({
    super.key,
    required this.selectedIndices,
    required this.letters,
    required this.gridSize,
    required this.tileSize,
    required this.spacing,
  });

  @override
  State<LetterConnectionOverlay> createState() => _LetterConnectionOverlayState();
}

class _LetterConnectionOverlayState extends State<LetterConnectionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(LetterConnectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndices.length != oldWidget.selectedIndices.length) {
      if (widget.selectedIndices.length > 1) {
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

  Offset _getPositionForIndex(int index) {
    final row = index ~/ widget.gridSize;
    final col = index % widget.gridSize;
    
    final x = col * (widget.tileSize + widget.spacing) + widget.tileSize / 2;
    final y = row * (widget.tileSize + widget.spacing) + widget.tileSize / 2;
    
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedIndices.length < 2) {
      return const SizedBox.shrink();
    }

    final positions = widget.selectedIndices
        .map((index) => _getPositionForIndex(index))
        .toList();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConnectionLinePainter(
            positions: positions,
            progress: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConnectionLinePainter extends CustomPainter {
  final List<Offset> positions;
  final double progress;

  ConnectionLinePainter({
    required this.positions,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(positions.first.dx, positions.first.dy);

    for (int i = 1; i < positions.length; i++) {
      final segmentProgress = ((progress * positions.length) - i + 1).clamp(0.0, 1.0);
      
      if (segmentProgress > 0) {
        final start = positions[i - 1];
        final end = positions[i];
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * segmentProgress,
          start.dy + (end.dy - start.dy) * segmentProgress,
        );
        
        path.lineTo(currentEnd.dx, currentEnd.dy);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots at positions
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < positions.length; i++) {
      final dotProgress = ((progress * positions.length) - i).clamp(0.0, 1.0);
      if (dotProgress > 0) {
        canvas.drawCircle(
          positions[i],
          4 * dotProgress,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConnectionLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.positions != positions;
  }
}
