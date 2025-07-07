import 'dart:async';
import 'dart:math';
import '../models/models.dart';
import '../models/combo_system.dart';
import '../models/learned_word.dart';
import 'letter_generator.dart';
import 'dictionary_service.dart';
import 'my_dictionary_service.dart';
import 'word_validator.dart';
import 'haptic_service.dart';

/// Core game engine that manages game logic and state
class GameEngine {
  static final Random _random = Random();
  
  /// Generate a new game session
  static GameSession createNewGame(GameSettings settings) {
    final letters = LetterGenerator.generatePlayableLetters(
      settings.difficulty.letterCount
    );
    
    return GameSession(
      id: _generateGameId(),
      letters: letters,
      foundWords: [],
      settings: settings,
      startTime: DateTime.now(),
      state: GameState.notStarted,
      timeRemaining: settings.difficulty.timeLimit,
    );
  }

  /// Start a game session
  static GameSession startGame(GameSession session) {
    return session.copyWith(
      state: GameState.playing,
      startTime: DateTime.now(),
      timeRemaining: session.settings.difficulty.timeLimit,
    );
  }

  /// Pause a game session
  static GameSession pauseGame(GameSession session) {
    if (session.state != GameState.playing) return session;
    
    return session.copyWith(state: GameState.paused);
  }

  /// Resume a paused game session
  static GameSession resumeGame(GameSession session) {
    if (session.state != GameState.paused) return session;
    
    return session.copyWith(state: GameState.playing);
  }

  /// End a game session
  static GameSession endGame(GameSession session) {
    return session.copyWith(
      state: GameState.finished,
      endTime: DateTime.now(),
      timeRemaining: 0,
    );
  }

  /// Update game timer
  static GameSession updateTimer(GameSession session, int newTimeRemaining) {
    if (session.state != GameState.playing) return session;

    final updatedSession = session.copyWith(timeRemaining: newTimeRemaining);

    // Auto-end game if time runs out
    if (newTimeRemaining <= 0) {
      return endGame(updatedSession);
    }

    return updatedSession;
  }

  /// Add time bonus based on word score (1 point = 1 second)
  static GameSession addTimeBonus(GameSession session, int bonusSeconds) {
    if (session.state != GameState.playing) return session;

    final newTimeRemaining = session.timeRemaining + bonusSeconds;

    return session.copyWith(timeRemaining: newTimeRemaining);
  }

  /// Select a letter at the given index
  static GameSession selectLetter(GameSession session, int letterIndex) {
    if (session.state != GameState.playing) return session;
    if (letterIndex < 0 || letterIndex >= session.letters.length) return session;
    if (session.selectedLetterIndices.contains(letterIndex)) return session;
    
    final newSelectedIndices = [...session.selectedLetterIndices, letterIndex];
    final newInput = session.currentInput + session.letters[letterIndex];
    
    return session.copyWith(
      selectedLetterIndices: newSelectedIndices,
      currentInput: newInput,
    );
  }

  /// Deselect the last selected letter
  static GameSession deselectLastLetter(GameSession session) {
    if (session.state != GameState.playing) return session;
    if (session.selectedLetterIndices.isEmpty) return session;
    
    final newSelectedIndices = [...session.selectedLetterIndices];
    newSelectedIndices.removeLast();
    
    final newInput = newSelectedIndices
        .map((index) => session.letters[index])
        .join('');
    
    return session.copyWith(
      selectedLetterIndices: newSelectedIndices,
      currentInput: newInput,
    );
  }

  /// Clear all selected letters
  static GameSession clearSelection(GameSession session) {
    if (session.state != GameState.playing) return session;
    
    return session.copyWith(
      selectedLetterIndices: [],
      currentInput: '',
    );
  }

