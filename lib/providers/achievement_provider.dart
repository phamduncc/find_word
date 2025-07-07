import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider for managing achievements and progress tracking
class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  List<Achievement> _newlyUnlocked = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Statistics for tracking progress
  int _totalWordsFound = 0;
  int _longestWordLength = 0;
  double _fastestWordTime = double.infinity;
  int _perfectGames = 0;

  // Getters
  List<Achievement> get achievements => _achievements;
  List<Achievement> get newlyUnlocked => _newlyUnlocked;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalWordsFound => _totalWordsFound;
  int get longestWordLength => _longestWordLength;
  double get fastestWordTime => _fastestWordTime;
  int get perfectGames => _perfectGames;

  // Achievement specific getters
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();

  int get totalAchievementPoints => 
      unlockedAchievements.fold(0, (sum, a) => sum + a.type.points);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Initialize achievements from storage
  Future<void> initializeAchievements() async {
    try {
      _setLoading(true);
      _setError(null);

      // Load achievements from storage
      final savedAchievements = await StorageService.loadAchievements();
      
      if (savedAchievements.isEmpty) {
        // First time - create default achievements
        _achievements = AchievementFactory.createDefaultAchievements();
        await _saveAchievements();
      } else {
        _achievements = savedAchievements;
      }

      // Load statistics
      await _loadStatistics();

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize achievements: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load player statistics from storage
  Future<void> _loadStatistics() async {
    try {
      final stats = await StorageService.loadPlayerStatistics();
      _totalWordsFound = stats['totalWordsFound'] ?? 0;
      _longestWordLength = stats['longestWordLength'] ?? 0;
      _fastestWordTime = stats['fastestWordTime'] ?? double.infinity;
      _perfectGames = stats['perfectGames'] ?? 0;
    } catch (e) {
      // Use defaults if loading fails
      _totalWordsFound = 0;
      _longestWordLength = 0;
      _fastestWordTime = double.infinity;
      _perfectGames = 0;
    }
  }

  /// Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      await StorageService.saveAchievements(_achievements);
    } catch (e) {
      _setError('Failed to save achievements: $e');
    }
  }

  /// Save player statistics to storage
  Future<void> _saveStatistics() async {
    try {
      final stats = {
        'totalWordsFound': _totalWordsFound,
        'longestWordLength': _longestWordLength,
        'fastestWordTime': _fastestWordTime,
        'perfectGames': _perfectGames,
      };
      await StorageService.savePlayerStatistics(stats);
    } catch (e) {
      _setError('Failed to save statistics: $e');
    }
  }

  /// Track when a word is found and check for achievements
  Future<void> trackWordFound(Word word, double timeToFind) async {
    try {
      // Update statistics
      _totalWordsFound++;
      
      if (word.text.length > _longestWordLength) {
        _longestWordLength = word.text.length;
      }
      
      if (timeToFind < _fastestWordTime) {
        _fastestWordTime = timeToFind;
      }

      // Check achievements
      await _checkAchievements(word, timeToFind);
      
      // Save updated data
      await _saveStatistics();
      await _saveAchievements();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to track word: $e');
    }
  }

  /// Track when a game is completed
  Future<void> trackGameCompleted(GameSession session) async {
    try {
      // Check for perfect game (no wrong attempts - this would need to be tracked in GameSession)
      // For now, we'll assume perfect if player found words efficiently
      if (session.foundWords.length >= 5) {
        _perfectGames++;
      }

      // Check time challenger achievement (10 words in single game)
      if (session.foundWords.length >= 10) {
        await _unlockAchievement(AchievementType.timeChallenger);
      }

      await _saveStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to track game completion: $e');
    }
  }

  /// Check and unlock achievements based on current progress
  Future<void> _checkAchievements(Word word, double timeToFind) async {
    _newlyUnlocked.clear();

    // First Word achievement
    if (_totalWordsFound == 1) {
      await _unlockAchievement(AchievementType.firstWord);
    }

    // Word Master achievement (100 words)
    if (_totalWordsFound >= 100) {
      await _unlockAchievement(AchievementType.wordMaster);
    }

    // Speed Demon achievement (word found in < 5 seconds)
    if (timeToFind < 5.0) {
      await _unlockAchievement(AchievementType.speedDemon);
    }

    // Dictionary achievement (8+ letter word)
    if (word.text.length >= 8) {
      await _unlockAchievement(AchievementType.dictionary);
    }

    // Update progress for all achievements
    await _updateAchievementProgress();
  }

  /// Unlock a specific achievement
  Future<void> _unlockAchievement(AchievementType type) async {
    final index = _achievements.indexWhere((a) => a.type == type);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        progress: _achievements[index].target,
      );
      _newlyUnlocked.add(_achievements[index]);
    }
  }

  /// Update progress for all achievements
  Future<void> _updateAchievementProgress() async {
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      int newProgress = 0;
      switch (achievement.type) {
        case AchievementType.wordMaster:
          newProgress = _totalWordsFound;
          break;
        case AchievementType.speedDemon:
          newProgress = _fastestWordTime < 5.0 ? 1 : 0;
          break;
        case AchievementType.dictionary:
          newProgress = _longestWordLength >= 8 ? 1 : 0;
          break;
        case AchievementType.firstWord:
          newProgress = _totalWordsFound > 0 ? 1 : 0;
          break;
        case AchievementType.perfectGame:
          newProgress = _perfectGames;
          break;
        case AchievementType.timeChallenger:
          // This is handled in trackGameCompleted
          break;
      }

      if (newProgress != achievement.progress) {
        _achievements[i] = achievement.copyWith(progress: newProgress);
      }
    }
  }

  /// Clear newly unlocked achievements (call after showing notification)
  void clearNewlyUnlocked() {
    _newlyUnlocked.clear();
    notifyListeners();
  }

  /// Reset all achievements (for testing or new player)
  Future<void> resetAchievements() async {
    try {
      _achievements = AchievementFactory.createDefaultAchievements();
      _newlyUnlocked.clear();
      _totalWordsFound = 0;
      _longestWordLength = 0;
      _fastestWordTime = double.infinity;
      _perfectGames = 0;

      await _saveAchievements();
      await _saveStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset achievements: $e');
    }
  }

  /// Get achievement by type
  Achievement? getAchievement(AchievementType type) {
    try {
      return _achievements.firstWhere((a) => a.type == type);
    } catch (e) {
      return null;
    }
  }
}
