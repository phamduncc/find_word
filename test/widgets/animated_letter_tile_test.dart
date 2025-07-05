import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_words/widgets/widgets.dart';

void main() {
  group('AnimatedLetterTile', () {
    testWidgets('should display letter correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'A',
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should handle tap correctly', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'B',
              index: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedLetterTile));
      expect(tapped, isTrue);
    });

    testWidgets('should show selected state visually', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'C',
              index: 0,
              isSelected: true,
            ),
          ),
        ),
      );

      await tester.pump();
      
      // The tile should be rendered (we can't easily test visual changes in unit tests)
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
    });

    testWidgets('should show correct state visually', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'D',
              index: 0,
              isCorrect: true,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
    });

    testWidgets('should show incorrect state visually', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'E',
              index: 0,
              isIncorrect: true,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
    });

    testWidgets('should handle state changes with animation', (WidgetTester tester) async {
      bool isSelected = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedLetterTile(
                      letter: 'F',
                      index: 0,
                      isSelected: isSelected,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => isSelected = !isSelected),
                      child: Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
      
      // Tap to change state
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      
      // Should still be there after state change
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
      
      // Let animation complete
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
    });

    testWidgets('should display letter in uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'g',
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('G'), findsOneWidget);
      expect(find.text('g'), findsNothing);
    });

    testWidgets('should handle multiple state combinations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLetterTile(
              letter: 'H',
              index: 0,
              isSelected: true,
              isCorrect: true,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
      expect(find.text('H'), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (WidgetTester tester) async {
      bool isSelected = false;
      bool isCorrect = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedLetterTile(
                      letter: 'I',
                      index: 0,
                      isSelected: isSelected,
                      isCorrect: isCorrect,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() => isSelected = !isSelected),
                          child: Text('Select'),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => isCorrect = !isCorrect),
                          child: Text('Correct'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Rapid state changes
      await tester.tap(find.text('Select'));
      await tester.pump(Duration(milliseconds: 50));
      
      await tester.tap(find.text('Correct'));
      await tester.pump(Duration(milliseconds: 50));
      
      await tester.tap(find.text('Select'));
      await tester.pump(Duration(milliseconds: 50));
      
      // Should handle rapid changes gracefully
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
      
      // Let all animations settle
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedLetterTile), findsOneWidget);
    });

    testWidgets('should maintain letter content during animations', (WidgetTester tester) async {
      bool isSelected = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedLetterTile(
                      letter: 'J',
                      index: 0,
                      isSelected: isSelected,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => isSelected = !isSelected),
                      child: Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Check initial letter
      expect(find.text('J'), findsOneWidget);
      
      // Change state and check letter is still there during animation
      await tester.tap(find.text('Toggle'));
      await tester.pump(Duration(milliseconds: 100));
      expect(find.text('J'), findsOneWidget);
      
      // Check letter is still there after animation
      await tester.pumpAndSettle();
      expect(find.text('J'), findsOneWidget);
    });
  });
}
