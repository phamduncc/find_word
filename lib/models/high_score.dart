import 'enums.dart';

/// Represents a high score entry
class HighScore {
  final String playerName;
  final int score;
  final int wordsFound;
  final String longestWord;
  final Difficulty difficulty;
  final DateTime achievedAt;
  final Duration gameDuration;

  const HighScore({
    required this.playerName,
    required this.score,
    required this.wordsFound,
    required this.longestWord,
    required this.difficulty,
    required this.achievedAt,
    required this.gameDuration,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'wordsFound': wordsFound,
      'longestWord': longestWord,
      'difficulty': difficulty.index,
      'achievedAt': achievedAt.toIso8601String(),
      'gameDuration': gameDuration.inSeconds,
    };
  }

  /// Create from JSON
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      wordsFound: json['wordsFound'] as int,
      longestWord: json['longestWord'] as String,
      difficulty: Difficulty.values[json['difficulty'] as int],
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      gameDuration: Duration(seconds: json['gameDuration'] as int),
    );
  }

  /// Format game duration as MM:SS
  String get formattedDuration {
    final minutes = gameDuration.inMinutes;
    final seconds = gameDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format achieved date
  String get formattedDate {
    return '${achievedAt.day}/${achievedAt.month}/${achievedAt.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighScore &&
        other.playerName == playerName &&
        other.score == score &&
        other.achievedAt == achievedAt;
  }

  @override
  int get hashCode {
    return Object.hash(playerName, score, achievedAt);
  }

  @override
  String toString() {
    return 'HighScore(player: $playerName, score: $score, words: $wordsFound, '
        'difficulty: $difficulty, date: $formattedDate)';
  }
}

/// Manages high scores for different difficulties
class HighScoreManager {
  static const int maxScoresPerDifficulty = 10;

  /// Sort high scores by score (descending)
  static List<HighScore> sortByScore(List<HighScore> scores) {
    final sorted = List<HighScore>.from(scores);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// Filter scores by difficulty
  static List<HighScore> filterByDifficulty(
    List<HighScore> scores, 
    Difficulty difficulty,
  ) {
    return scores.where((score) => score.difficulty == difficulty).toList();
  }

  /// Get top scores for a specific difficulty
  static List<HighScore> getTopScores(
    List<HighScore> scores, 
    Difficulty difficulty,
  ) {
    final filtered = filterByDifficulty(scores, difficulty);
    final sorted = sortByScore(filtered);
    return sorted.take(maxScoresPerDifficulty).toList();
  }

  /// Check if a score qualifies as a high score
  static bool isHighScore(
    List<HighScore> existingScores,
    int newScore,
    Difficulty difficulty,
  ) {
    final topScores = getTopScores(existingScores, difficulty);
    if (topScores.length < maxScoresPerDifficulty) {
      return true;
    }
    return newScore > topScores.last.score;
  }

  /// Add a new high score and maintain the top scores list
  static List<HighScore> addHighScore(
    List<HighScore> existingScores,
    HighScore newScore,
  ) {
    // Check if this score qualifies first
    if (!isHighScore(existingScores, newScore.score, newScore.difficulty)) {
      return existingScores; // Score doesn't qualify, return unchanged
    }

    final allScores = List<HighScore>.from(existingScores)..add(newScore);
    final topScores = getTopScores(allScores, newScore.difficulty);

    // Keep all scores from other difficulties
    final otherDifficultyScores = allScores
        .where((score) => score.difficulty != newScore.difficulty)
        .toList();

    return [...otherDifficultyScores, ...topScores];
  }

  /// Remove duplicate scores (same player, score, and time within 1 second)
  static List<HighScore> removeDuplicates(List<HighScore> scores) {
    final uniqueScores = <HighScore>[];

    for (final score in scores) {
      final isDuplicate = uniqueScores.any((existing) =>
        existing.playerName == score.playerName &&
        existing.score == score.score &&
        existing.difficulty == score.difficulty &&
        existing.achievedAt.difference(score.achievedAt).abs().inSeconds < 2
      );

      if (!isDuplicate) {
        uniqueScores.add(score);
      }
    }

    return uniqueScores;
  }
}
