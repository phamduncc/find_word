import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class ResultsScreen extends StatefulWidget {
  final GameSession gameSession;

  const ResultsScreen({super.key, required this.gameSession});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();

    // Check and save high score
    _checkHighScore();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _playAgain() {
    Navigator.pushReplacementNamed(
      context,
      '/game',
      arguments: widget.gameSession.settings,
    );
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  void _viewLeaderboard() {
    Navigator.pushNamed(context, '/leaderboard');
  }

  void _viewMyDictionary() {
    Navigator.pushNamed(context, '/my-dictionary');
  }

  Future<void> _checkHighScore() async {
    final highScoreProvider = context.read<HighScoreProvider>();
    final achievementProvider = context.read<AchievementProvider>();

    final isNewHighScore = await highScoreProvider.addHighScore(widget.gameSession);

    // Track game completion for achievements
    await achievementProvider.trackGameCompleted(widget.gameSession);

    if (mounted) {
      setState(() {
        _isNewHighScore = isNewHighScore;
      });

      if (isNewHighScore) {
        _showHighScoreDialog();
      }

      // Show achievement notifications if any were unlocked
      for (final achievement in achievementProvider.newlyUnlocked) {
        AchievementOverlay.show(context, achievement);
      }
      achievementProvider.clearNewlyUnlocked();
    }
  }

  void _showHighScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text(
              'New High Score!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Congratulations! You achieved a new high score of ${widget.gameSession.totalScore} points!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewLeaderboard();
            },
            child: const Text(
              'View Leaderboard',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceMessage() {
    final score = widget.gameSession.totalScore;
    final wordsFound = widget.gameSession.foundWords.length;
    
    if (score >= 500 || wordsFound >= 20) {
      return 'Outstanding! 🏆';
    } else if (score >= 300 || wordsFound >= 15) {
      return 'Excellent! 🌟';
    } else if (score >= 200 || wordsFound >= 10) {
      return 'Great job! 👏';
    } else if (score >= 100 || wordsFound >= 5) {
      return 'Good work! 👍';
    } else {
      return 'Keep practicing! 💪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1976D2),
              Color(0xFF0D47A1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeController, _slideController]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 80,
                                color: Colors.yellow.shade600,
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              const Text(
                                'GAME FINISHED!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                _getPerformanceMessage(),
                                style: TextStyle(
                                  color: Colors.yellow.shade300,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Score summary
                        Card(
                          color: Colors.white.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.spacingL),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      'Final Score',
                                      widget.gameSession.totalScore.toString(),
                                      Icons.star,
                                      Colors.yellow,
                                    ),
                                    _buildStatItem(
                                      'Words Found',
                                      widget.gameSession.foundWords.length.toString(),
                                      Icons.text_fields,
                                      Colors.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.spacingL),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      'Longest Word',
                                      widget.gameSession.longestWord?.text ?? 'None',
                                      Icons.trending_up,
                                      Colors.orange,
                                    ),
                                    _buildStatItem(
                                      'Time Played',
                                      _formatDuration(widget.gameSession.duration),
                                      Icons.timer,
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Words found list
                        Expanded(
                          child: Card(
                            color: Colors.white.withOpacity(0.1),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppConstants.spacingM),
                                  child: Text(
                                    'Words Found (${widget.gameSession.foundWords.length})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: widget.gameSession.foundWords.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No words found',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants.spacingM,
                                          ),
                                          itemCount: widget.gameSession.foundWords.length,
                                          itemBuilder: (context, index) {
                                            final word = widget.gameSession.foundWords[index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: AppConstants.spacingXS,
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: AppConstants.spacingM,
                                                vertical: AppConstants.spacingS,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(
                                                  AppConstants.borderRadius,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    word.text,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    '+${word.score}',
                                                    style: TextStyle(
                                                      color: Colors.yellow.shade300,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Action buttons
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GameButton(
                                    text: 'PLAY AGAIN',
                                    onPressed: _playAgain,
                                    backgroundColor: Colors.green.shade600,
                                    icon: Icons.refresh,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingM),
                                Expanded(
                                  child: GameButton(
                                    text: 'HOME',
                                    onPressed: _goHome,
                                    backgroundColor: Colors.orange.shade600,
                                    icon: Icons.home,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            SizedBox(
                              width: double.infinity,
                              child: GameButton(
                                text: _isNewHighScore ? 'VIEW LEADERBOARD ⭐' : 'VIEW LEADERBOARD',
                                onPressed: _viewLeaderboard,
                                backgroundColor: _isNewHighScore ? Colors.amber.shade600 : Colors.purple.shade600,
                                icon: Icons.leaderboard,
                              ),
                            ),

                            // My Dictionary button (only show if Learning Mode is enabled)
                            Consumer<SettingsProvider>(
                              builder: (context, settingsProvider, child) {
                                if (settingsProvider.settings.learningModeEnabled) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: AppConstants.spacingM),
                                      SizedBox(
                                        width: double.infinity,
                                        child: GameButton(
                                          text: 'MY DICTIONARY',
                                          onPressed: _viewMyDictionary,
                                          backgroundColor: Colors.indigo.shade600,
                                          icon: Icons.book,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
