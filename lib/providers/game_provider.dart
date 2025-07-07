import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/models.dart';
import '../models/combo_system.dart';
import '../services/services.dart';

class GameProvider extends ChangeNotifier {
  GameSession? _currentSession;
  Timer? _gameTimer;
  bool _isLoading = false;
  String? _errorMessage;
  ComboManager? _comboManager;

  // Getters
  GameSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGameActive => _currentSession?.isActive ?? false;
  bool get isGameFinished => _currentSession?.isFinished ?? false;
  int get timeRemaining => _currentSession?.timeRemaining ?? 0;
  int get totalScore => _currentSession?.totalScore ?? 0;
  List<Word> get foundWords => _currentSession?.foundWords ?? [];
  String get currentInput => _currentSession?.currentInput ?? '';
  List<int> get selectedIndices => _currentSession?.selectedLetterIndices ?? [];
  List<String> get letters => _currentSession?.letters ?? [];
  ComboStreak? get currentCombo => _comboManager?.currentCombo;
  double get comboMultiplier => _comboManager?.currentMultiplier ?? 1.0;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Start a new game with given settings
  Future<void> startNewGame(GameSettings settings) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Stop any existing timer
      _gameTimer?.cancel();

      // Initialize combo manager
      _comboManager?.dispose();
      _comboManager = ComboManager(
        onComboStarted: (combo) => notifyListeners(),
        onComboExtended: (combo) => notifyListeners(),
        onComboLevelUp: (combo) => notifyListeners(),
        onComboEnded: (combo) => notifyListeners(),
      );

      // Create new game session
      _currentSession = GameEngine.createNewGame(settings);
      _currentSession = GameEngine.startGame(_currentSession!);

      // Start game timer
      _startGameTimer();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to start game: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Start the game timer
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null && _currentSession!.state == GameState.playing) {
        _currentSession = GameEngine.updateTimer(
          _currentSession!,
          _currentSession!.timeRemaining - 1,
        );
        
        notifyListeners();
        
        // End game when time runs out
        if (_currentSession!.timeRemaining <= 0) {
          endGame();
        }
      }
    });
  }

  /// Select a letter at the given index
  void selectLetter(int index) {
    if (_currentSession == null || !_currentSession!.isActive) return;
    
    try {
      _currentSession = GameEngine.selectLetter(_currentSession!, index);
      notifyListeners();
    } catch (e) {
      _setError('Failed to select letter: $e');
    }
  }

  /// Deselect the last selected letter
  void deselectLastLetter() {
    if (_currentSession == null || !_currentSession!.isActive) return;
    
    try {
      _currentSession = GameEngine.deselectLastLetter(_currentSession!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to deselect letter: $e');
    }
  }

  /// Clear all selected letters
  void clearSelection() {
    if (_currentSession == null || !_currentSession!.isActive) return;
    
    try {
      _currentSession = GameEngine.clearSelection(_currentSession!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear selection: $e');
    }
  }

  /// Submit the current word
  Future<GameSubmissionResult> submitWord() async {
    if (_currentSession == null || !_currentSession!.isActive) {
      return GameSubmissionResult(
        success: false,
        message: 'No active game session',
        updatedSession: _currentSession!,
      );
    }

    try {
      final result = await GameEngine.submitWord(_currentSession!, comboManager: _comboManager);
      _currentSession = result.updatedSession;
      notifyListeners();
      return result;
    } catch (e) {
      _setError('Failed to submit word: $e');
      return GameSubmissionResult(
        success: false,
        message: 'Error submitting word: $e',
        updatedSession: _currentSession!,
      );
    }
  }

  /// Pause the current game
  void pauseGame() {
    if (_currentSession == null || _currentSession!.state != GameState.playing) return;
    
    try {
      _gameTimer?.cancel();
      _currentSession = GameEngine.pauseGame(_currentSession!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to pause game: $e');
    }
  }

  /// Resume the paused game
  void resumeGame() {
    if (_currentSession == null || _currentSession!.state != GameState.paused) return;
    
    try {
      _currentSession = GameEngine.resumeGame(_currentSession!);
      _startGameTimer();
      notifyListeners();
    } catch (e) {
      _setError('Failed to resume game: $e');
    }
  }

  /// End the current game
  void endGame() {
    try {
      _gameTimer?.cancel();
      if (_currentSession != null) {
        _currentSession = GameEngine.endGame(_currentSession!);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to end game: $e');
    }
  }

  /// Reset the game state
  void resetGame() {
    _gameTimer?.cancel();
    _currentSession = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get hint words for the current letters
  List<String> getHintWords({int maxHints = 3}) {
    if (_currentSession == null) return [];
    
    try {
      return WordValidator.getHintWords(
        _currentSession!.letters,
        _currentSession!.foundWords.map((w) => w.text).toList(),
        maxHints: maxHints,
      );
    } catch (e) {
      _setError('Failed to get hints: $e');
      return [];
    }
  }

  /// Check if a word can be formed with current letters
  bool canFormWord(String word) {
    if (_currentSession == null) return false;
    
    try {
      return WordValidator.canFormWord(word, _currentSession!.letters);
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _comboManager?.dispose();
    super.dispose();
  }
}
