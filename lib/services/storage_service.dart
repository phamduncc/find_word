import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }

  // ==================== GENERIC DATA METHODS ====================

  /// Save generic data as JSON
  static Future<bool> saveData(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = json.encode(data);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get generic data from JSON
  static Future<Map<String, dynamic>?> getData(String key) async {
    try {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== SETTINGS ====================

  /// Save game settings
  static Future<bool> saveSettings(GameSettings settings) async {
    try {
      final settingsJson = json.encode(settings.toJson());
      return await prefs.setString(AppConstants.keyGameSettings, settingsJson);
    } catch (e) {
      return false;
    }
  }

  /// Load game settings
  static GameSettings loadSettings() {
    try {
      final settingsJson = prefs.getString(AppConstants.keyGameSettings);
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        return GameSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // Return default settings if loading fails
    }
    return const GameSettings();
  }

  /// Save individual setting values
  static Future<bool> saveDifficulty(Difficulty difficulty) async {
    return await prefs.setInt('difficulty', difficulty.index);
  }

  static Future<bool> saveSoundEnabled(bool enabled) async {
    return await prefs.setBool(AppConstants.keySoundEnabled, enabled);
  }

  static Future<bool> saveVibrationEnabled(bool enabled) async {
    return await prefs.setBool(AppConstants.keyVibrationEnabled, enabled);
  }

  static Future<bool> saveShowHints(bool enabled) async {
    return await prefs.setBool('show_hints', enabled);
  }

  static Future<bool> savePlayerName(String name) async {
    return await prefs.setString(AppConstants.keyPlayerName, name);
  }

  // ==================== HIGH SCORES ====================

  /// Save high scores list
  static Future<bool> saveHighScores(List<HighScore> scores) async {
    try {
      final scoresJson = json.encode(
        scores.map((score) => score.toJson()).toList(),
      );
      return await prefs.setString(AppConstants.keyHighScores, scoresJson);
    } catch (e) {
      return false;
    }
  }

  /// Load high scores list
  static List<HighScore> loadHighScores() {
    try {
      final scoresJson = prefs.getString(AppConstants.keyHighScores);
      if (scoresJson != null) {
        final scoresList = json.decode(scoresJson) as List;
        return scoresList
            .map((json) => HighScore.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Return empty list if loading fails
    }
    return [];
  }

  /// Add a single high score
  static Future<bool> addHighScore(HighScore score) async {
    try {
      final scores = loadHighScores();
      scores.add(score);
      
      // Sort by score descending
      scores.sort((a, b) => b.score.compareTo(a.score));
      
      // Keep only top scores
      if (scores.length > AppConstants.maxHighScores) {
        scores.removeRange(AppConstants.maxHighScores, scores.length);
      }
      
      return await saveHighScores(scores);
    } catch (e) {
      return false;
    }
  }

  /// Clear all high scores
  static Future<bool> clearHighScores() async {
    return await prefs.remove(AppConstants.keyHighScores);
  }

  // ==================== GAME PROGRESS ====================

  /// Save current game session
  static Future<bool> saveGameSession(GameSession session) async {
    try {
      final sessionJson = json.encode(session.toJson());
      return await prefs.setString('current_game_session', sessionJson);
    } catch (e) {
      return false;
    }
  }

  /// Load saved game session
  static GameSession? loadGameSession() {
    try {
      final sessionJson = prefs.getString('current_game_session');
      if (sessionJson != null) {
        final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
        return GameSession.fromJson(sessionMap);
      }
    } catch (e) {
      // Return null if loading fails
    }
    return null;
  }

  /// Clear saved game session
  static Future<bool> clearGameSession() async {
    return await prefs.remove('current_game_session');
  }

  // ==================== APP STATE ====================

  /// Check if this is first launch
  static bool isFirstLaunch() {
    return !prefs.containsKey(AppConstants.keyFirstLaunch);
  }

  /// Mark first launch as complete
  static Future<bool> markFirstLaunchComplete() async {
    return await prefs.setBool(AppConstants.keyFirstLaunch, false);
  }

  /// Save last played date
  static Future<bool> saveLastPlayedDate() async {
    return await prefs.setString('last_played_date', DateTime.now().toIso8601String());
  }

  /// Get last played date
  static DateTime? getLastPlayedDate() {
    try {
      final dateString = prefs.getString('last_played_date');
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  // ==================== STATISTICS ====================

  /// Save game statistics
  static Future<bool> saveGameStats(Map<String, dynamic> stats) async {
    try {
      final statsJson = json.encode(stats);
      return await prefs.setString('game_statistics', statsJson);
    } catch (e) {
      return false;
    }
  }

  /// Load game statistics
  static Map<String, dynamic> loadGameStats() {
    try {
      final statsJson = prefs.getString('game_statistics');
      if (statsJson != null) {
        return json.decode(statsJson) as Map<String, dynamic>;
      }
    } catch (e) {
      // Return empty stats if loading fails
    }
    return {
      'totalGamesPlayed': 0,
      'totalWordsFound': 0,
      'totalScore': 0,
      'averageScore': 0.0,
      'bestScore': 0,
      'longestWord': '',
      'favoriteWordLength': 3,
    };
  }

  /// Update game statistics
  static Future<bool> updateGameStats(GameSession session) async {
    try {
      final stats = loadGameStats();
      
      // Update statistics
      stats['totalGamesPlayed'] = (stats['totalGamesPlayed'] ?? 0) + 1;
      stats['totalWordsFound'] = (stats['totalWordsFound'] ?? 0) + session.foundWords.length;
      stats['totalScore'] = (stats['totalScore'] ?? 0) + session.totalScore;
      stats['averageScore'] = stats['totalScore'] / stats['totalGamesPlayed'];
      
      if (session.totalScore > (stats['bestScore'] ?? 0)) {
        stats['bestScore'] = session.totalScore;
      }
      
      final longestWord = session.longestWord?.text ?? '';
      if (longestWord.length > (stats['longestWord'] ?? '').length) {
        stats['longestWord'] = longestWord;
      }
      
      return await saveGameStats(stats);
    } catch (e) {
      return false;
    }
  }

  // ==================== ACHIEVEMENTS ====================

  /// Save achievements list
  static Future<bool> saveAchievements(List<Achievement> achievements) async {
    try {
      final achievementsJson = json.encode(
        achievements.map((achievement) => achievement.toJson()).toList(),
      );
      return await prefs.setString('achievements', achievementsJson);
    } catch (e) {
      return false;
    }
  }

  /// Load achievements list
  static Future<List<Achievement>> loadAchievements() async {
    try {
      final achievementsJson = prefs.getString('achievements');
      if (achievementsJson != null) {
        final achievementsList = json.decode(achievementsJson) as List;
        return achievementsList
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Return empty list if loading fails
    }
    return [];
  }

  /// Save player statistics for achievements
  static Future<bool> savePlayerStatistics(Map<String, dynamic> stats) async {
    try {
      final statsJson = json.encode(stats);
      return await prefs.setString('player_statistics', statsJson);
    } catch (e) {
      return false;
    }
  }

  /// Load player statistics for achievements
  static Future<Map<String, dynamic>> loadPlayerStatistics() async {
    try {
      final statsJson = prefs.getString('player_statistics');
      if (statsJson != null) {
        return json.decode(statsJson) as Map<String, dynamic>;
      }
    } catch (e) {
      // Return empty stats if loading fails
    }
    return {
      'totalWordsFound': 0,
      'longestWordLength': 0,
      'fastestWordTime': double.infinity,
      'perfectGames': 0,
    };
  }

  // ==================== UTILITY ====================

  /// Clear all app data
  static Future<bool> clearAllData() async {
    try {
      await prefs.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all stored keys (for debugging)
  static Set<String> getAllKeys() {
    return prefs.getKeys();
  }

  /// Check if a key exists
  static bool hasKey(String key) {
    return prefs.containsKey(key);
  }
}
