import 'package:flutter_test/flutter_test.dart';
import 'package:find_words/services/services.dart';

void main() {
  group('WordValidator', () {
    test('should validate common English words correctly', () {
      expect(WordValidator.isValidWord('CAT'), isTrue);
      expect(WordValidator.isValidWord('DOG'), isTrue);
      expect(WordValidator.isValidWord('THAT'), isTrue);
      expect(WordValidator.isValidWord('WITH'), isTrue);
      expect(WordValidator.isValidWord('HAVE'), isTrue);
    });

    test('should reject invalid words', () {
      expect(WordValidator.isValidWord('XYZ'), isFalse);
      expect(WordValidator.isValidWord('QWERTY'), isFalse);
      expect(WordValidator.isValidWord('ASDFGH'), isFalse);
      expect(WordValidator.isValidWord('ZXCVBN'), isFalse);
    });

    test('should handle case insensitivity', () {
      expect(WordValidator.isValidWord('cat'), isTrue);
      expect(WordValidator.isValidWord('Cat'), isTrue);
      expect(WordValidator.isValidWord('CAT'), isTrue);
      expect(WordValidator.isValidWord('cAt'), isTrue);
    });

    test('should reject words that are too short', () {
      expect(WordValidator.isValidWord('A'), isFalse);
      expect(WordValidator.isValidWord('AB'), isFalse);
      expect(WordValidator.isValidWord('I'), isFalse);
      expect(WordValidator.isValidWord('GO'), isFalse);
    });

    test('should accept minimum length words', () {
      expect(WordValidator.isValidWord('THE'), isTrue);
      expect(WordValidator.isValidWord('AND'), isTrue);
      expect(WordValidator.isValidWord('FOR'), isTrue);
      expect(WordValidator.isValidWord('ARE'), isTrue);
    });

    test('should reject empty or null words', () {
      expect(WordValidator.isValidWord(''), isFalse);
      expect(WordValidator.isValidWord('   '), isFalse);
    });

    test('should handle words with special characters', () {
      expect(WordValidator.isValidWord('CAT!'), isFalse);
      expect(WordValidator.isValidWord('DOG123'), isFalse);
      expect(WordValidator.isValidWord('HOUSE-'), isFalse);
      expect(WordValidator.isValidWord('COMPUTER.'), isFalse);
    });

    test('should validate words from different categories', () {
      // Common nouns
      expect(WordValidator.isValidWord('BOOK'), isTrue);
      expect(WordValidator.isValidWord('TABLE'), isTrue);
      expect(WordValidator.isValidWord('CHAIR'), isTrue);
      
      // Verbs
      expect(WordValidator.isValidWord('RUN'), isTrue);
      expect(WordValidator.isValidWord('WALK'), isTrue);
      expect(WordValidator.isValidWord('JUMP'), isTrue);
      
      // Adjectives
      expect(WordValidator.isValidWord('BIG'), isTrue);
      expect(WordValidator.isValidWord('SMALL'), isTrue);
      expect(WordValidator.isValidWord('FAST'), isTrue);
    });

    test('should handle long words correctly', () {
      expect(WordValidator.isValidWord('COMPUTER'), isTrue);
      expect(WordValidator.isValidWord('BEAUTIFUL'), isTrue);
      expect(WordValidator.isValidWord('IMPORTANT'), isTrue);
      expect(WordValidator.isValidWord('ABCDEFGHIJKLMNOP'), isFalse);
    });

    test('should validate plural forms', () {
      expect(WordValidator.isValidWord('CATS'), isTrue);
      expect(WordValidator.isValidWord('DOGS'), isTrue);
      expect(WordValidator.isValidWord('HOUSES'), isTrue);
      expect(WordValidator.isValidWord('BOOKS'), isTrue);
    });

    test('should validate past tense forms', () {
      expect(WordValidator.isValidWord('WALKED'), isTrue);
      expect(WordValidator.isValidWord('JUMPED'), isTrue);
      expect(WordValidator.isValidWord('PLAYED'), isTrue);
      expect(WordValidator.isValidWord('WORKED'), isTrue);
    });

    test('should validate comparative forms', () {
      expect(WordValidator.isValidWord('BIGGER'), isTrue);
      expect(WordValidator.isValidWord('SMALLER'), isTrue);
      expect(WordValidator.isValidWord('FASTER'), isTrue);
      expect(WordValidator.isValidWord('SLOWER'), isTrue);
    });

    test('should validate superlative forms', () {
      expect(WordValidator.isValidWord('BIGGEST'), isTrue);
      expect(WordValidator.isValidWord('SMALLEST'), isTrue);
      expect(WordValidator.isValidWord('FASTEST'), isTrue);
      expect(WordValidator.isValidWord('SLOWEST'), isTrue);
    });

    test('should handle contractions correctly', () {
      // Most word games don't accept contractions
      expect(WordValidator.isValidWord("CAN'T"), isFalse);
      expect(WordValidator.isValidWord("WON'T"), isFalse);
      expect(WordValidator.isValidWord("DON'T"), isFalse);
      expect(WordValidator.isValidWord("ISN'T"), isFalse);
    });

    test('should validate common short words', () {
      expect(WordValidator.isValidWord('THE'), isTrue);
      expect(WordValidator.isValidWord('AND'), isTrue);
      expect(WordValidator.isValidWord('FOR'), isTrue);
      expect(WordValidator.isValidWord('ARE'), isTrue);
      expect(WordValidator.isValidWord('BUT'), isTrue);
      expect(WordValidator.isValidWord('NOT'), isTrue);
      expect(WordValidator.isValidWord('YOU'), isTrue);
      expect(WordValidator.isValidWord('ALL'), isTrue);
      expect(WordValidator.isValidWord('CAN'), isTrue);
      expect(WordValidator.isValidWord('HER'), isTrue);
      expect(WordValidator.isValidWord('WAS'), isTrue);
      expect(WordValidator.isValidWord('ONE'), isTrue);
      expect(WordValidator.isValidWord('OUR'), isTrue);
      expect(WordValidator.isValidWord('OUT'), isTrue);
      expect(WordValidator.isValidWord('DAY'), isTrue);
      expect(WordValidator.isValidWord('GET'), isTrue);
      expect(WordValidator.isValidWord('HAS'), isTrue);
      expect(WordValidator.isValidWord('HIM'), isTrue);
      expect(WordValidator.isValidWord('HIS'), isTrue);
      expect(WordValidator.isValidWord('HOW'), isTrue);
      expect(WordValidator.isValidWord('ITS'), isTrue);
      expect(WordValidator.isValidWord('MAY'), isTrue);
      expect(WordValidator.isValidWord('NEW'), isTrue);
      expect(WordValidator.isValidWord('NOW'), isTrue);
      expect(WordValidator.isValidWord('OLD'), isTrue);
      expect(WordValidator.isValidWord('SEE'), isTrue);
      expect(WordValidator.isValidWord('TWO'), isTrue);
      expect(WordValidator.isValidWord('WAY'), isTrue);
      expect(WordValidator.isValidWord('WHO'), isTrue);
      expect(WordValidator.isValidWord('BOY'), isTrue);
      expect(WordValidator.isValidWord('DID'), isTrue);
      expect(WordValidator.isValidWord('END'), isTrue);
      expect(WordValidator.isValidWord('FEW'), isTrue);
      expect(WordValidator.isValidWord('GOT'), isTrue);
      expect(WordValidator.isValidWord('LET'), isTrue);
      expect(WordValidator.isValidWord('MAN'), isTrue);
      expect(WordValidator.isValidWord('PUT'), isTrue);
      expect(WordValidator.isValidWord('SAY'), isTrue);
      expect(WordValidator.isValidWord('SHE'), isTrue);
      expect(WordValidator.isValidWord('TOO'), isTrue);
      expect(WordValidator.isValidWord('USE'), isTrue);
    });

    test('should reject nonsense combinations', () {
      expect(WordValidator.isValidWord('QQQ'), isFalse);
      expect(WordValidator.isValidWord('XXX'), isFalse);
      expect(WordValidator.isValidWord('ZZZ'), isFalse);
      expect(WordValidator.isValidWord('QXZQXZ'), isFalse);
      expect(WordValidator.isValidWord('ZZXXQQ'), isFalse);
    });

    test('should handle performance with many validations', () {
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        WordValidator.isValidWord('CAT');
        WordValidator.isValidWord('DOG');
        WordValidator.isValidWord('HOUSE');
        WordValidator.isValidWord('XYZ');
      }
      
      stopwatch.stop();
      
      // Should complete 4000 validations in reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
