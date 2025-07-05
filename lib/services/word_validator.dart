import 'package:english_words/english_words.dart';

/// Service for validating words using english_words package
class WordValidator {
  // Use english_words package for comprehensive dictionary
  static Set<String>? _validWords;
  
  /// Initialize the word dictionary
  static Set<String> get validWords {
    if (_validWords == null) {
      _validWords = <String>{};
      
      // // Add all nouns (most common words)
      // _validWords!.addAll(nouns.map((word) => word.toUpperCase()));
      //
      // // Add common adjectives
      // _validWords!.addAll(adjectives.map((word) => word.toUpperCase()));

      _validWords!.addAll(all.map((word) => word.toUpperCase()));
    }
    
    return _validWords!;
  }

  /// Check if a word is valid
  static bool isValidWord(String word) {
    if (word.isEmpty) return false;
    return validWords.contains(word.toUpperCase());
  }

  /// Check if a word can be formed from the given letters
  static bool canFormWord(String word, List<String> availableLetters) {
    if (word.isEmpty) return false;
    
    final wordLetters = word.toUpperCase().split('');
    final letterCounts = <String, int>{};
    
    // Count available letters
    for (final letter in availableLetters) {
      letterCounts[letter.toUpperCase()] = (letterCounts[letter.toUpperCase()] ?? 0) + 1;
    }
    
    // Check if word can be formed
    for (final letter in wordLetters) {
      if ((letterCounts[letter] ?? 0) <= 0) {
        return false;
      }
      letterCounts[letter] = letterCounts[letter]! - 1;
    }
    
    return true;
  }

  /// Validate a word and return validation result
  static WordValidationResult validateWord(
    String word, 
    List<String> availableLetters,
    {int minLength = 3}
  ) {
    if (word.length < minLength) {
      return WordValidationResult(
        isValid: false,
        reason: 'Word must be at least $minLength letters long',
      );
    }
    
    if (!canFormWord(word, availableLetters)) {
      return WordValidationResult(
        isValid: false,
        reason: 'Cannot form word with available letters',
      );
    }
    
    if (!isValidWord(word)) {
      return WordValidationResult(
        isValid: false,
        reason: 'Word not found in dictionary',
      );
    }
    
    return WordValidationResult(isValid: true);
  }

  /// Get all possible words that can be formed from the given letters
  static List<String> findPossibleWords(
    List<String> availableLetters,
    {int minLength = 3, int maxLength = 10}
  ) {
    final possibleWords = <String>[];
    
    for (final word in validWords) {
      if (word.length >= minLength && 
          word.length <= maxLength && 
          canFormWord(word, availableLetters)) {
        possibleWords.add(word);
      }
    }
    
    return possibleWords;
  }

  /// Get letter frequency distribution for balanced game generation
  static Map<String, double> getLetterFrequency() {
    return {
      'A': 8.12, 'B': 1.49, 'C': 2.78, 'D': 4.25, 'E': 12.02, 'F': 2.23,
      'G': 2.02, 'H': 6.09, 'I': 6.97, 'J': 0.15, 'K': 0.77, 'L': 4.03,
      'M': 2.41, 'N': 6.75, 'O': 7.51, 'P': 1.93, 'Q': 0.10, 'R': 5.99,
      'S': 6.33, 'T': 9.06, 'U': 2.76, 'V': 0.98, 'W': 2.36, 'X': 0.15,
      'Y': 1.97, 'Z': 0.07,
    };
  }

  /// Get hint words for the game
  static List<String> getHintWords(
    List<String> availableLetters,
    List<String> alreadyFound,
    {int maxHints = 3, int minLength = 3, int maxLength = 10}
  ) {
    final possibleWords = findPossibleWords(
      availableLetters,
      minLength: minLength,
      maxLength: maxLength,
    );

    // Filter out already found words
    final hints = possibleWords
        .where((word) => !alreadyFound.contains(word.toUpperCase()))
        .take(maxHints)
        .toList();

    return hints;
  }
}

/// Result of word validation
class WordValidationResult {
  final bool isValid;
  final String? reason;

  const WordValidationResult({
    required this.isValid,
    this.reason,
  });
}
