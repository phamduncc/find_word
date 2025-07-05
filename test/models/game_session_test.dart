import 'package:flutter_test/flutter_test.dart';
import 'package:find_words/models/models.dart';
import 'package:find_words/services/game_engine.dart';

void main() {
  group('GameSession', () {
    late GameSession gameSession;

    setUp(() {
      gameSession = GameSession(
        id: 'test-session',
        letters: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
        foundWords: [],
        settings: GameSettings(
          difficulty: Difficulty.medium,
          playerName: 'Test Player',
        ),
        startTime: DateTime.now(),
        state: GameState.notStarted,
        timeRemaining: 180,
      );
    });

    test('should create GameSession with correct initial values', () {
      expect(gameSession.id, 'test-session');
      expect(gameSession.settings.difficulty, Difficulty.medium);
      expect(gameSession.settings.playerName, 'Test Player');
      expect(gameSession.letters.length, 9);
      expect(gameSession.timeRemaining, 180);
      expect(gameSession.foundWords, isEmpty);
      expect(gameSession.totalScore, 0);
      expect(gameSession.state, GameState.notStarted);
      expect(gameSession.startTime, isNotNull);
      expect(gameSession.endTime, isNull);
    });

    test('should start game correctly', () {
      final startedSession = GameEngine.startGame(gameSession);

      expect(startedSession.state, GameState.playing);
      expect(startedSession.startTime, isNotNull);
      expect(startedSession.endTime, isNull);
    });

    test('should pause and resume game correctly', () {
      final startedSession = GameEngine.startGame(gameSession);
      final pausedSession = GameEngine.pauseGame(startedSession);

      expect(pausedSession.state, GameState.paused);

      final resumedSession = GameEngine.resumeGame(pausedSession);
      expect(resumedSession.state, GameState.playing);
    });

    test('should end game correctly', () {
      final startedSession = GameEngine.startGame(gameSession);
      final endedSession = GameEngine.endGame(startedSession);

      expect(endedSession.state, GameState.finished);
      expect(endedSession.endTime, isNotNull);
    });

    test('should add found word correctly', () {
      final word = Word(
        text: 'CAB',
        letterIndices: [2, 0, 1],
        score: 20,
        foundAt: DateTime.now(),
      );

      final updatedSession = gameSession.copyWith(
        foundWords: [...gameSession.foundWords, word],
      );

      expect(updatedSession.foundWords.length, 1);
      expect(updatedSession.foundWords.first.text, 'CAB');
      expect(updatedSession.totalScore, 20);
    });

    test('should calculate total score correctly', () {
      final word1 = Word(
        text: 'CAB',
        letterIndices: [2, 0, 1],
        score: 20,
        foundAt: DateTime.now(),
      );

      final word2 = Word(
        text: 'FACE',
        letterIndices: [5, 0, 2, 4],
        score: 35,
        foundAt: DateTime.now(),
      );

      final updatedSession = gameSession.copyWith(
        foundWords: [word1, word2],
      );

      expect(updatedSession.totalScore, 55);
    });

    test('should find longest word correctly', () {
      final shortWord = Word(
        text: 'CAB',
        letterIndices: [2, 0, 1],
        score: 20,
        foundAt: DateTime.now(),
      );

      final longWord = Word(
        text: 'FACED',
        letterIndices: [5, 0, 2, 4, 3],
        score: 50,
        foundAt: DateTime.now(),
      );

      final updatedSession = gameSession.copyWith(
        foundWords: [shortWord, longWord],
      );

      expect(updatedSession.foundWords.length, 2);
      expect(updatedSession.foundWords.any((w) => w.text == 'FACED'), isTrue);
    });

    test('should check if game is active', () {
      expect(gameSession.isActive, isFalse);

      final playingSession = gameSession.copyWith(state: GameState.playing);
      expect(playingSession.isActive, isTrue);

      final pausedSession = gameSession.copyWith(state: GameState.paused);
      expect(pausedSession.isActive, isTrue);

      final finishedSession = gameSession.copyWith(state: GameState.finished);
      expect(finishedSession.isActive, isFalse);
    });

    test('should check if game is finished', () {
      expect(gameSession.isFinished, isFalse);

      final finishedSession = gameSession.copyWith(state: GameState.finished);
      expect(finishedSession.isFinished, isTrue);

      final timeUpSession = gameSession.copyWith(timeRemaining: 0);
      expect(timeUpSession.isFinished, isTrue);
    });
  });
}
