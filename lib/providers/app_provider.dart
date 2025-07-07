import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import 'game_provider.dart';
import 'settings_provider.dart';
import 'high_score_provider.dart';
import 'achievement_provider.dart';

class AppProvider extends ChangeNotifier {
  final GameProvider gameProvider;
  final SettingsProvider settingsProvider;
  final HighScoreProvider highScoreProvider;
  final AchievementProvider achievementProvider;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AppProvider({
    required this.gameProvider,
    required this.settingsProvider,
    required this.highScoreProvider,
    required this.achievementProvider,
  });

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Initialize the app
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      // Initialize storage service first
      await StorageService.init();

      // Initialize sound service
      await SoundService.init();

      // Load settings first
      await settingsProvider.loadSettings();

      // Configure sound and haptic services based on settings
      SoundService.setEnabled(settingsProvider.settings.soundEnabled);
      HapticService.setEnabled(settingsProvider.settings.vibrationEnabled);

      // Load high scores
      await highScoreProvider.loadHighScores();

      // Initialize achievements
      await achievementProvider.initializeAchievements();

      // Check if this is first launch
      final isFirstLaunch = await settingsProvider.isFirstLaunch();
      if (isFirstLaunch) {
        await _handleFirstLaunch();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize app: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle first launch setup
  Future<void> _handleFirstLaunch() async {
    try {
      // Show welcome or tutorial if needed
      await settingsProvider.markFirstLaunchComplete();
    } catch (e) {
      _setError('Failed to handle first launch: $e');
    }
  }

  /// Start a new game with current settings
  Future<void> startNewGame() async {
    try {
      // Play game start sound
      await SoundService.playGameStart();
      await HapticService.gameEvent();

      await gameProvider.startNewGame(settingsProvider.settings);
    } catch (e) {
      _setError('Failed to start new game: $e');
    }
  }

  /// End current game and save high score if applicable
  Future<bool> endGameAndSaveScore() async {
    try {
      final session = gameProvider.currentSession;
      if (session == null) return false;

      // End the game
      gameProvider.endGame();

      // Play game end sound
      await SoundService.playGameEnd();
      await HapticService.gameEvent();

      // Update game statistics
      await StorageService.updateGameStats(session);

      // Save last played date
      await StorageService.saveLastPlayedDate();

      // Check if it's a high score
      final isHighScore = await highScoreProvider.addHighScore(session);

      if (isHighScore) {
        await SoundService.playAchievement();
        await HapticService.gameEvent();
      }

      // Clear saved game session
      await StorageService.clearGameSession();

      return isHighScore;
    } catch (e) {
      _setError('Failed to end game and save score: $e');
      return false;
    }
  }

  /// Play sound effect if enabled
  void playSound(String soundName) {
    if (settingsProvider.soundEnabled) {
      // TODO: Implement sound playing
      // AudioPlayer.play(soundName);
    }
  }

  /// Trigger vibration if enabled
  void vibrate() {
    if (settingsProvider.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Trigger medium vibration if enabled
  void vibrateMedium() {
    if (settingsProvider.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Trigger heavy vibration if enabled
  void vibrateHeavy() {
    if (settingsProvider.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Get current game statistics
  Map<String, dynamic> getCurrentGameStats() {
    final session = gameProvider.currentSession;
    if (session == null) {
      return {
        'score': 0,
        'wordsFound': 0,
        'timeRemaining': 0,
        'longestWord': '',
        'isActive': false,
      };
    }

    return {
      'score': session.totalScore,
      'wordsFound': session.foundWords.length,
      'timeRemaining': session.timeRemaining,
      'longestWord': session.longestWord?.text ?? '',
      'isActive': session.isActive,
    };
  }

  /// Check if current score would be a high score
  bool wouldBeHighScore() {
    final session = gameProvider.currentSession;
    if (session == null) return false;
    
    return highScoreProvider.wouldBeHighScore(session.totalScore);
  }

  /// Get player's best score for current difficulty
  HighScore? getPlayerBestScore() {
    return highScoreProvider.getPlayerBestScore(
      settingsProvider.playerName,
    );
  }

  /// Reset all app data
  Future<void> resetAllData() async {
    try {
      _setLoading(true);
      
      // Reset game
      gameProvider.resetGame();
      
      // Reset settings to defaults
      await settingsProvider.resetToDefaults();
      
      // Clear high scores
      await highScoreProvider.clearHighScores();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset app data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Handle app lifecycle changes
  void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // Pause game if active
        if (gameProvider.isGameActive) {
          gameProvider.pauseGame();
        }
        break;
      case AppLifecycleState.resumed:
        // Game will be resumed manually by user
        break;
      case AppLifecycleState.detached:
        // Save any pending data
        break;
      default:
        break;
    }
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }
}
