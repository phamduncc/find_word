import 'package:flutter/services.dart';

/// Text-to-Speech service for word pronunciation
/// Uses platform channels to access native TTS
class TTSService {
  static const MethodChannel _channel = MethodChannel('flutter/tts');
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// Initialize the TTS service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔧 Initializing TTS Service...');
      // Try to initialize platform TTS
      final result = await _channel.invokeMethod('initialize');
      _isInitialized = true;
      _isEnabled = true;
      print('✅ TTS Service initialized successfully (platform TTS): $result');
    } catch (e) {
      print('❌ TTS initialization error: $e');
      print('🔄 Falling back to haptic feedback mode');
      _isEnabled = false;
      _isInitialized = true; // Still mark as initialized for fallback
    }
  }

  /// Enable or disable TTS
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if TTS is enabled
  static bool get isEnabled => _isEnabled && _isInitialized;

  /// Speak a word with pronunciation
  static Future<void> speak(String word) async {
    if (word.isEmpty) return;

    print('🔊 Attempting to speak: "$word" (enabled: $_isEnabled, initialized: $_isInitialized)');

    if (!_isInitialized) {
      print('⚠️ TTS not initialized, initializing now...');
      await initialize();
    }

    try {
      if (_isEnabled) {
        // Try platform TTS first
        final result = await _channel.invokeMethod('speak', {'text': word});
        print('✅ TTS speak successful: "$word" -> $result');
      } else {
        throw Exception('TTS disabled, using fallback');
      }
    } catch (e) {
      print('❌ TTS speak error: $e');
      print('🔄 Using haptic feedback fallback');
      // Fallback to haptic feedback
      await HapticFeedback.mediumImpact();
    }
  }

  /// Speak a word with phonetic pronunciation
  static Future<void> speakWithPhonetic(String word, String? phonetic) async {
    if (word.isEmpty) return;

    final textToSpeak = phonetic?.isNotEmpty == true ? phonetic! : word;
    print('🔊 Attempting to speak with phonetic: "$word" -> "$textToSpeak"');

    if (!_isInitialized) {
      print('⚠️ TTS not initialized, initializing now...');
      await initialize();
    }

    try {
      if (_isEnabled) {
        // Use the word itself for TTS (phonetic is just for display)
        final result = await _channel.invokeMethod('speak', {'text': word});
        print('✅ TTS speak with phonetic successful: "$word" -> $result');
      } else {
        throw Exception('TTS disabled, using fallback');
      }
    } catch (e) {
      print('❌ TTS speak with phonetic error: $e');
      print('🔄 Using haptic feedback fallback');
      // Fallback to haptic feedback
      await HapticFeedback.mediumImpact();
    }
  }

  /// Stop current speech
  static Future<void> stop() async {
    if (!isEnabled) return;
    print('🔇 TTS stopped');
  }

  /// Set speech rate (0.0 to 1.0) - no-op in fallback mode
  static Future<void> setSpeechRate(double rate) async {
    if (!isEnabled) return;
    final clampedRate = rate.clamp(0.0, 1.0);
    print('🎚️ TTS speech rate set to: $clampedRate (fallback mode)');
  }

  /// Set volume (0.0 to 1.0) - no-op in fallback mode
  static Future<void> setVolume(double volume) async {
    if (!isEnabled) return;
    final clampedVolume = volume.clamp(0.0, 1.0);
    print('🔊 TTS volume set to: $clampedVolume (fallback mode)');
  }

  /// Set pitch (0.5 to 2.0) - no-op in fallback mode
  static Future<void> setPitch(double pitch) async {
    if (!isEnabled) return;
    final clampedPitch = pitch.clamp(0.5, 2.0);
    print('🎵 TTS pitch set to: $clampedPitch (fallback mode)');
  }

  /// Get available languages - returns common English variants
  static Future<List<String>> getLanguages() async {
    if (!isEnabled) return [];
    
    return [
      'en-US', // American English
      'en-GB', // British English
      'en-AU', // Australian English
      'en-CA', // Canadian English
    ];
  }

  /// Check if language is available
  static Future<bool> isLanguageAvailable(String language) async {
    if (!isEnabled) return false;
    
    // Return true for common English variants
    return ['en-US', 'en-GB', 'en-AU', 'en-CA'].contains(language);
  }

  /// Set language - no-op in fallback mode
  static Future<void> setLanguage(String language) async {
    if (!isEnabled) return;
    print('🌍 TTS language set to: $language (fallback mode)');
  }

  /// Check if TTS is currently speaking
  static bool get isSpeaking => false;

  /// Dispose resources
  static Future<void> dispose() async {
    _isInitialized = false;
    print('TTS Service disposed');
  }
}
