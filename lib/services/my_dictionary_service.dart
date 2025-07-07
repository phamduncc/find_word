import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learned_word.dart';

/// Service for managing user's learned vocabulary (My Dictionary)
class MyDictionaryService {
  static const String _learnedWordsKey = 'learned_words';
  static const String _learningModeEnabledKey = 'learning_mode_enabled';
  static const String _autoSaveWordsKey = 'auto_save_words';
  static const String _showDefinitionsKey = 'show_definitions';
  static const String _enablePronunciationKey = 'enable_pronunciation';

  static SharedPreferences? _prefs;
  static List<LearnedWord> _learnedWords = [];
  static bool _isInitialized = false;

  /// Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadLearnedWords();
    _isInitialized = true;
  }

  /// Load learned words from storage
  static Future<void> _loadLearnedWords() async {
    try {
      final wordsJson = _prefs?.getStringList(_learnedWordsKey) ?? [];
      _learnedWords = wordsJson
          .map((json) => LearnedWord.fromJson(jsonDecode(json)))
          .toList();
      
      // Sort by most recently learned
      _learnedWords.sort((a, b) => b.learnedAt.compareTo(a.learnedAt));
      
      print('Loaded ${_learnedWords.length} learned words');
    } catch (e) {
      print('Error loading learned words: $e');
      _learnedWords = [];
    }
  }

  /// Save learned words to storage
  static Future<void> _saveLearnedWords() async {
    try {
      final wordsJson = _learnedWords
          .map((word) => jsonEncode(word.toJson()))
          .toList();
      
      await _prefs?.setStringList(_learnedWordsKey, wordsJson);
      print('Saved ${_learnedWords.length} learned words');
    } catch (e) {
      print('Error saving learned words: $e');
    }
  }

  /// Add a new learned word
  static Future<void> addLearnedWord(LearnedWord word) async {
    await initialize();

    // Check if word already exists
    final existingIndex = _learnedWords.indexWhere((w) => w.word == word.word);
    
    if (existingIndex != -1) {
      // Update existing word stats
      _learnedWords[existingIndex] = _learnedWords[existingIndex].updateStats(
        newTimeToFind: word.averageTimeToFind,
        wasCorrect: true,
      );
    } else {
      // Add new word
      _learnedWords.insert(0, word); // Add to beginning for recent first
    }

    await _saveLearnedWords();
  }

  /// Update word statistics
  static Future<void> updateWordStats(String word, {
    required double timeToFind,
    required bool wasCorrect,
  }) async {
    await initialize();

    final index = _learnedWords.indexWhere((w) => w.word == word);
    if (index != -1) {
      _learnedWords[index] = _learnedWords[index].updateStats(
        newTimeToFind: timeToFind,
        wasCorrect: wasCorrect,
      );
      await _saveLearnedWords();
    }
  }

  /// Toggle favorite status of a word
  static Future<void> toggleFavorite(String word) async {
    await initialize();

    final index = _learnedWords.indexWhere((w) => w.word == word);
    if (index != -1) {
      _learnedWords[index] = _learnedWords[index].copyWith(
        isFavorite: !_learnedWords[index].isFavorite,
      );
      await _saveLearnedWords();
    }
  }

  /// Add tag to a word
  static Future<void> addTag(String word, String tag) async {
    await initialize();

    final index = _learnedWords.indexWhere((w) => w.word == word);
    if (index != -1) {
      final currentTags = List<String>.from(_learnedWords[index].tags);
      if (!currentTags.contains(tag)) {
        currentTags.add(tag);
        _learnedWords[index] = _learnedWords[index].copyWith(tags: currentTags);
        await _saveLearnedWords();
      }
    }
  }

  /// Remove tag from a word
  static Future<void> removeTag(String word, String tag) async {
    await initialize();

    final index = _learnedWords.indexWhere((w) => w.word == word);
    if (index != -1) {
      final currentTags = List<String>.from(_learnedWords[index].tags);
      currentTags.remove(tag);
      _learnedWords[index] = _learnedWords[index].copyWith(tags: currentTags);
      await _saveLearnedWords();
    }
  }

  /// Remove a learned word
  static Future<void> removeLearnedWord(String word) async {
    await initialize();

    _learnedWords.removeWhere((w) => w.word == word);
    await _saveLearnedWords();
  }

  /// Get all learned words
  static Future<List<LearnedWord>> getAllLearnedWords() async {
    await initialize();
    return List.from(_learnedWords);
  }

  /// Get learned words with filters
  static Future<List<LearnedWord>> getFilteredWords({
    String? searchQuery,
    String? partOfSpeech,
    String? difficultyLevel,
    String? masteryLevel,
    bool? isFavorite,
    String? tag,
    bool? needsReview,
  }) async {
    await initialize();

    var filtered = List<LearnedWord>.from(_learnedWords);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((word) =>
          word.word.toLowerCase().contains(query) ||
          word.definition.toLowerCase().contains(query)).toList();
    }

    if (partOfSpeech != null) {
      filtered = filtered.where((word) => word.partOfSpeech == partOfSpeech).toList();
    }

    if (difficultyLevel != null) {
      filtered = filtered.where((word) => word.difficultyLevel == difficultyLevel).toList();
    }

    if (masteryLevel != null) {
      filtered = filtered.where((word) => word.masteryLevel == masteryLevel).toList();
    }

    if (isFavorite != null) {
      filtered = filtered.where((word) => word.isFavorite == isFavorite).toList();
    }

    if (tag != null) {
      filtered = filtered.where((word) => word.tags.contains(tag)).toList();
    }

    if (needsReview != null) {
      filtered = filtered.where((word) => word.needsReview == needsReview).toList();
    }

    return filtered;
  }

  /// Get word by text
  static Future<LearnedWord?> getLearnedWord(String word) async {
    await initialize();
    
    try {
      return _learnedWords.firstWhere((w) => w.word == word);
    } catch (e) {
      return null;
    }
  }

  /// Check if word is learned
  static Future<bool> isWordLearned(String word) async {
    await initialize();
    return _learnedWords.any((w) => w.word == word);
  }

  /// Get learning statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    await initialize();

    final totalWords = _learnedWords.length;
    final favoriteWords = _learnedWords.where((w) => w.isFavorite).length;
    final wordsNeedingReview = _learnedWords.where((w) => w.needsReview).length;
    
    final masteryLevels = <String, int>{};
    final difficultyLevels = <String, int>{};
    final partsOfSpeech = <String, int>{};
    
    double totalAccuracy = 0;
    double totalAverageTime = 0;
    
    for (final word in _learnedWords) {
      // Mastery levels
      masteryLevels[word.masteryLevel] = (masteryLevels[word.masteryLevel] ?? 0) + 1;
      
      // Difficulty levels
      difficultyLevels[word.difficultyLevel] = (difficultyLevels[word.difficultyLevel] ?? 0) + 1;
      
      // Parts of speech
      if (word.partOfSpeech.isNotEmpty) {
        partsOfSpeech[word.partOfSpeech] = (partsOfSpeech[word.partOfSpeech] ?? 0) + 1;
      }
      
      totalAccuracy += word.accuracy;
      totalAverageTime += word.averageTimeToFind;
    }

    return {
      'totalWords': totalWords,
      'favoriteWords': favoriteWords,
      'wordsNeedingReview': wordsNeedingReview,
      'averageAccuracy': totalWords > 0 ? totalAccuracy / totalWords : 0.0,
      'averageTimeToFind': totalWords > 0 ? totalAverageTime / totalWords : 0.0,
      'masteryLevels': masteryLevels,
      'difficultyLevels': difficultyLevels,
      'partsOfSpeech': partsOfSpeech,
    };
  }

  /// Get all unique tags
  static Future<List<String>> getAllTags() async {
    await initialize();
    
    final allTags = <String>{};
    for (final word in _learnedWords) {
      allTags.addAll(word.tags);
    }
    
    return allTags.toList()..sort();
  }

  /// Learning Mode Settings
  static Future<bool> isLearningModeEnabled() async {
    await initialize();
    return _prefs?.getBool(_learningModeEnabledKey) ?? false;
  }

  static Future<void> setLearningModeEnabled(bool enabled) async {
    await initialize();
    await _prefs?.setBool(_learningModeEnabledKey, enabled);
  }

  static Future<bool> isAutoSaveWordsEnabled() async {
    await initialize();
    return _prefs?.getBool(_autoSaveWordsKey) ?? true;
  }

  static Future<void> setAutoSaveWordsEnabled(bool enabled) async {
    await initialize();
    await _prefs?.setBool(_autoSaveWordsKey, enabled);
  }

  static Future<bool> isShowDefinitionsEnabled() async {
    await initialize();
    return _prefs?.getBool(_showDefinitionsKey) ?? true;
  }

  static Future<void> setShowDefinitionsEnabled(bool enabled) async {
    await initialize();
    await _prefs?.setBool(_showDefinitionsKey, enabled);
  }

  static Future<bool> isPronunciationEnabled() async {
    await initialize();
    return _prefs?.getBool(_enablePronunciationKey) ?? true;
  }

  static Future<void> setPronunciationEnabled(bool enabled) async {
    await initialize();
    await _prefs?.setBool(_enablePronunciationKey, enabled);
  }

  /// Clear all learned words
  static Future<void> clearAllWords() async {
    await initialize();
    _learnedWords.clear();
    await _saveLearnedWords();
  }

  /// Export learned words as JSON
  static Future<String> exportWords() async {
    await initialize();
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalWords': _learnedWords.length,
      'words': _learnedWords.map((w) => w.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  /// Import learned words from JSON
  static Future<bool> importWords(String jsonData) async {
    try {
      await initialize();
      
      final data = jsonDecode(jsonData);
      final words = (data['words'] as List)
          .map((json) => LearnedWord.fromJson(json))
          .toList();
      
      // Merge with existing words (avoid duplicates)
      for (final word in words) {
        if (!_learnedWords.any((w) => w.word == word.word)) {
          _learnedWords.add(word);
        }
      }
      
      await _saveLearnedWords();
      return true;
    } catch (e) {
      print('Error importing words: $e');
      return false;
    }
  }
}
