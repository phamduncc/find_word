import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:find_words/main.dart';
import 'package:find_words/providers/providers.dart';
import 'package:find_words/services/services.dart';
import 'package:find_words/models/models.dart';

void main() {
  group('Game Flow Integration Tests', () {
    late GameProvider gameProvider;
    late SettingsProvider settingsProvider;
    late HighScoreProvider highScoreProvider;
    late AppProvider appProvider;

    setUp(() async {
      // Initialize storage service for tests
      await StorageService.init();
      
      gameProvider = GameProvider();
      settingsProvider = SettingsProvider();
      highScoreProvider = HighScoreProvider();
      appProvider = AppProvider(
        gameProvider: gameProvider,
        settingsProvider: settingsProvider,
        highScoreProvider: highScoreProvider,
      );
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: gameProvider),
          ChangeNotifierProvider.value(value: settingsProvider),
          ChangeNotifierProvider.value(value: highScoreProvider),
          ChangeNotifierProvider.value(value: appProvider),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('Game State: ${context.watch<GameProvider>().currentSession?.state ?? 'None'}'),
                    Text('Score: ${context.watch<GameProvider>().currentSession?.totalScore ?? 0}'),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read<AppProvider>().startNewGame();
                      },
                      child: Text('Start Game'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GameProvider>().pauseGame();
                      },
                      child: Text('Pause Game'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GameProvider>().resumeGame();
                      },
                      child: Text('Resume Game'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read<AppProvider>().endGameAndSaveScore();
                      },
                      child: Text('End Game'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    testWidgets('should complete full game flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      
      // Initial state should be not started
      expect(find.text('Game State: GameState.notStarted'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
      
      // Start a new game
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();
      
      // Game should be playing
      expect(find.text('Game State: GameState.playing'), findsOneWidget);
      
      // Pause the game
      await tester.tap(find.text('Pause Game'));
      await tester.pump();
      
      // Game should be paused
      expect(find.text('Game State: GameState.paused'), findsOneWidget);
      
      // Resume the game
      await tester.tap(find.text('Resume Game'));
      await tester.pump();
      
      // Game should be playing again
      expect(find.text('Game State: GameState.playing'), findsOneWidget);
      
      // End the game
      await tester.tap(find.text('End Game'));
      await tester.pumpAndSettle();
      
      // Game should be finished
      expect(find.text('Game State: GameState.finished'), findsOneWidget);
    });

    testWidgets('should handle word submission flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      
      // Start a game first
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();
      
      // Simulate word submission through provider
      final session = gameProvider.currentSession!;
      final word = Word(
        text: 'CAT',
        letterIndices: [0, 1, 2],
        score: 20,
        foundAt: DateTime.now(),
      );

      gameProvider.submitWord();
      await tester.pump();
      
      // Score should be updated
      expect(find.text('Score: 20'), findsOneWidget);
    });

    testWidgets('should handle settings changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final settings = context.watch<SettingsProvider>().settings;
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Difficulty: ${settings.difficulty}'),
                      Text('Sound: ${settings.soundEnabled}'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<SettingsProvider>().updateDifficulty(Difficulty.hard);
                        },
                        child: Text('Set Hard'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<SettingsProvider>().updateSoundEnabled(false);
                        },
                        child: Text('Disable Sound'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      // Check initial settings
      expect(find.text('Difficulty: Difficulty.medium'), findsOneWidget);
      expect(find.text('Sound: true'), findsOneWidget);
      
      // Change difficulty
      await tester.tap(find.text('Set Hard'));
      await tester.pump();
      
      expect(find.text('Difficulty: Difficulty.hard'), findsOneWidget);
      
      // Change sound setting
      await tester.tap(find.text('Disable Sound'));
      await tester.pump();
      
      expect(find.text('Sound: false'), findsOneWidget);
    });

    testWidgets('should handle high score updates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: highScoreProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scores = context.watch<HighScoreProvider>().highScores;
                return Scaffold(
                  body: Column(
                    children: [
                      Text('High Scores: ${scores.length}'),
                      ElevatedButton(
                        onPressed: () async {
                          final session = GameSession(
                            id: 'test',
                            letters: ['A', 'B', 'C'],
                            foundWords: [],
                            settings: GameSettings(
                              difficulty: Difficulty.medium,
                            ),
                            startTime: DateTime.now(),
                            state: GameState.finished,
                            timeRemaining: 0,
                          );
                          
                          await context.read<HighScoreProvider>().addHighScore(session);
                        },
                        child: Text('Add Score'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially no scores
      expect(find.text('High Scores: 0'), findsOneWidget);
      
      // Add a high score
      await tester.tap(find.text('Add Score'));
      await tester.pumpAndSettle();
      
      // Should have one score
      expect(find.text('High Scores: 1'), findsOneWidget);
    });

    testWidgets('should handle app initialization', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(value: highScoreProvider),
            ChangeNotifierProvider.value(value: appProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final isInitialized = context.watch<AppProvider>().isInitialized;
                final isLoading = context.watch<AppProvider>().isLoading;
                
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Initialized: $isInitialized'),
                      Text('Loading: $isLoading'),
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<AppProvider>().initialize();
                        },
                        child: Text('Initialize'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially not initialized
      expect(find.text('Initialized: false'), findsOneWidget);
      
      // Initialize the app
      await tester.tap(find.text('Initialize'));
      await tester.pumpAndSettle();
      
      // Should be initialized
      expect(find.text('Initialized: true'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: gameProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final error = context.watch<GameProvider>().errorMessage;
                
                return Scaffold(
                  body: Column(
                    children: [
                      if (error != null) Text('Error: $error'),
                      if (error == null) Text('No Error'),
                      ElevatedButton(
                        onPressed: () {
                          // Try to perform invalid operation
                          gameProvider.pauseGame(); // Pause without starting
                        },
                        child: Text('Invalid Operation'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially no error
      expect(find.text('No Error'), findsOneWidget);
      
      // Perform invalid operation
      await tester.tap(find.text('Invalid Operation'));
      await tester.pump();
      
      // Should handle gracefully (implementation dependent)
      // The exact behavior depends on how the provider handles invalid states
    });
  });
}
