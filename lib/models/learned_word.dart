import '../services/dictionary_service.dart';

/// Model for a word that has been learned by the user
class LearnedWord {
  final String word;
  final String definition;
  final String phonetic;
  final String partOfSpeech;
  final String example;
  final DateTime learnedAt;
  final int timesEncountered;
  final int correctAnswers;
  final double averageTimeToFind; // in seconds
  final bool isFavorite;
  final List<String> tags;

  const LearnedWord({
    required this.word,
    required this.definition,
    required this.phonetic,
    required this.partOfSpeech,
    required this.example,
    required this.learnedAt,
    this.timesEncountered = 1,
    this.correctAnswers = 1,
    this.averageTimeToFind = 0.0,
    this.isFavorite = false,
    this.tags = const [],
  });

  /// Create a LearnedWord from a Word and WordDefinition
  factory LearnedWord.fromWordAndDefinition(
    String word,
    WordDefinition? definition, {
    double timeToFind = 0.0,
  }) {
    return LearnedWord(
      word: word.toUpperCase(),
      definition: definition?.primaryDefinition ?? 'No definition available',
      phonetic: definition?.phonetic ?? '',
      partOfSpeech: definition?.partOfSpeech ?? '',
      example: definition?.primaryExample ?? '',
      learnedAt: DateTime.now(),
      averageTimeToFind: timeToFind,
    );
  }

  /// Create from JSON
  factory LearnedWord.fromJson(Map<String, dynamic> json) {
    return LearnedWord(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      phonetic: json['phonetic'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      example: json['example'] ?? '',
      learnedAt: DateTime.parse(json['learnedAt'] ?? DateTime.now().toIso8601String()),
      timesEncountered: json['timesEncountered'] ?? 1,
      correctAnswers: json['correctAnswers'] ?? 1,
      averageTimeToFind: (json['averageTimeToFind'] ?? 0.0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'phonetic': phonetic,
      'partOfSpeech': partOfSpeech,
      'example': example,
      'learnedAt': learnedAt.toIso8601String(),
      'timesEncountered': timesEncountered,
      'correctAnswers': correctAnswers,
      'averageTimeToFind': averageTimeToFind,
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  /// Create a copy with updated values
  LearnedWord copyWith({
    String? word,
    String? definition,
    String? phonetic,
    String? partOfSpeech,
    String? example,
    DateTime? learnedAt,
    int? timesEncountered,
    int? correctAnswers,
    double? averageTimeToFind,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return LearnedWord(
      word: word ?? this.word,
      definition: definition ?? this.definition,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      example: example ?? this.example,
      learnedAt: learnedAt ?? this.learnedAt,
      timesEncountered: timesEncountered ?? this.timesEncountered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      averageTimeToFind: averageTimeToFind ?? this.averageTimeToFind,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  /// Update statistics when word is encountered again
  LearnedWord updateStats({
    required double newTimeToFind,
    required bool wasCorrect,
  }) {
    final newTimesEncountered = timesEncountered + 1;
    final newCorrectAnswers = wasCorrect ? correctAnswers + 1 : correctAnswers;
    
    // Calculate new average time (weighted average)
    final newAverageTime = ((averageTimeToFind * timesEncountered) + newTimeToFind) / newTimesEncountered;

    return copyWith(
      timesEncountered: newTimesEncountered,
      correctAnswers: newCorrectAnswers,
      averageTimeToFind: newAverageTime,
    );
  }

  /// Get accuracy percentage
  double get accuracy {
    if (timesEncountered == 0) return 0.0;
    return (correctAnswers / timesEncountered) * 100;
  }

  /// Get difficulty level based on stats
  String get difficultyLevel {
    if (averageTimeToFind <= 3.0 && accuracy >= 90) return 'Easy';
    if (averageTimeToFind <= 8.0 && accuracy >= 70) return 'Medium';
    return 'Hard';
  }

  /// Get mastery level
  String get masteryLevel {
    if (timesEncountered >= 10 && accuracy >= 95) return 'Mastered';
    if (timesEncountered >= 5 && accuracy >= 80) return 'Proficient';
    if (timesEncountered >= 3 && accuracy >= 60) return 'Learning';
    return 'Beginner';
  }

  /// Check if word needs review (low accuracy or not seen recently)
  bool get needsReview {
    final daysSinceLastSeen = DateTime.now().difference(learnedAt).inDays;
    return accuracy < 70 || daysSinceLastSeen > 7;
  }

  /// Get word length category
  String get lengthCategory {
    if (word.length <= 3) return 'Short';
    if (word.length <= 6) return 'Medium';
    if (word.length <= 9) return 'Long';
    return 'Very Long';
  }

  /// Get formatted phonetic pronunciation
  String get formattedPhonetic {
    if (phonetic.isEmpty) return '';
    if (phonetic.startsWith('/') && phonetic.endsWith('/')) {
      return phonetic;
    }
    return '/$phonetic/';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearnedWord && other.word == word;
  }

  @override
  int get hashCode => word.hashCode;

  @override
  String toString() {
    return 'LearnedWord(word: $word, definition: ${definition.length > 50 ? '${definition.substring(0, 50)}...' : definition}, accuracy: ${accuracy.toStringAsFixed(1)}%)';
  }
}
