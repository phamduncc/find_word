import 'dart:async';
import 'package:flutter/material.dart';

/// Represents a combo streak in the game
class ComboStreak {
  final int level;
  final int wordsInStreak;
  final DateTime startTime;
  final DateTime lastWordTime;
  final double multiplier;
  final List<String> wordsInCombo;

  const ComboStreak({
    required this.level,
    required this.wordsInStreak,
    required this.startTime,
    required this.lastWordTime,
    required this.multiplier,
    required this.wordsInCombo,
  });

  /// Create initial combo
  factory ComboStreak.initial(String firstWord) {
    final now = DateTime.now();
    return ComboStreak(
      level: 1,
      wordsInStreak: 1,
      startTime: now,
      lastWordTime: now,
      multiplier: 1.0,
      wordsInCombo: [firstWord],
    );
  }

  /// Add word to combo
  ComboStreak addWord(String word) {
    final now = DateTime.now();
    final newWordsInStreak = wordsInStreak + 1;
    final newLevel = _calculateLevel(newWordsInStreak);
    final newMultiplier = _calculateMultiplier(newLevel);

    return ComboStreak(
      level: newLevel,
      wordsInStreak: newWordsInStreak,
      startTime: startTime,
      lastWordTime: now,
      multiplier: newMultiplier,
      wordsInCombo: [...wordsInCombo, word],
    );
  }

  /// Calculate combo level based on words in streak
  static int _calculateLevel(int wordsInStreak) {
    if (wordsInStreak < 3) return 1;
    if (wordsInStreak < 5) return 2;
    if (wordsInStreak < 8) return 3;
    if (wordsInStreak < 12) return 4;
    if (wordsInStreak < 16) return 5;
    return 6; // Max level
  }

  /// Calculate score multiplier based on level
  static double _calculateMultiplier(int level) {
    switch (level) {
      case 1: return 1.0;
      case 2: return 1.2;
      case 3: return 1.5;
      case 4: return 1.8;
      case 5: return 2.0;
      case 6: return 2.5;
      default: return 1.0;
    }
  }

  /// Check if combo is still active (within time limit)
  bool isActive({Duration timeLimit = const Duration(seconds: 10)}) {
    final now = DateTime.now();
    return now.difference(lastWordTime) <= timeLimit;
  }

  /// Get combo duration
  Duration get duration => lastWordTime.difference(startTime);

  /// Get time since last word
  Duration get timeSinceLastWord => DateTime.now().difference(lastWordTime);

  /// Get combo description
  String get description {
    switch (level) {
      case 1: return 'Getting Started';
      case 2: return 'Nice Streak!';
      case 3: return 'Great Combo!';
      case 4: return 'Amazing Chain!';
      case 5: return 'Incredible Streak!';
      case 6: return 'LEGENDARY COMBO!';
      default: return 'Combo';
    }
  }

