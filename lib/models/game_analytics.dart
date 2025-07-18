import 'dart:math';

/// Detailed game analytics and statistics
class GameAnalytics {
  final String playerId;
  final DateTime startDate;
  final int totalGamesPlayed;
  final int totalWordsFound;
  final int totalScore;
  final double totalPlayTime; // in minutes
  final Map<String, int> wordLengthStats;
  final Map<String, int> difficultyStats;
  final Map<String, double> performanceByTime; // hour of day -> avg score
  final List<GameSession> recentSessions;
  final PlayerStreak currentStreak;
  final PlayerStreak longestStreak;
  final Map<String, int> achievementProgress;
  final List<PerformanceTrend> trends;

  const GameAnalytics({
    required this.playerId,
    required this.startDate,
    this.totalGamesPlayed = 0,
    this.totalWordsFound = 0,
    this.totalScore = 0,
    this.totalPlayTime = 0.0,
    this.wordLengthStats = const {},
    this.difficultyStats = const {},
    this.performanceByTime = const {},
    this.recentSessions = const [],
    required this.currentStreak,
    required this.longestStreak,
    this.achievementProgress = const {},
    this.trends = const [],
  });

  /// Average score per game
  double get averageScore => totalGamesPlayed > 0 ? totalScore / totalGamesPlayed : 0.0;

  /// Average words per game
  double get averageWordsPerGame => totalGamesPlayed > 0 ? totalWordsFound / totalGamesPlayed : 0.0;

  /// Average play time per game (in minutes)
  double get averagePlayTime => totalGamesPlayed > 0 ? totalPlayTime / totalGamesPlayed : 0.0;

  /// Most productive hour of day
  int get mostProductiveHour {
    if (performanceByTime.isEmpty) return 12;
    return performanceByTime.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .split(':')[0]
        .let((hour) => int.parse(hour));
  }

  /// Favorite word length
  int get favoriteWordLength {
    if (wordLengthStats.isEmpty) return 4;
    return wordLengthStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .let((length) => int.parse(length));
  }

  /// Performance rating (0-100)
  int get performanceRating {
    if (totalGamesPlayed == 0) return 0;
    
    final scoreRating = (averageScore / 1000).clamp(0.0, 1.0);
    final wordsRating = (averageWordsPerGame / 20).clamp(0.0, 1.0);
    final streakRating = (currentStreak.count / 30).clamp(0.0, 1.0);
    final timeRating = (1.0 - (averagePlayTime / 300)).clamp(0.0, 1.0); // Faster is better
    
    return ((scoreRating + wordsRating + streakRating + timeRating) / 4 * 100).round();
  }

  /// Get improvement suggestions
  List<String> get improvementSuggestions {
    final suggestions = <String>[];
    
    if (averageWordsPerGame < 8) {
      suggestions.add('Try to find more words per game - aim for 10+ words!');
    }
    
    if (favoriteWordLength < 5) {
      suggestions.add('Challenge yourself with longer words for higher scores!');
    }
    
    if (currentStreak.count < 3) {
      suggestions.add('Build a daily playing streak for consistency!');
    }
    
    if (averagePlayTime > 180) { // 3 minutes
      suggestions.add('Try to find words faster to improve your efficiency!');
    }
    
    return suggestions;
  }

