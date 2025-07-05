import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/services.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startGameTimer();
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
    _gameSession = GameEngine.createNewGame(settings);
    _gameSession = GameEngine.startGame(_gameSession);
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

  void _onLetterTap(int index) {
    setState(() {
      _gameSession = GameEngine.selectLetter(_gameSession, index);
    });
  }

  void _onSubmitWord() async {
    if (_isSubmitting || _gameSession.currentInput.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    final result = GameEngine.submitWord(_gameSession);

    // Debug print
    print('=== SUBMIT DEBUG ===');
    print('Word: "${_gameSession.currentInput}"');
    print('Available letters: ${_gameSession.letters}');
    print('Selected indices: ${_gameSession.selectedLetterIndices}');
    print('Result success: ${result.success}');
    print('Result message: ${result.message}');
    print('==================');

    setState(() {
      _gameSession = result.updatedSession;
      _isSubmitting = false;
    });

    // Show feedback
    if (result.success) {
      _showSuccessMessage(result.message);
    } else {
      _showErrorMessage(result.message);
    }
  }

  void _onClearSelection() {
    setState(() {
      _gameSession = GameEngine.clearSelection(_gameSession);
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

      // Navigate to results screen
      Navigator.pushReplacementNamed(
        context,
        '/results',
        arguments: _gameSession,
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
              // Top bar with timer and score
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GameTimer(
                      timeRemaining: _gameSession.timeRemaining,
                      isRunning: _gameSession.state == GameState.playing,
                      onTimeUp: _endGame,
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
                      child: LetterGrid(
                        letters: _gameSession.letters,
                        selectedIndices: _gameSession.selectedLetterIndices,
                        onLetterTap: _onLetterTap,
                        columns: _getOptimalColumns(_gameSession.letters.length),
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
                      child: Text(
                        _gameSession.currentInput.isEmpty 
                            ? '_ _ _ _' 
                            : _gameSession.currentInput,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
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
                      child: SubmitButton(
                        onPressed: _gameSession.currentInput.isNotEmpty ? _onSubmitWord : null,
                        isEnabled: _gameSession.currentInput.isNotEmpty && !_isSubmitting,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: ClearButton(
                        onPressed: _gameSession.selectedLetterIndices.isNotEmpty ? _onClearSelection : null,
                        isEnabled: _gameSession.selectedLetterIndices.isNotEmpty,
                      ),
                    ),
                  ],
                ),
              ),

              // Found words list
              Expanded(
                flex: 1,
                child: FoundWordsList(
                  words: _gameSession.foundWords,
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
