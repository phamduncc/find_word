import 'lib/services/word_validator.dart';

void main() {
  print('=== Testing english_words package ===');
  
  // Test DONE validation
  List<String> letters = ['D', 'O', 'N', 'E', 'A', 'B', 'C', 'F'];
  var result = WordValidator.validateWord('DONE', letters);
  print('DONE validation: ${result.isValid}, reason: ${result.reason}');
  
  // Test isValidWord directly
  print('DONE is valid word: ${WordValidator.isValidWord('DONE')}');
  print('CAT is valid word: ${WordValidator.isValidWord('CAT')}');
  print('HOUSE is valid word: ${WordValidator.isValidWord('HOUSE')}');
  print('XYZZZ is valid word: ${WordValidator.isValidWord('XYZZZ')}');
  
  // Test dictionary size
  print('Total words in dictionary: ${WordValidator.validWords.length}');
  
  // Test some words from english_words package
  print('APPLE is valid: ${WordValidator.isValidWord('APPLE')}');
  print('COMPUTER is valid: ${WordValidator.isValidWord('COMPUTER')}');
}
