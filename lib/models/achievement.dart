import 'package:flutter/material.dart';

/// Types of achievements available in the game
enum AchievementType {
  wordMaster,
  speedDemon,
  dictionary,
  firstWord,
  perfectGame,
  timeChallenger,
}

/// Extension for AchievementType to provide additional properties
extension AchievementTypeExtension on AchievementType {
  /// Display name for the achievement
  String get displayName {
    switch (this) {
      case AchievementType.wordMaster:
        return 'Word Master';
      case AchievementType.speedDemon:
        return 'Speed Demon';
      case AchievementType.dictionary:
        return 'Dictionary';
      case AchievementType.firstWord:
        return 'First Word';
      case AchievementType.perfectGame:
        return 'Perfect Game';
      case AchievementType.timeChallenger:
        return 'Time Challenger';
    }
  }

  /// Description of what the achievement requires
  String get description {
    switch (this) {
      case AchievementType.wordMaster:
        return 'Find 100 words total';
      case AchievementType.speedDemon:
        return 'Find a word in less than 5 seconds';
      case AchievementType.dictionary:
        return 'Find a word with 8+ letters';
      case AchievementType.firstWord:
        return 'Find your first word';
      case AchievementType.perfectGame:
        return 'Complete a game without wrong attempts';
      case AchievementType.timeChallenger:
        return 'Find 10 words in a single game';
    }
  }

  /// Icon for the achievement
  IconData get icon {
    switch (this) {
      case AchievementType.wordMaster:
        return Icons.school;
      case AchievementType.speedDemon:
        return Icons.flash_on;
      case AchievementType.dictionary:
        return Icons.menu_book;
      case AchievementType.firstWord:
        return Icons.star;
      case AchievementType.perfectGame:
        return Icons.check_circle;
      case AchievementType.timeChallenger:
        return Icons.timer;
    }
  }

  /// Color for the achievement badge
  Color get color {
    switch (this) {
      case AchievementType.wordMaster:
        return Colors.purple;
      case AchievementType.speedDemon:
        return Colors.orange;
      case AchievementType.dictionary:
        return Colors.blue;
      case AchievementType.firstWord:
        return Colors.yellow;
      case AchievementType.perfectGame:
        return Colors.green;
      case AchievementType.timeChallenger:
        return Colors.red;
    }
  }

  /// Points awarded for this achievement
  int get points {
    switch (this) {
      case AchievementType.wordMaster:
        return 500;
      case AchievementType.speedDemon:
        return 100;
      case AchievementType.dictionary:
        return 200;
      case AchievementType.firstWord:
        return 50;
      case AchievementType.perfectGame:
        return 300;
      case AchievementType.timeChallenger:
        return 150;
    }
  }
}

/// Represents an achievement that can be unlocked
class Achievement {
  final AchievementType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  const Achievement({
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  /// Create a copy with modified values
  Achievement copyWith({
    AchievementType? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? target,
  }) {
    return Achievement(
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (target == 0) return 1.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// Check if achievement is completed but not yet unlocked
  bool get isCompleted => progress >= target;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  /// Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      type: AchievementType.values[json['type'] as int],
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'Achievement(type: $type, isUnlocked: $isUnlocked, progress: $progress/$target)';
  }
}

/// Factory class to create default achievements
class AchievementFactory {
  /// Create all default achievements
  static List<Achievement> createDefaultAchievements() {
    return [
      const Achievement(
        type: AchievementType.firstWord,
        target: 1,
      ),
      const Achievement(
        type: AchievementType.wordMaster,
        target: 100,
      ),
      const Achievement(
        type: AchievementType.speedDemon,
        target: 1,
      ),
      const Achievement(
        type: AchievementType.dictionary,
        target: 1,
      ),
      const Achievement(
        type: AchievementType.perfectGame,
        target: 1,
      ),
      const Achievement(
        type: AchievementType.timeChallenger,
        target: 10,
      ),
    ];
  }
}
