import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Widget to display current score and game statistics
class ScoreBoard extends StatefulWidget {
  final int score;
  final int wordsFound;
  final String longestWord;
  final Duration timeElapsed;
  final bool showDetailed;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.wordsFound,
    this.longestWord = '',
    this.timeElapsed = Duration.zero,
    this.showDetailed = false,
  });

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.addListener(() {
      setState(() {
        _displayedScore = _scoreAnimation.value.round();
      });
    });

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ScoreBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.score != oldWidget.score) {
      _scoreAnimation = Tween<double>(
        begin: _displayedScore.toDouble(),
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: widget.showDetailed 
            ? _buildDetailedView() 
            : _buildCompactView(),
      ),
    );
  }

  Widget _buildCompactView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildScoreItem(
          icon: Icons.star,
          label: 'Score',
          value: _displayedScore.toString(),
          color: AppConstants.primaryColor,
        ),
        _buildScoreItem(
          icon: Icons.text_fields,
          label: 'Words',
          value: widget.wordsFound.toString(),
          color: AppConstants.successColor,
        ),
        if (widget.longestWord.isNotEmpty)
          _buildScoreItem(
            icon: Icons.trending_up,
            label: 'Longest',
            value: widget.longestWord,
            color: AppConstants.warningColor,
          ),
      ],
    );
  }

  Widget _buildDetailedView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildScoreItem(
              icon: Icons.star,
              label: 'Score',
              value: _displayedScore.toString(),
              color: AppConstants.primaryColor,
              isLarge: true,
            ),
            _buildScoreItem(
              icon: Icons.text_fields,
              label: 'Words Found',
              value: widget.wordsFound.toString(),
              color: AppConstants.successColor,
              isLarge: true,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.longestWord.isNotEmpty)
              _buildScoreItem(
                icon: Icons.trending_up,
                label: 'Longest Word',
                value: widget.longestWord,
                color: AppConstants.warningColor,
              ),
            _buildScoreItem(
              icon: Icons.timer,
              label: 'Time',
              value: _formatTime(widget.timeElapsed),
              color: AppConstants.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLarge = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: isLarge ? 32 : 24,
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          value,
          style: isLarge 
              ? AppConstants.scoreStyle.copyWith(color: color)
              : AppConstants.subheadingStyle.copyWith(color: color),
        ),
        Text(
          label,
          style: AppConstants.captionStyle.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Widget to display score change animation
class ScoreChangeIndicator extends StatefulWidget {
  final int scoreChange;
  final String? message;

  const ScoreChangeIndicator({
    super.key,
    required this.scoreChange,
    this.message,
  });

  @override
  State<ScoreChangeIndicator> createState() => _ScoreChangeIndicatorState();
}

class _ScoreChangeIndicatorState extends State<ScoreChangeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: -50,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: widget.scoreChange > 0 
                    ? AppConstants.successColor 
                    : AppConstants.errorColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.scoreChange > 0 ? '+' : ''}${widget.scoreChange}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
