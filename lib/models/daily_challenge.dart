import 'dart:math';
import 'enums.dart';

/// Types of daily challenges
enum ChallengeType {
  wordCount,      // Find X words
  timeLimit,      // Complete in X seconds
  longWords,      // Find words with X+ letters
  noHints,        // Complete without using hints
  perfectScore,   // No invalid attempts
  speedRun,       // Find words quickly
  themeWords,     // Find words related to a theme
}

/// Daily challenge configuration
class DailyChallenge {
  final String id;
  final DateTime date;
  final ChallengeType type;
  final String title;
  final String description;
  final Map<String, dynamic> parameters;
  final int rewardPoints;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? bestScore;

  const DailyChallenge({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.parameters,
    required this.rewardPoints,
    this.isCompleted = false,
    this.completedAt,
    this.bestScore,
  });

  /// Get the target value for this challenge
  int get target {
    switch (type) {
      case ChallengeType.wordCount:
        return parameters['wordCount'] as int? ?? 10;
      case ChallengeType.timeLimit:
        return parameters['timeLimit'] as int? ?? 300;
      case ChallengeType.longWords:
        return parameters['minLength'] as int? ?? 6;
      case ChallengeType.speedRun:
        return parameters['targetWords'] as int? ?? 5;
      default:
        return parameters['target'] as int? ?? 100;
    }
  }

  /// Get the difficulty level for this challenge
  Difficulty get difficulty {
    final difficultyIndex = parameters['difficulty'] as int? ?? 1;
    return Difficulty.values[difficultyIndex.clamp(0, Difficulty.values.length - 1)];
  }

  /// Create a copy with modified values
  DailyChallenge copyWith({
    String? id,
    DateTime? date,
    ChallengeType? type,
    String? title,
    String? description,
    Map<String, dynamic>? parameters,
    int? rewardPoints,
    bool? isCompleted,
    DateTime? completedAt,
    int? bestScore,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.index,
      'title': title,
      'description': description,
      'parameters': parameters,
      'rewardPoints': rewardPoints,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'bestScore': bestScore,
    };
  }

  /// Create from JSON
  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: ChallengeType.values[json['type'] as int],
      title: json['title'] as String,
      description: json['description'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      rewardPoints: json['rewardPoints'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      bestScore: json['bestScore'] as int?,
    );
  }
}

/// Daily challenge generator
class DailyChallengeGenerator {
  static final Random _random = Random();

  /// Generate daily challenge for a specific date
  static DailyChallenge generateForDate(DateTime date) {
    // Use date as seed for consistent daily challenges
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    
    final challengeTypes = ChallengeType.values;
    final type = challengeTypes[random.nextInt(challengeTypes.length)];
    
    return _createChallenge(type, date, random);
  }

  /// Create challenge based on type
  static DailyChallenge _createChallenge(ChallengeType type, DateTime date, Random random) {
    final id = 'daily_${date.year}_${date.month}_${date.day}';
    
    switch (type) {
      case ChallengeType.wordCount:
        final targetWords = 8 + random.nextInt(7); // 8-14 words
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'Word Hunter',
          description: 'Find $targetWords words in a single game',
          parameters: {'targetWords': targetWords},
          rewardPoints: targetWords * 10,
        );
        
      case ChallengeType.timeLimit:
        final timeLimit = 45 + random.nextInt(31); // 45-75 seconds
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'Speed Challenge',
          description: 'Find 5+ words in under $timeLimit seconds',
          parameters: {'timeLimit': timeLimit, 'minWords': 5},
          rewardPoints: 150,
        );
        
      case ChallengeType.longWords:
        final minLength = 6 + random.nextInt(3); // 6-8 letters
        final targetCount = 2 + random.nextInt(2); // 2-3 words
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'Long Word Master',
          description: 'Find $targetCount words with $minLength+ letters',
          parameters: {'minLength': minLength, 'targetCount': targetCount},
          rewardPoints: minLength * targetCount * 20,
        );
        
      case ChallengeType.noHints:
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'No Help Needed',
          description: 'Find 6+ words without using hints',
          parameters: {'minWords': 6},
          rewardPoints: 200,
        );
        
      case ChallengeType.perfectScore:
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'Perfect Game',
          description: 'Complete a game with no invalid word attempts',
          parameters: {'minWords': 5},
          rewardPoints: 250,
        );
        
      case ChallengeType.speedRun:
        final maxTime = 3.0 + random.nextDouble() * 2.0; // 3-5 seconds per word
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'Lightning Fast',
          description: 'Find 3 words in under ${maxTime.toStringAsFixed(1)} seconds each',
          parameters: {'maxTimePerWord': maxTime, 'targetWords': 3},
          rewardPoints: 180,
        );
        
      case ChallengeType.themeWords:
        final themes = ['ANIMALS', 'FOOD', 'COLORS', 'NATURE', 'SPORTS'];
        final theme = themes[random.nextInt(themes.length)];
        return DailyChallenge(
          id: id,
          date: date,
          type: type,
          title: 'Theme Master',
          description: 'Find 3 words related to: $theme',
          parameters: {'theme': theme, 'targetWords': 3},
          rewardPoints: 300,
        );
    }
  }
}

/// Challenge progress tracking
class ChallengeProgress {
  final String challengeId;
  final int currentProgress;
  final int targetProgress;
  final Map<String, dynamic> metadata;

  const ChallengeProgress({
    required this.challengeId,
    required this.currentProgress,
    required this.targetProgress,
    this.metadata = const {},
  });

  /// Check if challenge is completed
  bool get isCompleted => currentProgress >= targetProgress;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage => 
      targetProgress > 0 ? (currentProgress / targetProgress).clamp(0.0, 1.0) : 0.0;

  /// Create a copy with updated progress
  ChallengeProgress copyWith({
    String? challengeId,
    int? currentProgress,
    int? targetProgress,
    Map<String, dynamic>? metadata,
  }) {
    return ChallengeProgress(
      challengeId: challengeId ?? this.challengeId,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      challengeId: json['challengeId'] as String,
      currentProgress: json['currentProgress'] as int,
      targetProgress: json['targetProgress'] as int,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}
