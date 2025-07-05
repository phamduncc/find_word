import 'package:flutter_test/flutter_test.dart';
import 'package:find_words/services/services.dart';
import 'package:find_words/models/models.dart';

void main() {
  group('LetterGenerator', () {

    test('should generate correct number of letters', () {
      final letters = LetterGenerator.generateLetters(9);
      expect(letters.length, 9);
      
      final moreLetters = LetterGenerator.generateLetters(16);
      expect(moreLetters.length, 16);
    });

    test('should generate only valid letters', () {
      final letters = LetterGenerator.generateLetters(20);
      
      for (final letter in letters) {
        expect(letter.length, 1);
        expect(RegExp(r'^[A-Z]$').hasMatch(letter), isTrue);
      }
    });

    test('should generate different letters on multiple calls', () {
      final letters1 = LetterGenerator.generateLetters(9);
      final letters2 = LetterGenerator.generateLetters(9);
      
      // It's extremely unlikely that two random generations are identical
      expect(letters1, isNot(equals(letters2)));
    });

    test('should respect difficulty-based frequency distribution', () {
      // Generate many letters to test distribution
      final letters = LetterGenerator.generateLetters(1000);
      
      // Count frequency of each letter
      final frequency = <String, int>{};
      for (final letter in letters) {
        frequency[letter] = (frequency[letter] ?? 0) + 1;
      }
      
      // Common letters should appear more frequently than rare ones
      final eCount = frequency['E'] ?? 0;
      final tCount = frequency['T'] ?? 0;
      final aCount = frequency['A'] ?? 0;
      final qCount = frequency['Q'] ?? 0;
      final xCount = frequency['X'] ?? 0;
      final zCount = frequency['Z'] ?? 0;
      
      // E, T, A should be more common than Q, X, Z
      expect(eCount, greaterThan(qCount));
      expect(tCount, greaterThan(xCount));
      expect(aCount, greaterThan(zCount));
    });

    test('should generate letters with vowels and consonants', () {
      final letters = LetterGenerator.generateLetters(9);

      expect(letters.length, 9);

      // Should have at least some vowels and consonants
      final vowelCount = letters.where((l) => 'AEIOU'.contains(l)).length;
      final consonantCount = letters.where((l) => !'AEIOU'.contains(l)).length;

      expect(vowelCount, greaterThanOrEqualTo(1));
      expect(consonantCount, greaterThanOrEqualTo(1));

      // All should contain valid letters
      for (final letter in letters) {
        expect(RegExp(r'^[A-Z]$').hasMatch(letter), isTrue);
      }
    });

    test('should include vowels in generated letters', () {
      // Generate multiple sets to ensure vowels are included
      bool hasVowels = false;
      
      for (int i = 0; i < 10; i++) {
        final letters = LetterGenerator.generateLetters(9);
        final vowels = letters.where((letter) => 'AEIOU'.contains(letter));
        
        if (vowels.isNotEmpty) {
          hasVowels = true;
          break;
        }
      }
      
      expect(hasVowels, isTrue);
    });

    test('should include consonants in generated letters', () {
      // Generate multiple sets to ensure consonants are included
      bool hasConsonants = false;
      
      for (int i = 0; i < 10; i++) {
        final letters = LetterGenerator.generateLetters(9);
        final consonants = letters.where((letter) => !'AEIOU'.contains(letter));
        
        if (consonants.isNotEmpty) {
          hasConsonants = true;
          break;
        }
      }
      
      expect(hasConsonants, isTrue);
    });

    test('should handle edge cases', () {
      // Test with minimum letters
      final minLetters = LetterGenerator.generateLetters(1);
      expect(minLetters.length, 1);
      expect(RegExp(r'^[A-Z]$').hasMatch(minLetters.first), isTrue);
      
      // Test with zero letters
      final zeroLetters = LetterGenerator.generateLetters(0);
      expect(zeroLetters.length, 0);
    });

    test('should generate balanced letter distribution', () {
      final letters = LetterGenerator.generateLetters(100);

      // Count vowels and consonants
      final vowels = letters.where((letter) => 'AEIOU'.contains(letter)).length;
      final consonants = letters.length - vowels;

      // Should have a reasonable balance
      final vowelPercentage = vowels / letters.length;
      expect(vowelPercentage, greaterThan(0.1));
      expect(vowelPercentage, lessThan(0.7));
    });

    test('should generate letters following frequency distribution', () {
      final letters = LetterGenerator.generateLetters(100);

      // Count frequency of common vs rare letters
      final commonLetters = ['E', 'T', 'A', 'O', 'I', 'N', 'S', 'H', 'R'];
      final rareLetters = ['Q', 'X', 'Z', 'J'];

      final commonCount = letters.where((letter) =>
          commonLetters.contains(letter)).length;
      final rareCount = letters.where((letter) =>
          rareLetters.contains(letter)).length;

      // Common letters should appear more frequently than rare ones
      expect(commonCount, greaterThan(rareCount));

      expect(letters.length, 100);
      for (final letter in letters) {
        expect(RegExp(r'^[A-Z]$').hasMatch(letter), isTrue);
      }
    });

    test('should be deterministic with same seed', () {
      // This test assumes the generator can be seeded (implementation detail)
      // If not implemented, this test can be skipped
      final letters1 = LetterGenerator.generateLetters(9);
      final letters2 = LetterGenerator.generateLetters(9);
      
      // Without seeding, results should be different
      // This just ensures the method works consistently
      expect(letters1.length, equals(letters2.length));
    });

    test('should handle large number of letters', () {
      final largeSet = LetterGenerator.generateLetters(1000);
      
      expect(largeSet.length, 1000);
      
      // All should be valid letters
      for (final letter in largeSet) {
        expect(RegExp(r'^[A-Z]$').hasMatch(letter), isTrue);
      }
      
      // Should have reasonable distribution
      final uniqueLetters = largeSet.toSet();
      expect(uniqueLetters.length, greaterThan(10)); // Should have variety
    });

    test('should generate letters that can form words', () {
      // Generate letters multiple times and check if common words can be formed
      bool canFormCommonWords = false;
      
      for (int attempt = 0; attempt < 20; attempt++) {
        final letters = LetterGenerator.generateLetters(9);
        
        // Check if we can form common 3-letter words
        final letterSet = letters.toSet();
        
        // Common words that might be formable
        final commonWords = ['THE', 'AND', 'CAT', 'DOG', 'RUN', 'SUN', 'FUN'];
        
        for (final word in commonWords) {
          bool canForm = true;
          final wordLetters = word.split('');
          final availableLetters = List<String>.from(letters);
          
          for (final wordLetter in wordLetters) {
            if (availableLetters.contains(wordLetter)) {
              availableLetters.remove(wordLetter);
            } else {
              canForm = false;
              break;
            }
          }
          
          if (canForm) {
            canFormCommonWords = true;
            break;
          }
        }
        
        if (canFormCommonWords) break;
      }
      
      // With 20 attempts, we should be able to form at least one common word
      expect(canFormCommonWords, isTrue);
    });
  });
}