  /// Submit the current word
  static Future<GameSubmissionResult> submitWord(
    GameSession session, {
    ComboManager? comboManager,
    GameSettings? gameSettings,
  }) async {
    if (session.state != GameState.playing) {
      await HapticService.error();
      return GameSubmissionResult(
        success: false,
        message: 'Game is not active',
        updatedSession: session,
      );
    }

    if (session.currentInput.isEmpty) {
      await HapticService.error();
      return GameSubmissionResult(
        success: false,
        message: 'No word entered',
        updatedSession: session,
      );
    }

    // Check if word was already found
    final alreadyFound = session.foundWords
        .any((word) => word.text == session.currentInput.toUpperCase());

    if (alreadyFound) {
      await HapticService.error();
      return GameSubmissionResult(
        success: false,
        message: 'Word already found',
        updatedSession: clearSelection(session),
      );
    }

    // Validate the word
    final validation = WordValidator.validateWord(
      session.currentInput,
      session.letters,
      minLength: session.settings.difficulty.minWordLength,
    );

    if (!validation.isValid) {
      await HapticService.error();
      return GameSubmissionResult(
        success: false,
        message: validation.reason ?? 'Invalid word',
        updatedSession: clearSelection(session),
      );
    }

    // Calculate time to find word
    final timeToFind = session.startTime != null
        ? DateTime.now().difference(session.startTime!).inSeconds.toDouble()
        : 0.0;

    // Get word definition if Learning Mode is enabled
    WordDefinition? definition;
    if (gameSettings?.learningModeEnabled == true && gameSettings?.showDefinitions == true) {
      try {
        definition = await DictionaryService.getDefinition(session.currentInput);
      } catch (e) {
        print('Failed to get definition for ${session.currentInput}: $e');
      }
    }

    // Create the word and add to found words
    final word = Word.create(
      text: session.currentInput,
      letterIndices: session.selectedLetterIndices,
      definition: definition,
      timeToFind: timeToFind,
    );

    // Add word to combo system
    comboManager?.addWord(word.text);
    final currentCombo = comboManager?.currentCombo;

    // Calculate final score with combo multiplier
    final baseScore = word.score;
    final multiplier = currentCombo?.multiplier ?? 1.0;
    final finalScore = (baseScore * multiplier).round();
    final finalWord = word.copyWith(score: finalScore);

    // Add time bonus equal to final word score (1 point = 1 second)
    final sessionWithWord = session.copyWith(
      foundWords: [...session.foundWords, finalWord],
      selectedLetterIndices: [],
      currentInput: '',
    );

    final finalSession = addTimeBonus(sessionWithWord, finalScore);

    // Save to My Dictionary if Learning Mode is enabled and auto-save is on
    if (gameSettings?.learningModeEnabled == true &&
        gameSettings?.autoSaveWords == true &&
        definition != null) {
      try {
        final learnedWord = LearnedWord.fromWordAndDefinition(
          finalWord.text,
          definition,
          timeToFind: timeToFind,
        );
        await MyDictionaryService.addLearnedWord(learnedWord);
      } catch (e) {
        print('Failed to save word to My Dictionary: $e');
      }
    }

    // Haptic feedback based on word length and combo
    await HapticService.wordFound(word.text.length);
    if (currentCombo != null && currentCombo.level > 1) {
      await HapticService.comboAchieved(currentCombo.level);
    }
    await HapticService.timeBonus(finalScore);

    final message = currentCombo != null && currentCombo.level > 1
        ? 'Word found! +$finalScore points (+${finalScore}s time) • ${currentCombo.multiplier.toStringAsFixed(1)}x COMBO'
        : 'Word found! +$finalScore points (+${finalScore}s time)';

    return GameSubmissionResult(
      success: true,
      message: message,
      updatedSession: finalSession,
      wordFound: finalWord,
      combo: currentCombo,
    );
  }

  /// Get game statistics
  static GameStatistics getGameStatistics(GameSession session) {
    final words = session.foundWords;
    final wordsByLength = <int, int>{};
    
    for (final word in words) {
      final length = word.text.length;
      wordsByLength[length] = (wordsByLength[length] ?? 0) + 1;
    }
    
    return GameStatistics(
      totalWords: words.length,
      totalScore: session.totalScore,
      longestWord: session.longestWord?.text ?? '',
      averageWordLength: words.isEmpty 
          ? 0.0 
          : words.map((w) => w.text.length).reduce((a, b) => a + b) / words.length,
      wordsByLength: wordsByLength,
      timeElapsed: session.duration,
      wordsPerMinute: session.duration.inMinutes > 0 
          ? words.length / session.duration.inMinutes 
          : 0.0,
    );
  }

  /// Get possible hints for the player
  static List<String> getHints(GameSession session, {int maxHints = 3}) {
    final alreadyFound = session.foundWords.map((w) => w.text).toList();
    return WordValidator.getHintWords(
      session.letters,
      alreadyFound,
      maxHints: maxHints,
    );
  }

  /// Check if the game qualifies for a high score
  static bool isHighScore(GameSession session, List<HighScore> existingScores) {
    if (session.state != GameState.finished) return false;
    
    return HighScoreManager.isHighScore(
      existingScores,
      session.totalScore,
      session.settings.difficulty,
    );
  }

  /// Create a high score from a finished game session
  static HighScore createHighScore(GameSession session) {
    if (session.state != GameState.finished) {
      throw StateError('Cannot create high score from unfinished game');
    }
    
    return HighScore(
      playerName: session.settings.playerName,
      score: session.totalScore,
      wordsFound: session.foundWords.length,
      longestWord: session.longestWord?.text ?? '',
      difficulty: session.settings.difficulty,
      achievedAt: session.endTime ?? DateTime.now(),
      gameDuration: session.duration,
    );
  }

  /// Generate a unique game ID
  static String _generateGameId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(10000);
    return 'game_${timestamp}_$random';
  }
}

/// Result of submitting a word
class GameSubmissionResult {
  final bool success;
  final String message;
  final GameSession updatedSession;
  final Word? wordFound;
  final ComboStreak? combo;

  const GameSubmissionResult({
    required this.success,
    required this.message,
    required this.updatedSession,
    this.wordFound,
    this.combo,
  });
}

/// Game statistics
class GameStatistics {
  final int totalWords;
  final int totalScore;
  final String longestWord;
  final double averageWordLength;
  final Map<int, int> wordsByLength;
  final Duration timeElapsed;
  final double wordsPerMinute;

  const GameStatistics({
    required this.totalWords,
    required this.totalScore,
    required this.longestWord,
    required this.averageWordLength,
    required this.wordsByLength,
    required this.timeElapsed,
    required this.wordsPerMinute,
  });

  @override
  String toString() {
    return 'GameStatistics(words: $totalWords, score: $totalScore, '
        'longest: $longestWord, avgLength: ${averageWordLength.toStringAsFixed(1)})';
  }
}
