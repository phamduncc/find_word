import 'dart:math';
import 'package:flutter/material.dart';

/// Individual particle for effects
class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double life;
  late double maxLife;
  late Color color;
  late double size;
  late double gravity;
  late double alpha;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
    this.gravity = 0.5,
  }) {
    maxLife = life;
    alpha = 1.0;
  }

  void update() {
    x += vx;
    y += vy;
    vy += gravity;
    life -= 1;
    alpha = life / maxLife;
  }

  bool get isDead => life <= 0;
}

/// Particle system widget for various effects
class ParticleSystem extends StatefulWidget {
  final List<Particle> particles;
  final Duration duration;
  final VoidCallback? onComplete;

  const ParticleSystem({
    super.key,
    required this.particles,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.from(widget.particles);
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        _particles.forEach((particle) => particle.update());
        _particles.removeWhere((particle) => particle.isDead);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(_particles),
      size: Size.infinite,
    );
  }
}

/// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Factory for creating different particle effects
class ParticleEffects {
  static final Random _random = Random();

  /// Create explosion effect for word found
  static List<Particle> createWordExplosion({
    required Offset center,
    required int wordLength,
    Color? color,
  }) {
    final particles = <Particle>[];
    final particleCount = (wordLength * 3).clamp(6, 20);
    final baseColor = color ?? Colors.yellow;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      final speed = _random.nextDouble() * 3 + 2;
      final size = _random.nextDouble() * 3 + 2;
      final life = _random.nextDouble() * 30 + 30;

      particles.add(Particle(
        x: center.dx,
        y: center.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: life,
        color: _randomizeColor(baseColor),
        size: size,
        gravity: 0.1,
      ));
    }

    return particles;
  }

  /// Create combo fireworks effect
  static List<Particle> createComboFireworks({
    required Offset center,
    required int comboLevel,
  }) {
    final particles = <Particle>[];
    final particleCount = (comboLevel * 5).clamp(10, 50);
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 5 + 3;
      final size = _random.nextDouble() * 4 + 2;
      final life = _random.nextDouble() * 40 + 40;
      final color = colors[_random.nextInt(colors.length)];

      particles.add(Particle(
        x: center.dx,
        y: center.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: life,
        color: color,
        size: size,
        gravity: 0.2,
      ));
    }

    return particles;
  }

  /// Create sparkle effect for achievements
  static List<Particle> createSparkles({
    required Offset center,
    int count = 15,
    Color? color,
  }) {
    final particles = <Particle>[];
    final baseColor = color ?? const Color(0xFFFFD700); // Gold color

    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = _random.nextDouble() * 50 + 20;
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;
      final size = _random.nextDouble() * 2 + 1;
      final life = _random.nextDouble() * 20 + 20;

      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 2,
        vy: (_random.nextDouble() - 0.5) * 2,
        life: life,
        color: _randomizeColor(baseColor),
        size: size,
        gravity: 0.05,
      ));
    }

    return particles;
  }

  /// Create cascading effect for time bonus
  static List<Particle> createTimeBonusCascade({
    required Offset start,
    required Offset end,
    int count = 20,
  }) {
    final particles = <Particle>[];
    final colors = [Colors.green.shade300, Colors.green.shade500, Colors.green.shade700];

    for (int i = 0; i < count; i++) {
      final progress = i / count;
      final x = start.dx + (end.dx - start.dx) * progress;
      final y = start.dy + (end.dy - start.dy) * progress;
      final size = _random.nextDouble() * 2 + 1;
      final life = _random.nextDouble() * 25 + 25;
      final color = colors[_random.nextInt(colors.length)];

      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 3,
        vy: _random.nextDouble() * -2 - 1,
        life: life,
        color: color,
        size: size,
        gravity: 0.15,
      ));
    }

    return particles;
  }

  /// Create letter selection effect
  static List<Particle> createLetterSelection({
    required Offset center,
    Color? color,
  }) {
    final particles = <Particle>[];
    final baseColor = color ?? Colors.blue;
    const count = 8;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final speed = _random.nextDouble() * 2 + 1;
      final size = _random.nextDouble() * 1.5 + 1;
      final life = _random.nextDouble() * 15 + 15;

      particles.add(Particle(
        x: center.dx,
        y: center.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: life,
        color: _randomizeColor(baseColor),
        size: size,
        gravity: 0.05,
      ));
    }

    return particles;
  }

  /// Randomize color slightly for variety
  static Color _randomizeColor(Color baseColor) {
    final r = (baseColor.red + _random.nextInt(40) - 20).clamp(0, 255);
    final g = (baseColor.green + _random.nextInt(40) - 20).clamp(0, 255);
    final b = (baseColor.blue + _random.nextInt(40) - 20).clamp(0, 255);
    return Color.fromARGB(baseColor.alpha, r, g, b);
  }
}

/// Overlay for showing particle effects
class ParticleOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context,
    List<Particle> particles, {
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onComplete,
  }) {
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: ParticleSystem(
            particles: particles,
            duration: duration,
            onComplete: () {
              hide();
              onComplete?.call();
            },
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

  /// Show word found effect
  static void showWordFound(
    BuildContext context,
    Offset position,
    int wordLength, {
    Color? color,
  }) {
    final particles = ParticleEffects.createWordExplosion(
      center: position,
      wordLength: wordLength,
      color: color,
    );
    show(context, particles);
  }

  /// Show combo effect
  static void showCombo(
    BuildContext context,
    Offset position,
    int comboLevel,
  ) {
    final particles = ParticleEffects.createComboFireworks(
      center: position,
      comboLevel: comboLevel,
    );
    show(context, particles, duration: const Duration(seconds: 3));
  }

  /// Show achievement sparkles
  static void showAchievement(
    BuildContext context,
    Offset position, {
    Color? color,
  }) {
    final particles = ParticleEffects.createSparkles(
      center: position,
      color: color,
    );
    show(context, particles);
  }

  /// Show time bonus cascade
  static void showTimeBonus(
    BuildContext context,
    Offset start,
    Offset end,
  ) {
    final particles = ParticleEffects.createTimeBonusCascade(
      start: start,
      end: end,
    );
    show(context, particles);
  }

  /// Show letter selection effect
  static void showLetterSelection(
    BuildContext context,
    Offset position, {
    Color? color,
  }) {
    final particles = ParticleEffects.createLetterSelection(
      center: position,
      color: color,
    );
    show(context, particles, duration: const Duration(milliseconds: 800));
  }
}
