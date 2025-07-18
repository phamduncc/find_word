import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../widgets/word_definition_dialog.dart';
import '../widgets/learning_mode_indicator.dart';
import '../models/models.dart';
import '../models/power_up.dart';

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
  GameSession? _gameSession;
  Timer? _gameTimer;
  bool _isSubmitting = false;
  bool _isInitialized = false;
  DateTime? _wordStartTime;
  bool _isTimerFrozen = false;
  Timer? _freezeTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Defer initialization to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeGame();
        _startGameTimer();
      });
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _freezeTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Get settings from route arguments or widget parameter
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    GameSettings? routeSettings;
    if (routeArgs is GameSettings) {
      routeSettings = routeArgs;
    }
    final settings = routeSettings ?? widget.settings ?? const GameSettings();

    final gameProvider = context.read<GameProvider>();
    gameProvider.startNewGame(settings);
    _gameSession = gameProvider.currentSession!;
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final session = _gameSession;
      if (session != null && session.state == GameState.playing && !_isTimerFrozen) {
        setState(() {
          _gameSession = GameEngine.updateTimer(
            session,
            session.timeRemaining - 1,
          );
        });

        if (_gameSession!.timeRemaining <= 0) {
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

    // Letter selection particle effects disabled for faster response
    // if (mounted) {
    //   final letterPosition = _getLetterPosition(index);
    //   ParticleOverlay.showLetterSelection(context, letterPosition);
    // }
  }

  // Helper method to calculate letter position for effects
  Offset _getLetterPosition(int index) {
    final screenSize = MediaQuery.of(context).size;
    final gridWidth = screenSize.width - 32; // Account for padding
    final difficulty = _gameSession?.settings.difficulty ?? Difficulty.easy;

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
    // Removed delay for faster response

    // Get settings for Learning Mode
    final settingsProvider = context.read<SettingsProvider>();
    final result = await gameProvider.submitWord(gameSettings: settingsProvider.settings);

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

        // Particle effects disabled for faster response
        ParticleOverlay.showWordFound(
          context,
          screenCenter,
          word.text.length,
        );

        // Enhanced word found overlay
        WordFoundOverlay.show(
          context,
          word,
          // combo: result.combo, // Combo display disabled
          position: screenCenter,
        );

        // Combo notifications disabled - keeping combo logic for scoring but not showing UI

        // Time bonus animation disabled for faster response
        TimeBonusOverlay.show(context, word.score);

        // Show Learning Mode definition dialog if enabled
        final settingsProvider = context.read<SettingsProvider>();
        if (settingsProvider.settings.learningModeEnabled &&
            settingsProvider.settings.showDefinitions &&
            word.definition != null) {
          // Show dialog immediately for faster response
          _showWordDefinitionDialog(word);
        }
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

  void _showWordDefinitionDialog(Word word) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WordDefinitionDialog(
        word: word,
        onSaveToMyDictionary: () {
          // Optional: Show feedback that word was saved
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${word.text}" to My Dictionary'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onClose: () {
          // Optional: Handle dialog close
        },
      ),
    );
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
      final session = _gameSession;
      if (session != null) {
        setState(() {
          _gameSession = GameEngine.endGame(session);
        });

        // Navigate to results screen with smooth transition
        Navigator.of(context).pushReplacement(
          SmoothPageRoute(
            child: ResultsScreen(gameSession: _gameSession!),
            transitionType: TransitionType.slideFromBottom,
          ),
        );
      }
    });
  }

  /// Handle power-up effects when used
  void _handlePowerupEffects() {
    final powerupProvider = context.read<PowerupProvider>();
    final gameProvider = context.read<GameProvider>();

    // Check for active power-up effects and apply them
    final activeEffects = powerupProvider.getActiveEffects();

    for (final effect in activeEffects) {
      if (effect.isConsumed) continue;

      switch (effect.type) {
        case PowerUpType.timeFreeze:
          // Pause the game timer for the duration
          _pauseTimerForDuration(effect);
          break;

        case PowerUpType.extraTime:
          // Add 30 seconds to timer
          _addExtraTime(30);
          powerupProvider.consumePowerUpEffect(PowerUpType.extraTime);
          break;

        case PowerUpType.wordHint:
          // Show a hint word
          _showWordHint();
          powerupProvider.consumePowerUpEffect(PowerUpType.wordHint);
          break;

        case PowerUpType.letterShuffle:
          // Shuffle the letters
          _shuffleLetters();
          powerupProvider.consumePowerUpEffect(PowerUpType.letterShuffle);
          break;

        case PowerUpType.doublePoints:
          // Double points effect is handled in scoring logic
          break;

        case PowerUpType.comboBoost:
          // Boost combo multiplier
          _boostCombo();
          powerupProvider.consumePowerUpEffect(PowerUpType.comboBoost);
          break;

        case PowerUpType.clearMistakes:
          // Clear mistakes/penalties
          _clearMistakes();
          powerupProvider.consumePowerUpEffect(PowerUpType.clearMistakes);
          break;

        case PowerUpType.xrayVision:
          // Highlight possible words (visual effect)
          _activateXrayVision(effect);
          break;
      }
    }

    setState(() {
      // Refresh UI after applying effects
    });
  }

  /// Pause timer for duration (Time Freeze power-up)
  void _pauseTimerForDuration(PowerUpEffect effect) {
    final duration = PowerUpConfig.getConfig(effect.type).duration;
    print('⏸️ Time Freeze activated for $duration seconds');

    // Freeze the timer
    _isTimerFrozen = true;

    // Show freeze effect
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.pause, color: Colors.white),
            const SizedBox(width: 8),
            Text('⏸️ Timer frozen for ${duration}s!'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: duration),
      ),
    );

    // Unfreeze after duration
    _freezeTimer?.cancel();
    _freezeTimer = Timer(Duration(seconds: duration), () {
      _isTimerFrozen = false;
      print('⏸️ Time Freeze ended');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏸️ Timer resumed!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  /// Add extra time to the game timer
  void _addExtraTime(int seconds) {
    final gameProvider = context.read<GameProvider>();
    final session = _gameSession;
    if (gameProvider.currentSession != null && session != null) {
      // Add time through GameProvider
      setState(() {
        _gameSession = GameEngine.addTimeBonus(session, seconds);
      });

      print('⏰ Added $seconds seconds to timer');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ +$seconds seconds added!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show word hint
  void _showWordHint() {
    final gameProvider = context.read<GameProvider>();
    final hints = gameProvider.getHintWords(maxHints: 1);

    if (hints.isNotEmpty) {
      final hint = hints.first;
      print('💡 Word hint: $hint');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💡 Hint: Try "$hint"'),
          backgroundColor: Colors.yellow.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💡 No hints available'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Shuffle letters
  void _shuffleLetters() {
    final session = _gameSession;
    if (session == null) return;

    print('🔀 Letters shuffled');

    // Create a new shuffled list of letters
    final shuffledLetters = List<String>.from(session.letters);
    shuffledLetters.shuffle();

    // Update game session with shuffled letters
    setState(() {
      _gameSession = session.copyWith(letters: shuffledLetters);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.shuffle, color: Colors.white),
            SizedBox(width: 8),
            Text('🔀 Letters shuffled for new perspective!'),
          ],
        ),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Boost combo multiplier
  void _boostCombo() {
    final gameProvider = context.read<GameProvider>();
    final comboManager = gameProvider.comboManager;

    if (comboManager != null) {
      // Force start a combo if none exists, or boost existing combo
      if (!comboManager.hasActiveCombo) {
        // Start a combo with a dummy word to activate the system
        comboManager.addWord('BOOST');
        print('📈 Combo system activated with boost!');
      } else {
        // Add an extra word to boost existing combo
        comboManager.addWord('BOOST');
        print('📈 Existing combo boosted! New multiplier: ${comboManager.currentMultiplier}x');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white),
              const SizedBox(width: 8),
              Text('📈 Combo boosted! ${comboManager.currentMultiplier.toStringAsFixed(1)}x multiplier'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📈 Combo system not available'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Clear mistakes/penalties
  void _clearMistakes() {
    final gameProvider = context.read<GameProvider>();
    final comboManager = gameProvider.comboManager;

    print('❌ Mistakes cleared');

    // Reset combo timer to give more time
    if (comboManager != null && comboManager.hasActiveCombo) {
      // Force extend combo time by adding a "clear" word
      comboManager.addWord('CLEAR');
      print('❌ Combo timer reset and extended');
    }

    // Clear current input if there's an invalid attempt
    final session = _gameSession;
    if (session != null && session.currentInput.isNotEmpty) {
      setState(() {
        _gameSession = session.copyWith(
          currentInput: '',
          selectedLetterIndices: [],
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.clear, color: Colors.white),
            SizedBox(width: 8),
            Text('❌ Mistakes cleared! Fresh start!'),
          ],
        ),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Activate X-ray vision
  void _activateXrayVision(PowerUpEffect effect) {
    final gameProvider = context.read<GameProvider>();
    final hints = gameProvider.getHintWords(maxHints: 5);

    print('👁️ X-ray vision activated - showing ${hints.length} possible words');

    if (hints.isNotEmpty) {
      // Show dialog with possible words
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.indigo.shade900,
          title: const Row(
            children: [
              Icon(Icons.visibility, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '👁️ X-Ray Vision',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Possible words you can make:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              ...hints.map((word) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• $word',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('👁️ No more words to discover!'),
          backgroundColor: Colors.indigo,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _pauseGame() {
    final session = _gameSession;
    if (session != null) {
      setState(() {
        _gameSession = GameEngine.pauseGame(session);
      });
    }
  }

  void _resumeGame() {
    final session = _gameSession;
    if (session != null) {
      setState(() {
        _gameSession = GameEngine.resumeGame(session);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if game session is not initialized
    if (_gameSession == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor,
                AppConstants.secondaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Initializing Game...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final gameSession = _gameSession!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor, // Cyan
              AppConstants.secondaryColor, // Dark cyan
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
                  // Top bar with timer, score, and power-ups
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Row(
                      children: [
                        // Timer - flexible to take needed space
                        Flexible(
                          flex: 2,
                          child: TimerWithBonus(
                            timeRemaining: gameSession.timeRemaining,
                            isRunning: gameSession.state == GameState.playing,
                            onTimeUp: _endGame,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Power-ups panel - flexible to take needed space
                        Flexible(
                          flex: 3,
                          child: GamePowerupsPanel(
                            onPowerupUsed: () {
                              _handlePowerupEffects();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Score - flexible to take remaining space
                        Flexible(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SCORE: ${gameSession.totalScore}',
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Consumer<SettingsProvider>(
                              builder: (context, settingsProvider, child) {
                                return LearningModeIndicator(
                                  isEnabled: settingsProvider.settings.learningModeEnabled,
                                  showLabel: false,
                                  size: 16,
                                );
                              },
                            ),
                          ],
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
                  key: ValueKey(gameSession.foundWords.length),
                  initialItemCount: gameSession.foundWords.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= gameSession.foundWords.length) {
                      return const SizedBox.shrink();
                    }
                    final word = gameSession.foundWords[index];
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
