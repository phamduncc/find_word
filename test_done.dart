import 'lib/services/word_validator.dart';

void main() {
  print('Testing DONE validation:');
  print('DONE is valid: ${WordValidator.isValidWord('DONE')}');
  print('done is valid: ${WordValidator.isValidWord('done')}');
  print('Done is valid: ${WordValidator.isValidWord('Done')}');
}
