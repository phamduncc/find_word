import 'lib/services/word_validator.dart';

void main() {
  // Test với các letters khác nhau
  print('=== Testing DONE validation ===');
  
  // Test 1: Có đủ letters
  List<String> letters1 = ['D', 'O', 'N', 'E', 'A', 'B', 'C', 'F'];
  var result1 = WordValidator.validateWord('DONE', letters1);
  print('Test 1 - Letters: $letters1');
  print('DONE validation: ${result1.isValid}, reason: ${result1.reason}');
  
  // Test 2: Thiếu letter
  List<String> letters2 = ['D', 'O', 'N', 'A', 'B', 'C', 'F'];
  var result2 = WordValidator.validateWord('DONE', letters2);
  print('\nTest 2 - Letters: $letters2');
  print('DONE validation: ${result2.isValid}, reason: ${result2.reason}');
  
  // Test 3: Có duplicate letters
  List<String> letters3 = ['D', 'O', 'N', 'E', 'D', 'O', 'N', 'E'];
  var result3 = WordValidator.validateWord('DONE', letters3);
  print('\nTest 3 - Letters: $letters3');
  print('DONE validation: ${result3.isValid}, reason: ${result3.reason}');
  
  // Test canFormWord directly
  print('\n=== Testing canFormWord directly ===');
  print('Can form DONE from $letters1: ${WordValidator.canFormWord('DONE', letters1)}');
  print('Can form DONE from $letters2: ${WordValidator.canFormWord('DONE', letters2)}');
  
  // Test isValidWord directly
  print('\n=== Testing isValidWord directly ===');
  print('DONE is valid word: ${WordValidator.isValidWord('DONE')}');
}
