import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../models/combo_system.dart';
import '../services/services.dart';
import '../providers/providers.dart';
import '../screens/results_screen.dart';

class GameScreen extends StatefulWidget {
  final GameSettings? settings;

  const GameScreen({super.key, this.settings});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession _gameSession;
  Timer? _gameTimer;
  bool _isSubmitting = false;
  bool _isInitialized = false;
  DateTime? _wordStartTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeGame();
      _startGameTimer();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Get settings from route arguments or widget parameter
    final routeSettings = ModalRoute.of(context)?.settings.arguments as GameSettings?;
    final settings = routeSettings ?? widget.settings ?? const GameSettings();

    final gameProvider = context.read<GameProvider>();
    gameProvider.startNewGame(settings);
    _gameSession = gameProvider.currentSession!;
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameSession.state == GameState.playing) {
        setState(() {
          _gameSession = GameEngine.updateTimer(
            _gameSession,
            _gameSession.timeRemaining - 1,
          );
        });

        if (_gameSession.timeRemaining <= 0) {
          _endGame();
        }
      }
    });
  }

  void _onLetterTap(int index) async {
    // Haptic feedback for letter selection
    await HapticService.lightImpact();

    final gameProvider = context.read<GameProvider>();
    final currentSession = gameProvider.currentSession;

    if (currentSession == null) return;

    // Start timing when first letter is selected
    if (currentSession.selectedLetterIndices.isEmpty) {
      _wordStartTime = DateTime.now();
    }

    gameProvider.selectLetter(index);

    setState(() {
      _gameSession = gameProvider.currentSession!;
    });

    // Show letter selection particle effect
    if (mounted) {
      final letterPosition = _getLetterPosition(index);
      ParticleOverlay.showLetterSelection(context, letterPosition);
    }
  }

  // Helper method to calculate letter position for effects
  Offset _getLetterPosition(int index) {
    final screenSize = MediaQuery.of(context).size;
    final gridWidth = screenSize.width - 32; // Account for padding
    final difficulty = _gameSession.settings.difficulty;

    final cols = difficulty.gridCols;
    final rows = difficulty.gridRows;

    final letterSize = gridWidth / cols;
    final col = index % cols;
    final row = index ~/ cols;

    final x = 16 + (col * letterSize) + (letterSize / 2);
    final y = (screenSize.height * 0.4) + (row * letterSize) + (letterSize / 2);

    return Offset(x, y);
  }

  void _onSubmitWord() async {
    final gameProvider = context.read<GameProvider>();
    final currentSession = gameProvider.currentSession;

    if (_isSubmitting || currentSession == null || currentSession.currentInput.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    // Haptic feedback for button press
    await HapticService.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));

    final result = await gameProvider.submitWord();

    // Calculate time taken to find word
    double timeToFind = 0.0;
    if (_wordStartTime != null) {
      timeToFind = DateTime.now().difference(_wordStartTime!).inMilliseconds / 1000.0;
    }

    // Debug print
    print('=== SUBMIT DEBUG ===');
    print('Word: "${currentSession.currentInput}"');
    print('Available letters: ${currentSession.letters}');
    print('Selected indices: ${currentSession.selectedLetterIndices}');
    print('Result success: ${result.success}');
    print('Result message: ${result.message}');
    print('Time to find: ${timeToFind}s');
    print('Combo: ${result.combo}');
    print('==================');

    setState(() {
      _gameSession = result.updatedSession;
      _isSubmitting = false;
    });

    // Show effects if word was found successfully
    if (result.success && result.wordFound != null) {
      final word = result.wordFound!;
      final achievementProvider = context.read<AchievementProvider>();
      await achievementProvider.trackWordFound(word, timeToFind);

      if (mounted) {
        // Show word found effect with particle explosion
        final screenCenter = Offset(
          MediaQuery.of(context).size.width * 0.5,
          MediaQuery.of(context).size.height * 0.4,
        );

        // Word found particle effect
        ParticleOverlay.showWordFound(
          context,
          screenCenter,
          word.text.length,
        );

        // Enhanced word found overlay
        WordFoundOverlay.show(
          context,
          word,
          combo: result.combo,
          position: screenCenter,
        );

        // Show combo notification for level ups
        if (result.combo != null && result.combo!.level > 1) {
          // Delay combo notification slightly
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ComboOverlay.show(context, result.combo!);

              // Combo fireworks for high levels
              if (result.combo!.level >= 3) {
                ParticleOverlay.showCombo(
                  context,
                  screenCenter,
                  result.combo!.level,
                );
              }
            }
          });
        }

        // Show time bonus animation
        TimeBonusOverlay.show(context, word.score);
      }

      // Show achievement notifications if any were unlocked
      for (final achievement in achievementProvider.newlyUnlocked) {
        if (mounted) {
          AchievementOverlay.show(context, achievement);
        }
      }
      achievementProvider.clearNewlyUnlocked();
    }

    // Reset word timing
    _wordStartTime = null;

    // Show feedback
    if (result.success) {
      _showSuccessMessage(result.message);
    } else {
      _showErrorMessage(result.message);
    }
  }

  void _onClearSelection() async {
    // Haptic feedback for clear action
    await HapticService.mediumImpact();

    final gameProvider = context.read<GameProvider>();

    // Reset word timing when clearing selection
    _wordStartTime = null;

    gameProvider.clearSelection();

    setState(() {
      _gameSession = gameProvider.currentSession!;
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _endGame() {
    _gameTimer?.cancel();

    // Use postFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _gameSession = GameEngine.endGame(_gameSession);
      });

      // Navigate to results screen with smooth transition
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(
          child: ResultsScreen(gameSession: _gameSession),
          transitionType: TransitionType.slideFromBottom,
        ),
      );
    });
  }

  void _pauseGame() {
    setState(() {
      _gameSession = GameEngine.pauseGame(_gameSession);
    });
  }

  void _resumeGame() {
    setState(() {
      _gameSession = GameEngine.resumeGame(_gameSession);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B1FA2), // Purple like in the image
              Color(0xFF512DA8), // Darker purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with timer, score, and combo
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TimerWithBonus(
                      timeRemaining: _gameSession.timeRemaining,
                      isRunning: _gameSession.state == GameState.playing,
                      onTimeUp: _endGame,
                    ),
                    // Combo display in center
                    Consumer<GameProvider>(
                      builder: (context, gameProvider, child) {
                        final combo = gameProvider.currentCombo;
                        if (combo != null && combo.level > 1) {
                          return ComboDisplay(
                            combo: combo,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    Text(
                      'SCORE: ${_gameSession.totalScore}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Letter grid
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          final session = gameProvider.currentSession;
                          if (session == null) return const SizedBox();

                          return LetterGrid(
                            letters: session.letters,
                            selectedIndices: session.selectedLetterIndices,
                            onLetterTap: _onLetterTap,
                            columns: _getOptimalColumns(session.letters.length),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Current word input
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  children: [
                    Text(
                      'Your word:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          final session = gameProvider.currentSession;
                          final currentInput = session?.currentInput ?? '';
                          return Text(
                            currentInput.isEmpty
                                ? '_ _ _ _'
                                : currentInput,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Row(
                  children: [
                    Expanded(
                      child: Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          final session = gameProvider.currentSession;
                          return SmoothButton(
                            child: SubmitButton(
                              onPressed: (session?.currentInput.isNotEmpty ?? false) ? _onSubmitWord : null,
                              isEnabled: (session?.currentInput.isNotEmpty ?? false) && !_isSubmitting,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          final session = gameProvider.currentSession;
                          return SmoothButton(
                            child: ClearButton(
                              onPressed: (session?.selectedLetterIndices.isNotEmpty ?? false) ? _onClearSelection : null,
                              isEnabled: session?.selectedLetterIndices.isNotEmpty ?? false,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Found words list with smooth animations
              Expanded(
                flex: 1,
                child: AnimatedList(
                  key: ValueKey(_gameSession.foundWords.length),
                  initialItemCount: _gameSession.foundWords.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= _gameSession.foundWords.length) {
                      return const SizedBox.shrink();
                    }
                    final word = _gameSession.foundWords[index];
                    return SmoothListItem(
                      index: index,
                      child: WordHighlightEffect(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingXS,
                          ),
                          padding: const EdgeInsets.all(AppConstants.spacingS),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                '${word.score}',
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculate optimal number of columns based on letter count
  int _getOptimalColumns(int letterCount) {
    switch (letterCount) {
      case 9:  // Easy: 3x3 grid
        return 3;
      case 12: // Medium: 4x3 grid
        return 4;
      case 15: // Hard: 5x3 grid
        return 5;
      default:
        // Fallback: calculate square-ish grid
        return (letterCount / 4).ceil().clamp(3, 5);
    }
  }
}
