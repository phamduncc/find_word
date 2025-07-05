import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class HighScoreProvider extends ChangeNotifier {
  List<HighScore> _highScores = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<HighScore> get highScores => List.unmodifiable(_highScores);
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

  /// Load high scores from SharedPreferences
  Future<void> loadHighScores() async {
    try {
      _setLoading(true);
      _setError(null);

      _highScores = StorageService.loadHighScores();
      // Remove any duplicates that might exist
      _highScores = HighScoreManager.removeDuplicates(_highScores);
      // Sort by score descending
      _highScores.sort((a, b) => b.score.compareTo(a.score));

      notifyListeners();
    } catch (e) {
      _setError('Failed to load high scores: $e');
      _highScores = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Save high scores to SharedPreferences
  Future<void> _saveHighScores() async {
    try {
      await StorageService.saveHighScores(_highScores);
    } catch (e) {
      _setError('Failed to save high scores: $e');
    }
  }

  /// Add a new high score
  Future<bool> addHighScore(GameSession gameSession) async {
    try {
      final newScore = HighScore(
        playerName: gameSession.settings.playerName,
        score: gameSession.totalScore,
        wordsFound: gameSession.foundWords.length,
        difficulty: gameSession.settings.difficulty,
        longestWord: gameSession.longestWord?.text ?? '',
        achievedAt: DateTime.now(),
        gameDuration: gameSession.duration,
      );

      // Use HighScoreManager to properly handle adding scores per difficulty
      _highScores = HighScoreManager.addHighScore(_highScores, newScore);

      // Check if this was actually added (qualifies as high score)
      final difficultyScores = HighScoreManager.getTopScores(_highScores, newScore.difficulty);
      final isHighScore = difficultyScores.any((score) =>
        score.playerName == newScore.playerName &&
        score.score == newScore.score &&
        score.achievedAt == newScore.achievedAt
      );

      if (isHighScore) {
        await _saveHighScores();
        notifyListeners();
      }

      return isHighScore;
    } catch (e) {
      _setError('Failed to add high score: $e');
      return false;
    }
  }

  /// Check if a score qualifies as a high score
  bool _isQualifyingScore(HighScore newScore) {
    if (_highScores.length < AppConstants.maxHighScores) {
      return true;
    }
    
    final lowestScore = _highScores.last.score;
    return newScore.score > lowestScore;
  }

  /// Get high scores for a specific difficulty
  List<HighScore> getHighScoresForDifficulty(Difficulty difficulty) {
    return _highScores
        .where((score) => score.difficulty == difficulty)
        .toList();
  }

  /// Get top score for a specific difficulty
  HighScore? getTopScoreForDifficulty(Difficulty difficulty) {
    final scores = getHighScoresForDifficulty(difficulty);
    return scores.isNotEmpty ? scores.first : null;
  }

  /// Get player's best score
  HighScore? getPlayerBestScore(String playerName) {
    final playerScores = _highScores
        .where((score) => score.playerName.toLowerCase() == playerName.toLowerCase())
        .toList();
    
    return playerScores.isNotEmpty ? playerScores.first : null;
  }

  /// Get player's scores
  List<HighScore> getPlayerScores(String playerName) {
    return _highScores
        .where((score) => score.playerName.toLowerCase() == playerName.toLowerCase())
        .toList();
  }

  /// Clear all high scores
  Future<void> clearHighScores() async {
    try {
      _highScores.clear();
      await _saveHighScores();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear high scores: $e');
    }
  }

  /// Check if a score would be a new high score
  bool wouldBeHighScore(int score) {
    if (_highScores.length < AppConstants.maxHighScores) {
      return true;
    }

    final lowestScore = _highScores.last.score;
    return score > lowestScore;
  }
}
