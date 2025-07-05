import 'dart:math' as math;

/// Service for generating random letters for the game
class LetterGenerator {
  static final math.Random _random = math.Random();

  /// English letter frequency distribution (approximate)
  /// Based on common English text analysis
  static const Map<String, double> _letterFrequency = {
    'A': 8.12, 'B': 1.49, 'C': 2.78, 'D': 4.25, 'E': 12.02,
    'F': 2.23, 'G': 2.02, 'H': 6.09, 'I': 6.97, 'J': 0.15,
    'K': 0.77, 'L': 4.03, 'M': 2.41, 'N': 6.75, 'O': 7.51,
    'P': 1.93, 'Q': 0.10, 'R': 5.99, 'S': 6.33, 'T': 9.06,
    'U': 2.76, 'V': 0.98, 'W': 2.36, 'X': 0.15, 'Y': 1.97,
    'Z': 0.07,
  };

  /// Vowels for ensuring playability
  static const List<String> _vowels = ['A', 'E', 'I', 'O', 'U'];
  
  /// Common consonants
  static const List<String> _commonConsonants = [
    'R', 'S', 'T', 'L', 'N', 'C', 'H', 'D', 'P', 'M', 'B', 'F', 'G'
  ];

  /// Generate a list of random letters with good distribution
  static List<String> generateLetters(int count) {
    if (count <= 0) return [];

    final letters = <String>[];
    
    // Ensure at least some vowels for playability
    final minVowels = count <= 3 ? 1 : 2;
    final maxVowels = math.max(count ~/ 2, minVowels);
    final vowelCount = (count * 0.3).round().clamp(minVowels, maxVowels);
    
    // Add vowels
    for (int i = 0; i < vowelCount; i++) {
      letters.add(_vowels[_random.nextInt(_vowels.length)]);
    }
    
    // Fill remaining with consonants using frequency distribution
    final remainingCount = count - vowelCount;
    for (int i = 0; i < remainingCount; i++) {
      letters.add(_getRandomConsonant());
    }
    
    // Shuffle the letters
    letters.shuffle(_random);
    
    return letters;
  }

  /// Generate letters ensuring at least one possible word exists
  static List<String> generatePlayableLetters(int count) {
    List<String> letters;
    int attempts = 0;
    const maxAttempts = 10;
    
    do {
      letters = generateLetters(count);
      attempts++;
    } while (attempts < maxAttempts && !_hasMinimumPlayability(letters));
    
    return letters;
  }

  /// Get a random consonant based on frequency
  static String _getRandomConsonant() {
    final consonants = _letterFrequency.keys
        .where((letter) => !_vowels.contains(letter))
        .toList();
    
    // Use weighted random selection based on frequency
    final totalWeight = consonants
        .map((letter) => _letterFrequency[letter]!)
        .reduce((a, b) => a + b);
    
    final randomValue = _random.nextDouble() * totalWeight;
    double currentWeight = 0;
    
    for (final letter in consonants) {
      currentWeight += _letterFrequency[letter]!;
      if (randomValue <= currentWeight) {
        return letter;
      }
    }
    
    // Fallback to random common consonant
    return _commonConsonants[_random.nextInt(_commonConsonants.length)];
  }

  /// Check if the letter set has minimum playability
  static bool _hasMinimumPlayability(List<String> letters) {
    // Check for at least 2 vowels
    final vowelCount = letters.where((letter) => _vowels.contains(letter)).length;
    if (vowelCount < 2) return false;
    
    // Check for common letter combinations
    final letterSet = letters.toSet();
    
    // Common 3-letter combinations that often form words
    final commonCombinations = [
      ['T', 'H', 'E'],
      ['A', 'N', 'D'],
      ['T', 'H', 'A'],
      ['E', 'R', 'S'],
      ['H', 'A', 'S'],
      ['H', 'I', 'S'],
      ['T', 'H', 'I'],
      ['F', 'O', 'R'],
      ['A', 'R', 'E'],
      ['W', 'I', 'T'],
    ];
    
    // Check if we have at least one common combination
    for (final combo in commonCombinations) {
      if (combo.every((letter) => letterSet.contains(letter))) {
        return true;
      }
    }
    
    return false;
  }

  /// Generate letters with a specific theme or pattern
  static List<String> generateThemedLetters(int count, {String? theme}) {
    switch (theme?.toLowerCase()) {
      case 'vowel_heavy':
        return _generateVowelHeavyLetters(count);
      case 'consonant_heavy':
        return _generateConsonantHeavyLetters(count);
      default:
        return generatePlayableLetters(count);
    }
  }

  /// Generate letters with more vowels
  static List<String> _generateVowelHeavyLetters(int count) {
    final letters = <String>[];
    final vowelCount = (count * 0.5).round();
    
    // Add vowels
    for (int i = 0; i < vowelCount; i++) {
      letters.add(_vowels[_random.nextInt(_vowels.length)]);
    }
    
    // Add consonants
    for (int i = vowelCount; i < count; i++) {
      letters.add(_getRandomConsonant());
    }
    
    letters.shuffle(_random);
    return letters;
  }

  /// Generate letters with more consonants
  static List<String> _generateConsonantHeavyLetters(int count) {
    final letters = <String>[];
    final vowelCount = (count * 0.2).round().clamp(1, count - 1);
    
    // Add minimum vowels
    for (int i = 0; i < vowelCount; i++) {
      letters.add(_vowels[_random.nextInt(_vowels.length)]);
    }
    
    // Add consonants
    for (int i = vowelCount; i < count; i++) {
      letters.add(_getRandomConsonant());
    }
    
    letters.shuffle(_random);
    return letters;
  }

  /// Get letter distribution statistics
  static Map<String, int> getLetterDistribution(List<String> letters) {
    final distribution = <String, int>{};
    for (final letter in letters) {
      distribution[letter] = (distribution[letter] ?? 0) + 1;
    }
    return distribution;
  }
}
