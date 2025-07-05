import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  GameSettings _settings = const GameSettings();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  GameSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Individual setting getters
  Difficulty get difficulty => _settings.difficulty;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  bool get showHints => _settings.showHints;
  String get playerName => _settings.playerName;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      _setLoading(true);
      _setError(null);

      _settings = StorageService.loadSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save settings to SharedPreferences
  Future<void> saveSettings() async {
    try {
      _setLoading(true);
      _setError(null);

      await StorageService.saveSettings(_settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to save settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update difficulty setting
  Future<void> updateDifficulty(Difficulty difficulty) async {
    _settings = _settings.copyWith(difficulty: difficulty);
    notifyListeners();
    await saveSettings();
  }

  /// Update sound enabled setting
  Future<void> updateSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    notifyListeners();
    await saveSettings();
  }

  /// Update vibration enabled setting
  Future<void> updateVibrationEnabled(bool enabled) async {
    _settings = _settings.copyWith(vibrationEnabled: enabled);
    notifyListeners();
    await saveSettings();
  }

  /// Update show hints setting
  Future<void> updateShowHints(bool enabled) async {
    _settings = _settings.copyWith(showHints: enabled);
    notifyListeners();
    await saveSettings();
  }

  /// Update player name
  Future<void> updatePlayerName(String name) async {
    _settings = _settings.copyWith(playerName: name.trim());
    notifyListeners();
    await saveSettings();
  }

  /// Update multiple settings at once
  Future<void> updateSettings(GameSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await saveSettings();
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    _settings = const GameSettings();
    notifyListeners();
    await saveSettings();
  }

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    try {
      return StorageService.isFirstLaunch();
    } catch (e) {
      return true;
    }
  }

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    try {
      await StorageService.markFirstLaunchComplete();
    } catch (e) {
      _setError('Failed to mark first launch: $e');
    }
  }

  /// Get time limit for current difficulty
  int get timeLimit => _settings.difficulty.timeLimit;

  /// Get letter count for current difficulty
  int get letterCount => _settings.difficulty.letterCount;

  /// Get minimum word length for current difficulty
  int get minWordLength => _settings.difficulty.minWordLength;

  /// Get display name for current difficulty
  String get difficultyDisplayName => _settings.difficulty.displayName;

  /// Get color for current difficulty
  String get difficultyColorHex => _settings.difficulty.colorHex;
}