  /// Create a copy with modified values
  GameAnalytics copyWith({
    String? playerId,
    DateTime? startDate,
    int? totalGamesPlayed,
    int? totalWordsFound,
    int? totalScore,
    double? totalPlayTime,
    Map<String, int>? wordLengthStats,
    Map<String, int>? difficultyStats,
    Map<String, double>? performanceByTime,
    List<GameSession>? recentSessions,
    PlayerStreak? currentStreak,
    PlayerStreak? longestStreak,
    Map<String, int>? achievementProgress,
    List<PerformanceTrend>? trends,
  }) {
    return GameAnalytics(
      playerId: playerId ?? this.playerId,
      startDate: startDate ?? this.startDate,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      wordLengthStats: wordLengthStats ?? this.wordLengthStats,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      performanceByTime: performanceByTime ?? this.performanceByTime,
      recentSessions: recentSessions ?? this.recentSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievementProgress: achievementProgress ?? this.achievementProgress,
      trends: trends ?? this.trends,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'startDate': startDate.toIso8601String(),
      'totalGamesPlayed': totalGamesPlayed,
      'totalWordsFound': totalWordsFound,
      'totalScore': totalScore,
      'totalPlayTime': totalPlayTime,
      'wordLengthStats': wordLengthStats,
      'difficultyStats': difficultyStats,
      'performanceByTime': performanceByTime,
      'recentSessions': recentSessions.map((s) => s.toJson()).toList(),
      'currentStreak': currentStreak.toJson(),
      'longestStreak': longestStreak.toJson(),
      'achievementProgress': achievementProgress,
      'trends': trends.map((t) => t.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory GameAnalytics.fromJson(Map<String, dynamic> json) {
    return GameAnalytics(
      playerId: json['playerId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalWordsFound: json['totalWordsFound'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      totalPlayTime: (json['totalPlayTime'] as num?)?.toDouble() ?? 0.0,
      wordLengthStats: Map<String, int>.from(json['wordLengthStats'] as Map? ?? {}),
      difficultyStats: Map<String, int>.from(json['difficultyStats'] as Map? ?? {}),
      performanceByTime: Map<String, double>.from(json['performanceByTime'] as Map? ?? {}),
      recentSessions: (json['recentSessions'] as List?)
          ?.map((s) => GameSession.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      currentStreak: PlayerStreak.fromJson(json['currentStreak'] as Map<String, dynamic>),
      longestStreak: PlayerStreak.fromJson(json['longestStreak'] as Map<String, dynamic>),
      achievementProgress: Map<String, int>.from(json['achievementProgress'] as Map? ?? {}),
      trends: (json['trends'] as List?)
          ?.map((t) => PerformanceTrend.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// Player streak information
class PlayerStreak {
  final int count;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const PlayerStreak({
    required this.count,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  /// Duration of the streak
  Duration get duration {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }

  /// Create a copy with modified values
  PlayerStreak copyWith({
    int? count,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return PlayerStreak(
      count: count ?? this.count,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory PlayerStreak.fromJson(Map<String, dynamic> json) {
    return PlayerStreak(
      count: json['count'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// Game session data for analytics
class GameSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int score;
  final int wordsFound;
  final String difficulty;
  final List<String> foundWords;
  final int invalidAttempts;
  final Map<String, dynamic> metadata;

  const GameSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.wordsFound,
    required this.difficulty,
    this.foundWords = const [],
    this.invalidAttempts = 0,
    this.metadata = const {},
  });

  /// Session duration in minutes
  double get durationMinutes => endTime.difference(startTime).inSeconds / 60.0;

  /// Words per minute
  double get wordsPerMinute => durationMinutes > 0 ? wordsFound / durationMinutes : 0.0;

  /// Score per minute
  double get scorePerMinute => durationMinutes > 0 ? score / durationMinutes : 0.0;

  /// Average word length
  double get averageWordLength {
    if (foundWords.isEmpty) return 0.0;
    return foundWords.map((w) => w.length).reduce((a, b) => a + b) / foundWords.length;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'score': score,
      'wordsFound': wordsFound,
      'difficulty': difficulty,
      'foundWords': foundWords,
      'invalidAttempts': invalidAttempts,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      score: json['score'] as int,
      wordsFound: json['wordsFound'] as int,
      difficulty: json['difficulty'] as String,
      foundWords: List<String>.from(json['foundWords'] as List? ?? []),
      invalidAttempts: json['invalidAttempts'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

/// Performance trend data
class PerformanceTrend {
  final String metric; // 'score', 'words', 'time', etc.
  final List<TrendPoint> points;
  final TrendDirection direction;
  final double changePercentage;

  const PerformanceTrend({
    required this.metric,
    required this.points,
    required this.direction,
    required this.changePercentage,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'points': points.map((p) => p.toJson()).toList(),
      'direction': direction.index,
      'changePercentage': changePercentage,
    };
  }

  /// Create from JSON
  factory PerformanceTrend.fromJson(Map<String, dynamic> json) {
    return PerformanceTrend(
      metric: json['metric'] as String,
      points: (json['points'] as List)
          .map((p) => TrendPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      direction: TrendDirection.values[json['direction'] as int],
      changePercentage: (json['changePercentage'] as num).toDouble(),
    );
  }
}

/// Individual trend point
class TrendPoint {
  final DateTime date;
  final double value;

  const TrendPoint({
    required this.date,
    required this.value,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  /// Create from JSON
  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

/// Trend direction
enum TrendDirection {
  improving,
  declining,
  stable,
}

/// Extension for convenience methods
extension on String {
  T let<T>(T Function(String) transform) => transform(this);
}
