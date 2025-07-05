import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum SoundEffect {
  letterSelect,
  letterDeselect,
  wordFound,
  wordInvalid,
  gameStart,
  gameEnd,
  buttonTap,
  timerTick,
  timerUrgent,
  achievement,
}

class SoundService {
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// Initialize the sound service
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Initialize any sound system here if needed
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize sound service: $e');
      }
    }
  }

  /// Enable or disable sound effects
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if sound is enabled
  static bool get isEnabled => _isEnabled;

  /// Play a sound effect
  static Future<void> playSound(SoundEffect effect) async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      // For now, we'll use system sounds and haptic feedback
      // In a real app, you would use a package like audioplayers
      switch (effect) {
        case SoundEffect.letterSelect:
          await _playSystemSound();
          break;
        case SoundEffect.letterDeselect:
          await _playSystemSound();
          break;
        case SoundEffect.wordFound:
          await _playSuccessSound();
          break;
        case SoundEffect.wordInvalid:
          await _playErrorSound();
          break;
        case SoundEffect.gameStart:
          await _playSystemSound();
          break;
        case SoundEffect.gameEnd:
          await _playSystemSound();
          break;
        case SoundEffect.buttonTap:
          await _playSystemSound();
          break;
        case SoundEffect.timerTick:
          await _playSystemSound();
          break;
        case SoundEffect.timerUrgent:
          await _playErrorSound();
          break;
        case SoundEffect.achievement:
          await _playSuccessSound();
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play sound effect $effect: $e');
      }
    }
  }

  /// Play letter selection sound
  static Future<void> playLetterSelect() async {
    await playSound(SoundEffect.letterSelect);
  }

  /// Play letter deselection sound
  static Future<void> playLetterDeselect() async {
    await playSound(SoundEffect.letterDeselect);
  }

  /// Play word found sound
  static Future<void> playWordFound() async {
    await playSound(SoundEffect.wordFound);
  }

  /// Play word invalid sound
  static Future<void> playWordInvalid() async {
    await playSound(SoundEffect.wordInvalid);
  }

  /// Play game start sound
  static Future<void> playGameStart() async {
    await playSound(SoundEffect.gameStart);
  }

  /// Play game end sound
  static Future<void> playGameEnd() async {
    await playSound(SoundEffect.gameEnd);
  }

  /// Play button tap sound
  static Future<void> playButtonTap() async {
    await playSound(SoundEffect.buttonTap);
  }

  /// Play timer tick sound
  static Future<void> playTimerTick() async {
    await playSound(SoundEffect.timerTick);
  }

  /// Play timer urgent sound
  static Future<void> playTimerUrgent() async {
    await playSound(SoundEffect.timerUrgent);
  }

  /// Play achievement sound
  static Future<void> playAchievement() async {
    await playSound(SoundEffect.achievement);
  }

  // Private helper methods for different sound types
  static Future<void> _playSystemSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play system sound: $e');
      }
    }
  }

  static Future<void> _playSuccessSound() async {
    try {
      // Use a different system sound for success
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play success sound: $e');
      }
    }
  }

  static Future<void> _playErrorSound() async {
    try {
      // Use a different system sound for errors
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play error sound: $e');
      }
    }
  }

  /// Dispose of resources
  static void dispose() {
    _isInitialized = false;
  }
}

class HapticService {
  static bool _isEnabled = true;

  /// Enable or disable haptic feedback
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if haptic feedback is enabled
  static bool get isEnabled => _isEnabled;

  /// Light haptic feedback
  static Future<void> lightImpact() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to provide light haptic feedback: $e');
      }
    }
  }

  /// Medium haptic feedback
  static Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to provide medium haptic feedback: $e');
      }
    }
  }

  /// Heavy haptic feedback
  static Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to provide heavy haptic feedback: $e');
      }
    }
  }

  /// Selection haptic feedback
  static Future<void> selectionClick() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to provide selection haptic feedback: $e');
      }
    }
  }

  /// Vibrate for notifications
  static Future<void> vibrate() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to vibrate: $e');
      }
    }
  }

  /// Haptic feedback for letter selection
  static Future<void> letterSelect() async {
    await lightImpact();
  }

  /// Haptic feedback for word found
  static Future<void> wordFound() async {
    await mediumImpact();
  }

  /// Haptic feedback for word invalid
  static Future<void> wordInvalid() async {
    await heavyImpact();
  }

  /// Haptic feedback for button tap
  static Future<void> buttonTap() async {
    await selectionClick();
  }

  /// Haptic feedback for game events
  static Future<void> gameEvent() async {
    await mediumImpact();
  }
}
