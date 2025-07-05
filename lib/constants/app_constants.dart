import 'package:flutter/material.dart';

/// Application constants
class AppConstants {
  // App Info
  static const String appName = 'Find Words';
  static const String appVersion = '1.0.0';
  
  // Game Constants
  static const int maxHighScores = 10;
  static const int defaultTimeLimit = 90; // seconds
  static const int minWordLength = 3;
  static const int maxWordLength = 15;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Grid
  static const int gridColumns = 3;
  static const double letterTileSize = 60.0;
  static const double letterTileSpacing = 8.0;
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Difficulty Colors
  static const Color easyColor = Color(0xFF4CAF50);
  static const Color mediumColor = Color(0xFFFF9800);
  static const Color hardColor = Color(0xFFF44336);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  // Letter Tile Styles
  static const TextStyle letterTileStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // Score Styles
  static const TextStyle scoreStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  // Timer Styles
  static const TextStyle timerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: errorColor,
  );
  
  // SharedPreferences Keys
  static const String keyHighScores = 'high_scores';
  static const String keyGameSettings = 'game_settings';
  static const String keyPlayerName = 'player_name';
  static const String keyFirstLaunch = 'first_launch';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  
  // Game Messages
  static const String msgWordTooShort = 'Word must be at least 3 letters long';
  static const String msgWordNotFound = 'Word not found in dictionary';
  static const String msgWordAlreadyFound = 'Word already found';
  static const String msgCannotFormWord = 'Cannot form word with available letters';
  static const String msgGamePaused = 'Game paused';
  static const String msgGameResumed = 'Game resumed';
  static const String msgGameFinished = 'Game finished!';
  static const String msgNewHighScore = 'New high score!';
  
  // Hints
  static const List<String> gameHints = [
    'Try to find shorter words first',
    'Look for common prefixes and suffixes',
    'Vowels are your friends - use them wisely',
    'Don\'t forget about plural forms',
    'Past tense words often work well',
  ];
  
  // Sound Effects (file names)
  static const String soundLetterSelect = 'letter_select.wav';
  static const String soundWordFound = 'word_found.wav';
  static const String soundWordInvalid = 'word_invalid.wav';
  static const String soundGameStart = 'game_start.wav';
  static const String soundGameEnd = 'game_end.wav';
  static const String soundHighScore = 'high_score.wav';
  static const String soundTick = 'tick.wav';
  
  // Achievements
  static const Map<String, String> achievements = {
    'first_word': 'First Word Found!',
    'speed_demon': 'Speed Demon - 10 words in 1 minute',
    'word_master': 'Word Master - 50 words in one game',
    'long_word': 'Long Word Expert - Found 8+ letter word',
    'perfect_game': 'Perfect Game - No invalid attempts',
  };
}

/// Theme-related constants
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppConstants.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppConstants.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
    );
  }
}
