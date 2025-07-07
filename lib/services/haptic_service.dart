import 'package:flutter/services.dart';

/// Service for managing haptic feedback throughout the app
class HapticService {
  static bool _isEnabled = true;

  /// Initialize haptic service
  static Future<void> initialize() async {
    // Using basic Flutter haptic feedback only
    _isEnabled = true;
  }

  /// Enable or disable haptic feedback
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if haptic feedback is enabled
  static bool get isEnabled => _isEnabled;

  /// Light haptic feedback for UI interactions
  static Future<void> lightImpact() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Medium haptic feedback for moderate actions
  static Future<void> mediumImpact() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Heavy haptic feedback for strong actions
  static Future<void> heavyImpact() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Selection haptic feedback for UI selections
  static Future<void> selectionClick() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Ignore errors
    }
  }

  // Game-specific haptic feedback methods

  /// Haptic feedback for letter selection
  static Future<void> letterSelection() async {
    await lightImpact();
  }

  /// Haptic feedback for button presses
  static Future<void> buttonPress() async {
    await mediumImpact();
  }

  /// Haptic feedback for word found (varies by word length)
  static Future<void> wordFound(int wordLength) async {
    if (!_isEnabled) return;

    if (wordLength <= 3) {
      await lightImpact();
    } else if (wordLength <= 5) {
      await mediumImpact();
    } else {
      await heavyImpact();
    }
  }

  /// Haptic feedback for combo achievements
  static Future<void> comboAchieved(int comboLevel) async {
    if (!_isEnabled) return;

    // More intense feedback for higher combo levels
    if (comboLevel <= 2) {
      await mediumImpact();
    } else if (comboLevel <= 4) {
      await heavyImpact();
    } else {
      // Super combo - multiple pulses
      await heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await heavyImpact();
    }
  }

  /// Haptic feedback for achievement unlocked
  static Future<void> achievementUnlocked() async {
    if (!_isEnabled) return;

    // Special pattern for achievements
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }

  /// Haptic feedback for time bonus
  static Future<void> timeBonus(int bonusSeconds) async {
    if (!_isEnabled) return;

    // Quick pulse for time bonus
    if (bonusSeconds >= 10) {
      await heavyImpact();
    } else if (bonusSeconds >= 5) {
      await mediumImpact();
    } else {
      await lightImpact();
    }
  }

  /// Haptic feedback for errors
  static Future<void> error() async {
    if (!_isEnabled) return;

    // Double tap for errors
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
  }
}
