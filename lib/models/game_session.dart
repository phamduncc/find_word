import 'enums.dart';
import 'word.dart';
import 'game_settings.dart';

/// Represents a complete game session
class GameSession {
  final String id;
  final List<String> letters;
  final List<Word> foundWords;
  final GameSettings settings;
  final DateTime startTime;
  final DateTime? endTime;
  final GameState state;
  final int timeRemaining; // in seconds
  final String currentInput;
  final List<int> selectedLetterIndices;

  const GameSession({
    required this.id,
    required this.letters,
    required this.foundWords,
    required this.settings,
    required this.startTime,
    this.endTime,
    required this.state,
    required this.timeRemaining,
    this.currentInput = '',
    this.selectedLetterIndices = const [],
  });

  /// Total score from all found words
  int get totalScore {
    return foundWords.fold(0, (sum, word) => sum + word.score);
  }

  /// Duration of the game session
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Check if the game is active (playing or paused)
  bool get isActive {
    return state == GameState.playing || state == GameState.paused;
  }

  /// Check if the game is finished
  bool get isFinished {
    return state == GameState.finished || timeRemaining <= 0;
  }

  /// Get the longest word found
  Word? get longestWord {
    if (foundWords.isEmpty) return null;
    return foundWords.reduce((a, b) => a.text.length > b.text.length ? a : b);
  }

  /// Get words by length
  Map<int, List<Word>> get wordsByLength {
    final Map<int, List<Word>> grouped = {};
    for (final word in foundWords) {
      final length = word.text.length;
      grouped[length] = (grouped[length] ?? [])..add(word);
    }
    return grouped;
  }

  /// Create a copy with modified values
  GameSession copyWith({
    String? id,
    List<String>? letters,
    List<Word>? foundWords,
    GameSettings? settings,
    DateTime? startTime,
    DateTime? endTime,
    GameState? state,
    int? timeRemaining,
    String? currentInput,
    List<int>? selectedLetterIndices,
  }) {
    return GameSession(
      id: id ?? this.id,
      letters: letters ?? this.letters,
      foundWords: foundWords ?? this.foundWords,
      settings: settings ?? this.settings,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      state: state ?? this.state,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      currentInput: currentInput ?? this.currentInput,
      selectedLetterIndices: selectedLetterIndices ?? this.selectedLetterIndices,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'letters': letters,
      'foundWords': foundWords.map((w) => w.toJson()).toList(),
      'settings': settings.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'state': state.index,
      'timeRemaining': timeRemaining,
      'currentInput': currentInput,
      'selectedLetterIndices': selectedLetterIndices,
    };
  }

  /// Create from JSON
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      letters: List<String>.from(json['letters'] as List),
      foundWords: (json['foundWords'] as List)
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      settings: GameSettings.fromJson(json['settings'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      state: GameState.values[json['state'] as int],
      timeRemaining: json['timeRemaining'] as int,
      currentInput: json['currentInput'] as String? ?? '',
      selectedLetterIndices: List<int>.from(json['selectedLetterIndices'] as List? ?? []),
    );
  }

  @override
  String toString() {
    return 'GameSession(id: $id, state: $state, score: $totalScore, '
        'words: ${foundWords.length}, timeRemaining: $timeRemaining)';
  }
}
