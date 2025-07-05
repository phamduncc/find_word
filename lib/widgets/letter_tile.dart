import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A single letter tile widget
class LetterTile extends StatefulWidget {
  final String letter;
  final bool isSelected;
  final bool isUsed;
  final VoidCallback? onTap;
  final int? index;

  const LetterTile({
    super.key,
    required this.letter,
    this.isSelected = false,
    this.isUsed = false,
    this.onTap,
    this.index,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Color _getTileColor() {
    if (widget.isUsed) {
      return Colors.grey.shade400;
    } else if (widget.isSelected) {
      return AppConstants.secondaryColor;
    } else {
      return AppConstants.primaryColor;
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTap: widget.isUsed ? null : widget.onTap,
              child: AnimatedContainer(
                duration: AppConstants.shortAnimation,
                width: AppConstants.letterTileSize,
                height: AppConstants.letterTileSize,
                decoration: BoxDecoration(
                  color: _getTileColor(),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppConstants.secondaryColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                  border: widget.isSelected
                      ? Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.letter,
                    style: AppConstants.letterTileStyle.copyWith(
                      color: _getTextColor(),
                      fontSize: widget.isSelected ? 22 : 20,
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
}

/// A grid of letter tiles
class LetterGrid extends StatelessWidget {
  final List<String> letters;
  final List<int> selectedIndices;
  final Function(int) onLetterTap;
  final int columns;

  const LetterGrid({
    super.key,
    required this.letters,
    required this.selectedIndices,
    required this.onLetterTap,
    this.columns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppConstants.letterTileSpacing,
          mainAxisSpacing: AppConstants.letterTileSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndices.contains(index);
          
          return LetterTile(
            letter: letters[index],
            isSelected: isSelected,
            onTap: () => onLetterTap(index),
            index: index,
          );
        },
      ),
    );
  }
}

/// A horizontal scrollable list of letter tiles for word formation
class WordFormationTiles extends StatelessWidget {
  final List<String> letters;
  final List<int> selectedIndices;
  final VoidCallback? onClear;

  const WordFormationTiles({
    super.key,
    required this.letters,
    required this.selectedIndices,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndices.isEmpty) {
      return Container(
        height: AppConstants.letterTileSize + AppConstants.spacingM * 2,
        alignment: Alignment.center,
        child: Text(
          'Tap letters to form words',
          style: AppConstants.captionStyle.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return Container(
      height: AppConstants.letterTileSize + AppConstants.spacingM * 2,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedIndices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final letterIndex = entry.value;
                  
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < selectedIndices.length - 1 
                          ? AppConstants.spacingS 
                          : 0,
                    ),
                    child: LetterTile(
                      letter: letters[letterIndex],
                      isSelected: true,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: AppConstants.spacingM),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear selection',
            ),
          ],
        ],
      ),
    );
  }
}
