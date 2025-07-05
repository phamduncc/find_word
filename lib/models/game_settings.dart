import 'enums.dart';

/// Game settings configuration
class GameSettings {
  final Difficulty difficulty;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showHints;
  final String playerName;

  const GameSettings({
    this.difficulty = Difficulty.medium,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showHints = true,
    this.playerName = 'Player',
  });

  /// Create a copy with modified values
  GameSettings copyWith({
    Difficulty? difficulty,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showHints,
    String? playerName,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showHints: showHints ?? this.showHints,
      playerName: playerName ?? this.playerName,
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
        other.playerName == playerName;
  }

  @override
  int get hashCode {
    return Object.hash(
      difficulty,
      soundEnabled,
      vibrationEnabled,
      showHints,
      playerName,
    );
  }

  @override
  String toString() {
    return 'GameSettings(difficulty: $difficulty, soundEnabled: $soundEnabled, '
        'vibrationEnabled: $vibrationEnabled, showHints: $showHints, '
        'playerName: $playerName)';
  }
}
