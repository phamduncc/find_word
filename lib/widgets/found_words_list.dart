import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

/// Widget to display list of found words
class FoundWordsList extends StatelessWidget {
  final List<Word> words;
  final bool showScores;
  final ScrollController? scrollController;

  const FoundWordsList({
    super.key,
    required this.words,
    this.showScores = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Words found:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Start finding words!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
            child: Text(
              'Words found:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[words.length - 1 - index]; // Show newest first
                return _WordItem(
                  word: word,
                  showScore: showScores,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WordItem extends StatefulWidget {
  final Word word;
  final bool showScore;
  final int index;

  const _WordItem({
    required this.word,
    required this.showScore,
    required this.index,
  });

  @override
  State<_WordItem> createState() => _WordItemState();
}

class _WordItemState extends State<_WordItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getWordColor() {
    final length = widget.word.text.length;
    if (length >= 7) {
      return Colors.purple.shade300;
    } else if (length >= 5) {
      return Colors.blue.shade300;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingXS),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: _getWordColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.word.text,
                      style: TextStyle(
                        color: _getWordColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.showScore) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getWordColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${widget.word.score}',
                        style: TextStyle(
                          color: _getWordColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact horizontal list of found words
class CompactWordsList extends StatelessWidget {
  final List<Word> words;
  final int maxVisible;

  const CompactWordsList({
    super.key,
    required this.words,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    final visibleWords = words.take(maxVisible).toList();
    final hasMore = words.length > maxVisible;

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visibleWords.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == visibleWords.length) {
            // Show "more" indicator
            return Container(
              margin: const EdgeInsets.only(left: AppConstants.spacingXS),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingS,
                vertical: AppConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '+${words.length - maxVisible}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          final word = visibleWords[index];
          return Container(
            margin: EdgeInsets.only(
              left: index > 0 ? AppConstants.spacingXS : 0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingS,
              vertical: AppConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                word.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
