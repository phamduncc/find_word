import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'models/game_session_test.dart' as game_session_tests;
import 'services/word_validator_test.dart' as word_validator_tests;
import 'services/letter_generator_test.dart' as letter_generator_tests;
import 'widgets/animated_letter_tile_test.dart' as animated_letter_tile_tests;
import 'integration/game_flow_test.dart' as game_flow_tests;

void main() {
  group('All Tests', () {
    group('Model Tests', () {
      game_session_tests.main();
    });

    group('Service Tests', () {
      word_validator_tests.main();
      letter_generator_tests.main();
    });

    group('Widget Tests', () {
      animated_letter_tile_tests.main();
    });

    group('Integration Tests', () {
      game_flow_tests.main();
    });
  });
}
