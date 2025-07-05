/// Game state enumeration
enum GameState {
  notStarted,
  playing,
  paused,
  finished,
}

/// Difficulty levels
enum Difficulty {
  easy,
  medium,
  hard,
}

/// Extension for Difficulty enum to provide additional properties
extension DifficultyExtension on Difficulty {
  /// Number of letters for each difficulty
  int get letterCount {
    switch (this) {
      case Difficulty.easy:
        return 9;
      case Difficulty.medium:
        return 12;
      case Difficulty.hard:
        return 15;
    }
  }

  /// Time limit in seconds for each difficulty
  int get timeLimit {
    switch (this) {
      case Difficulty.easy:
        return 120; // 2 minutes
      case Difficulty.medium:
        return 90;  // 1.5 minutes
      case Difficulty.hard:
        return 60;  // 1 minute
    }
  }

  /// Minimum word length for each difficulty
  int get minWordLength {
    switch (this) {
      case Difficulty.easy:
        return 2;
      case Difficulty.medium:
        return 3;
      case Difficulty.hard:
        return 4;
    }
  }

  /// Display name for each difficulty
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  /// Color associated with each difficulty
  String get colorHex {
    switch (this) {
      case Difficulty.easy:
        return '#4CAF50'; // Green
      case Difficulty.medium:
        return '#FF9800'; // Orange
      case Difficulty.hard:
        return '#F44336'; // Red
    }
  }
}
