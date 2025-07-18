import 'enums.dart';

/// Game settings configuration
class GameSettings {
  final Difficulty difficulty;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showHints;
  final String playerName;
  final bool learningModeEnabled;
  final bool autoSaveWords;
  final bool showDefinitions;
  final bool enablePronunciation;
  final bool isChallengeMode;
  final String? challengeId;
  final int? targetScore;
  final int? targetWords;

  const GameSettings({
    this.difficulty = Difficulty.medium,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showHints = true,
    this.playerName = 'Player',
    this.learningModeEnabled = false,
    this.autoSaveWords = true,
    this.showDefinitions = true,
    this.enablePronunciation = true,
    this.isChallengeMode = false,
    this.challengeId,
    this.targetScore,
    this.targetWords,
  });

  /// Create a copy with modified values
  GameSettings copyWith({
    Difficulty? difficulty,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showHints,
    String? playerName,
    bool? learningModeEnabled,
    bool? autoSaveWords,
    bool? showDefinitions,
    bool? enablePronunciation,
    bool? isChallengeMode,
    String? challengeId,
    int? targetScore,
    int? targetWords,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showHints: showHints ?? this.showHints,
      playerName: playerName ?? this.playerName,
      learningModeEnabled: learningModeEnabled ?? this.learningModeEnabled,
      autoSaveWords: autoSaveWords ?? this.autoSaveWords,
      showDefinitions: showDefinitions ?? this.showDefinitions,
      enablePronunciation: enablePronunciation ?? this.enablePronunciation,
      isChallengeMode: isChallengeMode ?? this.isChallengeMode,
      challengeId: challengeId ?? this.challengeId,
      targetScore: targetScore ?? this.targetScore,
      targetWords: targetWords ?? this.targetWords,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.index,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showHints': showHints,
      'playerName': playerName,
      'learningModeEnabled': learningModeEnabled,
      'autoSaveWords': autoSaveWords,
      'showDefinitions': showDefinitions,
      'enablePronunciation': enablePronunciation,
      'isChallengeMode': isChallengeMode,
      'challengeId': challengeId,
      'targetScore': targetScore,
      'targetWords': targetWords,
    };
  }

  /// Create from JSON
  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      difficulty: Difficulty.values[json['difficulty'] as int? ?? 1],
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      showHints: json['showHints'] as bool? ?? true,
      playerName: json['playerName'] as String? ?? 'Player',
      learningModeEnabled: json['learningModeEnabled'] as bool? ?? false,
      autoSaveWords: json['autoSaveWords'] as bool? ?? true,
      showDefinitions: json['showDefinitions'] as bool? ?? true,
      enablePronunciation: json['enablePronunciation'] as bool? ?? true,
      isChallengeMode: json['isChallengeMode'] as bool? ?? false,
      challengeId: json['challengeId'] as String?,
      targetScore: json['targetScore'] as int?,
      targetWords: json['targetWords'] as int?,
    );
  }

  /// Create challenge settings from DailyChallenge
  factory GameSettings.fromChallenge(dynamic challenge) {
    // Extract challenge properties
    final challengeType = challenge.type;
    final difficulty = challenge.difficulty;

    // Set targets based on challenge type
    int? targetScore;
    int? targetWords;

    switch (challengeType) {
      case 'score':
        targetScore = challenge.target;
        break;
      case 'words':
        targetWords = challenge.target;
        break;
      case 'time':
        // Time challenges use default targets but shorter time
        targetScore = 100;
        break;
      case 'streak':
        targetWords = 5;
        break;
    }

    return GameSettings(
      difficulty: difficulty,
      isChallengeMode: true,
      challengeId: challenge.id,
      targetScore: targetScore,
      targetWords: targetWords,
      // Use default settings for other properties
      soundEnabled: true,
      vibrationEnabled: true,
      showHints: true,
      playerName: 'Player',
      learningModeEnabled: false,
      autoSaveWords: true,
      showDefinitions: true,
      enablePronunciation: true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameSettings &&
        other.difficulty == difficulty &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.showHints == showHints &&
        other.playerName == playerName &&
        other.learningModeEnabled == learningModeEnabled &&
        other.autoSaveWords == autoSaveWords &&
        other.showDefinitions == showDefinitions &&
        other.enablePronunciation == enablePronunciation;
  }

  @override
  int get hashCode {
    return Object.hash(
      difficulty,
      soundEnabled,
      vibrationEnabled,
      showHints,
      playerName,
      learningModeEnabled,
      autoSaveWords,
      showDefinitions,
      enablePronunciation,
    );
  }

  @override
  String toString() {
    return 'GameSettings(difficulty: $difficulty, soundEnabled: $soundEnabled, '
        'vibrationEnabled: $vibrationEnabled, showHints: $showHints, '
        'playerName: $playerName, learningModeEnabled: $learningModeEnabled, '
        'autoSaveWords: $autoSaveWords, showDefinitions: $showDefinitions, '
        'enablePronunciation: $enablePronunciation)';
  }
}
