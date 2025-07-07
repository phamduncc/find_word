import 'package:flutter/material.dart';
import '../services/tts_service.dart';

/// Button widget for word pronunciation
class PronunciationButton extends StatefulWidget {
  final String word;
  final String? phonetic;
  final double size;
  final Color? color;
  final bool showLabel;
  final VoidCallback? onPressed;

  const PronunciationButton({
    Key? key,
    required this.word,
    this.phonetic,
    this.size = 24.0,
    this.color,
    this.showLabel = false,
    this.onPressed,
  }) : super(key: key);

  @override
  State<PronunciationButton> createState() => _PronunciationButtonState();
}

class _PronunciationButtonState extends State<PronunciationButton>
    with SingleTickerProviderStateMixin {
  bool _isSpeaking = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (_isSpeaking) return;

    widget.onPressed?.call();

    setState(() {
      _isSpeaking = true;
    });

    _animationController.repeat(reverse: true);

    try {
      if (widget.phonetic?.isNotEmpty == true) {
        await TTSService.speakWithPhonetic(widget.word, widget.phonetic);
      } else {
        await TTSService.speak(widget.word);
      }
    } finally {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSpeaking ? _scaleAnimation.value : 1.0,
          child: Transform.rotate(
            angle: _isSpeaking ? _rotationAnimation.value : 0.0,
            child: widget.showLabel
                ? _buildButtonWithLabel(effectiveColor)
                : _buildIconButton(effectiveColor),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(Color color) {
    return IconButton(
      onPressed: _isSpeaking ? null : _handlePress,
      icon: _isSpeaking
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(
              Icons.volume_up,
              size: widget.size,
              color: color,
            ),
      tooltip: _isSpeaking ? 'Speaking...' : 'Pronounce "${widget.word}"',
      splashRadius: widget.size,
    );
  }

  Widget _buildButtonWithLabel(Color color) {
    return ElevatedButton.icon(
      onPressed: _isSpeaking ? null : _handlePress,
      icon: _isSpeaking
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.volume_up, size: 16),
      label: Text(_isSpeaking ? 'Speaking...' : 'Pronounce'),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Compact pronunciation button for word lists
class CompactPronunciationButton extends StatefulWidget {
  final String word;
  final String? phonetic;
  final VoidCallback? onPressed;

  const CompactPronunciationButton({
    Key? key,
    required this.word,
    this.phonetic,
    this.onPressed,
  }) : super(key: key);

  @override
  State<CompactPronunciationButton> createState() => _CompactPronunciationButtonState();
}

class _CompactPronunciationButtonState extends State<CompactPronunciationButton> {
  bool _isSpeaking = false;

  Future<void> _handlePress() async {
    if (_isSpeaking) return;

    widget.onPressed?.call();

    setState(() {
      _isSpeaking = true;
    });

    try {
      if (widget.phonetic?.isNotEmpty == true) {
        await TTSService.speakWithPhonetic(widget.word, widget.phonetic);
      } else {
        await TTSService.speak(widget.word);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isSpeaking ? null : _handlePress,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _isSpeaking ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _isSpeaking ? Colors.blue : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: _isSpeaking
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.volume_up,
                size: 16,
                color: Colors.grey[600],
              ),
      ),
    );
  }
}

/// Pronunciation guide widget showing phonetic spelling
class PronunciationGuide extends StatelessWidget {
  final String word;
  final String? phonetic;
  final bool showPronunciationButton;

  const PronunciationGuide({
    Key? key,
    required this.word,
    this.phonetic,
    this.showPronunciationButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayPhonetic = phonetic ?? '';

    if (displayPhonetic.isEmpty && !showPronunciationButton) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.record_voice_over,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pronunciation:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                if (displayPhonetic.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    displayPhonetic,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showPronunciationButton)
            PronunciationButton(
              word: word,
              phonetic: phonetic,
              size: 20,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}

/// Floating pronunciation button for overlay
class FloatingPronunciationButton extends StatelessWidget {
  final String word;
  final String? phonetic;
  final VoidCallback? onPressed;

  const FloatingPronunciationButton({
    Key? key,
    required this.word,
    this.phonetic,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      heroTag: 'pronunciation_${word}_${DateTime.now().millisecondsSinceEpoch}',
      child: PronunciationButton(
        word: word,
        phonetic: phonetic,
        size: 20,
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
