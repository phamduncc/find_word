import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper functions for setting up tests
class TestHelpers {
  /// Initialize SharedPreferences for tests
  static Future<void> initializeSharedPreferences() async {
    // Set up fake shared preferences for testing
    SharedPreferences.setMockInitialValues({});
  }

  /// Clear all test data
  static Future<void> clearTestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
