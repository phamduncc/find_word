/// Represents a word found by the player
class Word {
  final String text;
  final int score;
  final DateTime foundAt;
  final List<int> letterIndices; // Indices of letters used from the grid

  const Word({
    required this.text,
    required this.score,
    required this.foundAt,
    required this.letterIndices,
  });

  /// Calculate score based on word length
  static int calculateScore(String word) {
    final length = word.length;
    if (length < 3) return 0;
    
    // Base scoring: 3 letters = 10 points, each additional letter adds more points
    switch (length) {
      case 3:
        return 10;
      case 4:
        return 20;
      case 5:
        return 35;
      case 6:
        return 55;
      case 7:
        return 80;
      case 8:
        return 110;
      default:
        return 110 + (length - 8) * 40; // 40 points for each letter beyond 8
    }
  }

  /// Create a Word instance with auto-calculated score
  factory Word.create({
    required String text,
    required List<int> letterIndices,
  }) {
    return Word(
      text: text.toUpperCase(),
      score: calculateScore(text),
      foundAt: DateTime.now(),
      letterIndices: letterIndices,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'score': score,
      'foundAt': foundAt.toIso8601String(),
      'letterIndices': letterIndices,
    };
  }

  /// Create from JSON
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'] as String,
      score: json['score'] as int,
      foundAt: DateTime.parse(json['foundAt'] as String),
      letterIndices: List<int>.from(json['letterIndices'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word && other.text == text;
  }

  @override
  int get hashCode => text.hashCode;

  /// Create a copy of this word with optional parameter overrides
  Word copyWith({
    String? text,
    int? score,
    DateTime? foundAt,
    List<int>? letterIndices,
  }) {
    return Word(
      text: text ?? this.text,
      score: score ?? this.score,
      foundAt: foundAt ?? this.foundAt,
      letterIndices: letterIndices ?? this.letterIndices,
    );
  }

  @override
  String toString() {
    return 'Word(text: $text, score: $score, foundAt: $foundAt)';
  }
}