  /// Get combo color based on level
  static Color getComboColor(int level) {
    switch (level) {
      case 1: return const Color(0xFF4CAF50); // Green
      case 2: return const Color(0xFF2196F3); // Blue
      case 3: return const Color(0xFF9C27B0); // Purple
      case 4: return const Color(0xFFFF9800); // Orange
      case 5: return const Color(0xFFF44336); // Red
      case 6: return const Color(0xFFFFD700); // Gold
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  String toString() {
    return 'ComboStreak(level: $level, words: $wordsInStreak, multiplier: ${multiplier}x)';
  }
}

/// Manages combo system for the game
class ComboManager {
  ComboStreak? _currentCombo;
  Timer? _comboTimer;
  final Duration _comboTimeLimit;
  final List<ComboStreak> _completedCombos = [];

  // Callbacks
  void Function(ComboStreak combo)? onComboStarted;
  void Function(ComboStreak combo)? onComboExtended;
  void Function(ComboStreak combo)? onComboLevelUp;
  void Function(ComboStreak combo)? onComboEnded;

  ComboManager({
    Duration comboTimeLimit = const Duration(seconds: 10),
    this.onComboStarted,
    this.onComboExtended,
    this.onComboLevelUp,
    this.onComboEnded,
  }) : _comboTimeLimit = comboTimeLimit;

  /// Get current combo
  ComboStreak? get currentCombo => _currentCombo;

  /// Get all completed combos
  List<ComboStreak> get completedCombos => List.unmodifiable(_completedCombos);

  /// Check if combo is active
  bool get hasActiveCombo => _currentCombo?.isActive(timeLimit: _comboTimeLimit) ?? false;

  /// Get current multiplier
  double get currentMultiplier => _currentCombo?.multiplier ?? 1.0;

  /// Add word to combo system
  void addWord(String word) {
    final now = DateTime.now();

    if (_currentCombo == null || !_currentCombo!.isActive(timeLimit: _comboTimeLimit)) {
      // Start new combo
      _startNewCombo(word);
    } else {
      // Extend existing combo
      _extendCombo(word);
    }

    // Reset combo timer
    _resetComboTimer();
  }

  /// Start a new combo
  void _startNewCombo(String word) {
    _currentCombo = ComboStreak.initial(word);
    onComboStarted?.call(_currentCombo!);
  }

  /// Extend current combo
  void _extendCombo(String word) {
    if (_currentCombo == null) return;

    final previousLevel = _currentCombo!.level;
    _currentCombo = _currentCombo!.addWord(word);

    onComboExtended?.call(_currentCombo!);

    // Check for level up
    if (_currentCombo!.level > previousLevel) {
      onComboLevelUp?.call(_currentCombo!);
    }
  }

  /// Reset combo timer
  void _resetComboTimer() {
    _comboTimer?.cancel();
    _comboTimer = Timer(_comboTimeLimit, () {
      _endCombo();
    });
  }

  /// End current combo
  void _endCombo() {
    if (_currentCombo != null) {
      _completedCombos.add(_currentCombo!);
      onComboEnded?.call(_currentCombo!);
      _currentCombo = null;
    }
    _comboTimer?.cancel();
  }

  /// Force end combo (e.g., game ended)
  void forceEndCombo() {
    _endCombo();
  }

  /// Reset combo system
  void reset() {
    _comboTimer?.cancel();
    _currentCombo = null;
    _completedCombos.clear();
  }

  /// Get combo statistics
  ComboStatistics getStatistics() {
    final allCombos = [..._completedCombos];
    if (_currentCombo != null) {
      allCombos.add(_currentCombo!);
    }

    if (allCombos.isEmpty) {
      return ComboStatistics.empty();
    }

    final maxLevel = allCombos.map((c) => c.level).reduce((a, b) => a > b ? a : b);
    final maxWords = allCombos.map((c) => c.wordsInStreak).reduce((a, b) => a > b ? a : b);
    final totalCombos = _completedCombos.length;
    final averageLevel = allCombos.map((c) => c.level).reduce((a, b) => a + b) / allCombos.length;

    return ComboStatistics(
      maxLevel: maxLevel,
      maxWordsInCombo: maxWords,
      totalCombos: totalCombos,
      averageLevel: averageLevel,
      currentCombo: _currentCombo,
    );
  }

  /// Dispose resources
  void dispose() {
    _comboTimer?.cancel();
  }
}

/// Statistics for combo system
class ComboStatistics {
  final int maxLevel;
  final int maxWordsInCombo;
  final int totalCombos;
  final double averageLevel;
  final ComboStreak? currentCombo;

  const ComboStatistics({
    required this.maxLevel,
    required this.maxWordsInCombo,
    required this.totalCombos,
    required this.averageLevel,
    this.currentCombo,
  });

  factory ComboStatistics.empty() {
    return const ComboStatistics(
      maxLevel: 0,
      maxWordsInCombo: 0,
      totalCombos: 0,
      averageLevel: 0.0,
    );
  }

  @override
  String toString() {
    return 'ComboStatistics(maxLevel: $maxLevel, maxWords: $maxWordsInCombo, total: $totalCombos)';
  }
}
