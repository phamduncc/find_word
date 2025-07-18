import 'package:flutter/material.dart';
import 'dart:math';

/// Word theme categories
enum ThemeCategory {
  animals,
  food,
  colors,
  nature,
  sports,
  technology,
  travel,
  music,
  science,
  emotions,
  weather,
  clothing,
  vehicles,
  professions,
  hobbies,
}

/// Word theme configuration
class WordTheme {
  final ThemeCategory category;
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> keywords;
  final List<String> bonusWords;
  final int difficultyLevel;
  final bool isUnlocked;

  const WordTheme({
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.keywords,
    required this.bonusWords,
    this.difficultyLevel = 1,
    this.isUnlocked = true,
  });

  /// Create a copy with modified values
  WordTheme copyWith({
    ThemeCategory? category,
    String? name,
    String? description,
    IconData? icon,
    Color? primaryColor,
    Color? secondaryColor,
    List<String>? keywords,
    List<String>? bonusWords,
    int? difficultyLevel,
    bool? isUnlocked,
  }) {
    return WordTheme(
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      keywords: keywords ?? this.keywords,
      bonusWords: bonusWords ?? this.bonusWords,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  /// Check if a word belongs to this theme
  bool containsWord(String word) {
    final upperWord = word.toUpperCase();
    return keywords.contains(upperWord) || bonusWords.contains(upperWord);
  }

  /// Get bonus points for theme words
  int getBonusPoints(String word) {
    if (bonusWords.contains(word.toUpperCase())) {
      return 50; // Bonus words give extra points
    } else if (keywords.contains(word.toUpperCase())) {
      return 25; // Regular theme words give moderate bonus
    }
    return 0;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category.index,
      'difficultyLevel': difficultyLevel,
      'isUnlocked': isUnlocked,
    };
  }

  /// Create from JSON
  factory WordTheme.fromJson(Map<String, dynamic> json, ThemeCategory category) {
    final config = ThemeConfig.getTheme(category);
    return config.copyWith(
      difficultyLevel: json['difficultyLevel'] as int?,
      isUnlocked: json['isUnlocked'] as bool?,
    );
  }
}

/// Theme configuration data
class ThemeConfig {
  static WordTheme getTheme(ThemeCategory category) {
    switch (category) {
      case ThemeCategory.animals:
        return const WordTheme(
          category: ThemeCategory.animals,
          name: 'Animal Kingdom',
          description: 'Find words related to animals and wildlife',
          icon: Icons.pets,
          primaryColor: Colors.brown,
          secondaryColor: Colors.orange,
          keywords: ['CAT', 'DOG', 'BIRD', 'FISH', 'BEAR', 'LION', 'TIGER', 'WOLF', 'FOX', 'DEER'],
          bonusWords: ['ELEPHANT', 'GIRAFFE', 'PENGUIN', 'DOLPHIN', 'BUTTERFLY'],
          difficultyLevel: 1,
        );

      case ThemeCategory.food:
        return const WordTheme(
          category: ThemeCategory.food,
          name: 'Delicious Dishes',
          description: 'Discover words about food and cooking',
          icon: Icons.restaurant,
          primaryColor: Colors.red,
          secondaryColor: Colors.yellow,
          keywords: ['APPLE', 'BREAD', 'CAKE', 'FISH', 'MEAT', 'RICE', 'SOUP', 'MILK', 'EGG', 'CHEESE'],
          bonusWords: ['PIZZA', 'BURGER', 'SPAGHETTI', 'CHOCOLATE', 'SANDWICH'],
          difficultyLevel: 1,
        );

      case ThemeCategory.colors:
        return const WordTheme(
          category: ThemeCategory.colors,
          name: 'Rainbow Spectrum',
          description: 'Find words related to colors and shades',
          icon: Icons.palette,
          primaryColor: Colors.purple,
          secondaryColor: Colors.pink,
          keywords: ['RED', 'BLUE', 'GREEN', 'YELLOW', 'BLACK', 'WHITE', 'PINK', 'BROWN', 'GRAY', 'ORANGE'],
          bonusWords: ['VIOLET', 'CRIMSON', 'TURQUOISE', 'MAGENTA', 'INDIGO'],
          difficultyLevel: 1,
        );

      case ThemeCategory.nature:
        return const WordTheme(
          category: ThemeCategory.nature,
          name: 'Natural World',
          description: 'Explore words about nature and environment',
          icon: Icons.nature,
          primaryColor: Colors.green,
          secondaryColor: Colors.lightGreen,
          keywords: ['TREE', 'FLOWER', 'GRASS', 'ROCK', 'WATER', 'WIND', 'FIRE', 'EARTH', 'SKY', 'CLOUD'],
          bonusWords: ['MOUNTAIN', 'FOREST', 'OCEAN', 'RAINBOW', 'WATERFALL'],
          difficultyLevel: 2,
        );

      case ThemeCategory.sports:
        return const WordTheme(
          category: ThemeCategory.sports,
          name: 'Sports Arena',
          description: 'Find words related to sports and games',
          icon: Icons.sports_soccer,
          primaryColor: Colors.blue,
          secondaryColor: Colors.lightBlue,
          keywords: ['BALL', 'GAME', 'TEAM', 'WIN', 'PLAY', 'RUN', 'JUMP', 'KICK', 'THROW', 'CATCH'],
          bonusWords: ['FOOTBALL', 'BASKETBALL', 'TENNIS', 'SWIMMING', 'BASEBALL'],
          difficultyLevel: 2,
        );

      case ThemeCategory.technology:
        return const WordTheme(
          category: ThemeCategory.technology,
          name: 'Digital Age',
          description: 'Discover words about technology and computers',
          icon: Icons.computer,
          primaryColor: Colors.indigo,
          secondaryColor: Colors.cyan,
          keywords: ['PHONE', 'COMPUTER', 'INTERNET', 'EMAIL', 'CODE', 'DATA', 'WIFI', 'APP', 'GAME', 'TECH'],
          bonusWords: ['SMARTPHONE', 'ARTIFICIAL', 'INTELLIGENCE', 'PROGRAMMING', 'DIGITAL'],
          difficultyLevel: 3,
        );

      case ThemeCategory.travel:
        return const WordTheme(
          category: ThemeCategory.travel,
          name: 'World Explorer',
          description: 'Find words related to travel and places',
          icon: Icons.flight,
          primaryColor: Colors.teal,
          secondaryColor: Colors.lightBlue,
          keywords: ['TRIP', 'HOTEL', 'PLANE', 'TRAIN', 'CAR', 'ROAD', 'MAP', 'CITY', 'BEACH', 'MOUNTAIN'],
          bonusWords: ['VACATION', 'PASSPORT', 'LUGGAGE', 'ADVENTURE', 'DESTINATION'],
          difficultyLevel: 2,
        );

      case ThemeCategory.music:
        return const WordTheme(
          category: ThemeCategory.music,
          name: 'Musical Notes',
          description: 'Explore words about music and instruments',
          icon: Icons.music_note,
          primaryColor: Colors.deepPurple,
          secondaryColor: Colors.purple,
          keywords: ['SONG', 'MUSIC', 'PIANO', 'GUITAR', 'DRUM', 'VOICE', 'BEAT', 'TUNE', 'SOUND', 'NOTE'],
          bonusWords: ['ORCHESTRA', 'SYMPHONY', 'MELODY', 'HARMONY', 'RHYTHM'],
          difficultyLevel: 2,
        );

      case ThemeCategory.science:
        return const WordTheme(
          category: ThemeCategory.science,
          name: 'Scientific Discovery',
          description: 'Find words related to science and research',
          icon: Icons.science,
          primaryColor: Colors.green,
          secondaryColor: Colors.lime,
          keywords: ['ATOM', 'CELL', 'DNA', 'GENE', 'SPACE', 'STAR', 'PLANET', 'ENERGY', 'FORCE', 'MATTER'],
          bonusWords: ['MOLECULE', 'CHEMISTRY', 'PHYSICS', 'BIOLOGY', 'EXPERIMENT'],
          difficultyLevel: 3,
        );

      case ThemeCategory.emotions:
        return const WordTheme(
          category: ThemeCategory.emotions,
          name: 'Feelings & Emotions',
          description: 'Discover words about feelings and emotions',
          icon: Icons.favorite,
          primaryColor: Colors.pink,
          secondaryColor: Colors.red,
          keywords: ['HAPPY', 'SAD', 'ANGRY', 'LOVE', 'FEAR', 'JOY', 'HOPE', 'CALM', 'EXCITED', 'PROUD'],
          bonusWords: ['HAPPINESS', 'SADNESS', 'EXCITEMENT', 'PEACEFUL', 'GRATEFUL'],
          difficultyLevel: 2,
        );

      case ThemeCategory.weather:
        return const WordTheme(
          category: ThemeCategory.weather,
          name: 'Weather Patterns',
          description: 'Find words related to weather and climate',
          icon: Icons.wb_sunny,
          primaryColor: Colors.amber,
          secondaryColor: Colors.orange,
          keywords: ['SUN', 'RAIN', 'SNOW', 'WIND', 'CLOUD', 'STORM', 'HOT', 'COLD', 'WARM', 'COOL'],
          bonusWords: ['THUNDER', 'LIGHTNING', 'HURRICANE', 'TORNADO', 'BLIZZARD'],
          difficultyLevel: 2,
        );

      case ThemeCategory.clothing:
        return const WordTheme(
          category: ThemeCategory.clothing,
          name: 'Fashion & Style',
          description: 'Explore words about clothing and fashion',
          icon: Icons.checkroom,
          primaryColor: Colors.purple,
          secondaryColor: Colors.deepPurple,
          keywords: ['SHIRT', 'PANTS', 'DRESS', 'SHOES', 'HAT', 'COAT', 'SOCKS', 'BELT', 'GLOVES', 'SCARF'],
          bonusWords: ['SWEATER', 'JACKET', 'SNEAKERS', 'FASHION', 'ELEGANT'],
          difficultyLevel: 1,
        );

      case ThemeCategory.vehicles:
        return const WordTheme(
          category: ThemeCategory.vehicles,
          name: 'Transportation',
          description: 'Find words related to vehicles and transport',
          icon: Icons.directions_car,
          primaryColor: Colors.blue,
          secondaryColor: Colors.indigo,
          keywords: ['CAR', 'BUS', 'TRAIN', 'PLANE', 'BIKE', 'BOAT', 'SHIP', 'TRUCK', 'TAXI', 'METRO'],
          bonusWords: ['MOTORCYCLE', 'HELICOPTER', 'SUBMARINE', 'AIRPLANE', 'VEHICLE'],
          difficultyLevel: 2,
        );

      case ThemeCategory.professions:
        return const WordTheme(
          category: ThemeCategory.professions,
          name: 'Career Paths',
          description: 'Discover words about jobs and professions',
          icon: Icons.work,
          primaryColor: Colors.brown,
          secondaryColor: Colors.amber,
          keywords: ['DOCTOR', 'TEACHER', 'NURSE', 'CHEF', 'ARTIST', 'WRITER', 'LAWYER', 'PILOT', 'FARMER', 'BUILDER'],
          bonusWords: ['ENGINEER', 'SCIENTIST', 'PROGRAMMER', 'DESIGNER', 'MUSICIAN'],
          difficultyLevel: 3,
        );

      case ThemeCategory.hobbies:
        return const WordTheme(
          category: ThemeCategory.hobbies,
          name: 'Fun Activities',
          description: 'Find words related to hobbies and activities',
          icon: Icons.sports_esports,
          primaryColor: Colors.orange,
          secondaryColor: Colors.deepOrange,
          keywords: ['READ', 'DRAW', 'PAINT', 'DANCE', 'SING', 'COOK', 'GARDEN', 'PHOTO', 'CRAFT', 'COLLECT'],
          bonusWords: ['PHOTOGRAPHY', 'PAINTING', 'GARDENING', 'COLLECTING', 'DANCING'],
          difficultyLevel: 2,
        );
    }
  }

  /// Get all available themes
  static List<WordTheme> getAllThemes() {
    return ThemeCategory.values.map((category) => getTheme(category)).toList();
  }

  /// Get random theme
  static WordTheme getRandomTheme() {
    final themes = getAllThemes();
    final random = Random();
    return themes[random.nextInt(themes.length)];
  }

  /// Get themes by difficulty level
  static List<WordTheme> getThemesByDifficulty(int level) {
    return getAllThemes().where((theme) => theme.difficultyLevel == level).toList();
  }
}
