import 'package:flutter/material.dart';

/// Types of power-ups available in the game
enum PowerUpType {
  timeFreeze,     // Freeze timer for 10 seconds
  extraTime,      // Add 30 seconds to timer
  wordHint,       // Reveal a valid word
  letterShuffle,  // Shuffle letters for new combinations
  doublePoints,   // 2x points for next 3 words
  comboBoost,     // Start with combo level 2
  clearMistakes,  // Remove invalid attempt penalties
  xrayVision,     // Highlight possible word patterns
}

/// Power-up configuration and state
class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int cost;           // Cost in coins/points
  final int duration;       // Duration in seconds (0 = instant)
  final int quantity;       // How many player owns
  final bool isActive;      // Currently active in game
  final DateTime? activatedAt;
  final int? remainingTime; // Remaining time if active

  const PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.cost,
    required this.duration,
    this.quantity = 0,
    this.isActive = false,
    this.activatedAt,
    this.remainingTime,
  });

  /// Create a copy with modified values
  PowerUp copyWith({
    PowerUpType? type,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    int? cost,
    int? duration,
    int? quantity,
    bool? isActive,
    DateTime? activatedAt,
    int? remainingTime,
  }) {
    return PowerUp(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      cost: cost ?? this.cost,
      duration: duration ?? this.duration,
      quantity: quantity ?? this.quantity,
      isActive: isActive ?? this.isActive,
      activatedAt: activatedAt ?? this.activatedAt,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  /// Check if power-up can be used
  bool get canUse => quantity > 0 && !isActive;

  /// Check if power-up has expired
  bool get hasExpired {
    if (!isActive || activatedAt == null || duration == 0) return false;
    final elapsed = DateTime.now().difference(activatedAt!).inSeconds;
    return elapsed >= duration;
  }

  /// Get remaining duration in seconds
  int get remainingDuration {
    if (!isActive || activatedAt == null || duration == 0) return 0;
    final elapsed = DateTime.now().difference(activatedAt!).inSeconds;
    return (duration - elapsed).clamp(0, duration);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'quantity': quantity,
      'isActive': isActive,
      'activatedAt': activatedAt?.toIso8601String(),
      'remainingTime': remainingTime,
    };
  }

  /// Create from JSON
  factory PowerUp.fromJson(Map<String, dynamic> json, PowerUpType type) {
    final config = PowerUpConfig.getConfig(type);
    return PowerUp(
      type: type,
      name: config.name,
      description: config.description,
      icon: config.icon,
      color: config.color,
      cost: config.cost,
      duration: config.duration,
      quantity: json['quantity'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      activatedAt: json['activatedAt'] != null 
          ? DateTime.parse(json['activatedAt'] as String)
          : null,
      remainingTime: json['remainingTime'] as int?,
    );
  }
}

/// Power-up configuration data
class PowerUpConfig {
  static PowerUp getConfig(PowerUpType type) {
    switch (type) {
      case PowerUpType.timeFreeze:
        return const PowerUp(
          type: PowerUpType.timeFreeze,
          name: 'Time Freeze',
          description: 'Freeze the timer for 10 seconds',
          icon: Icons.pause_circle,
          color: Colors.blue,
          cost: 50,
          duration: 10,
        );
        
      case PowerUpType.extraTime:
        return const PowerUp(
          type: PowerUpType.extraTime,
          name: 'Extra Time',
          description: 'Add 30 seconds to the timer',
          icon: Icons.access_time,
          color: Colors.green,
          cost: 75,
          duration: 0, // Instant effect
        );
        
      case PowerUpType.wordHint:
        return const PowerUp(
          type: PowerUpType.wordHint,
          name: 'Word Hint',
          description: 'Reveal a valid word you can make',
          icon: Icons.lightbulb,
          color: Colors.yellow,
          cost: 30,
          duration: 0,
        );
        
      case PowerUpType.letterShuffle:
        return const PowerUp(
          type: PowerUpType.letterShuffle,
          name: 'Letter Shuffle',
          description: 'Shuffle letters for new combinations',
          icon: Icons.shuffle,
          color: Colors.purple,
          cost: 25,
          duration: 0,
        );
        
      case PowerUpType.doublePoints:
        return const PowerUp(
          type: PowerUpType.doublePoints,
          name: 'Double Points',
          description: '2x points for the next 3 words',
          icon: Icons.star,
          color: Colors.orange,
          cost: 100,
          duration: 60, // Lasts until 3 words or 60 seconds
        );
        
      case PowerUpType.comboBoost:
        return const PowerUp(
          type: PowerUpType.comboBoost,
          name: 'Combo Boost',
          description: 'Start your next combo at level 2',
          icon: Icons.trending_up,
          color: Colors.red,
          cost: 80,
          duration: 30,
        );
        
      case PowerUpType.clearMistakes:
        return const PowerUp(
          type: PowerUpType.clearMistakes,
          name: 'Clear Mistakes',
          description: 'Remove penalty from invalid attempts',
          icon: Icons.refresh,
          color: Colors.teal,
          cost: 40,
          duration: 0,
        );
        
      case PowerUpType.xrayVision:
        return const PowerUp(
          type: PowerUpType.xrayVision,
          name: 'X-Ray Vision',
          description: 'Highlight possible word patterns',
          icon: Icons.visibility,
          color: Colors.indigo,
          cost: 120,
          duration: 15,
        );
    }
  }

  /// Get all available power-ups with default quantities
  static List<PowerUp> getAllPowerUps() {
    return PowerUpType.values.map((type) => getConfig(type)).toList();
  }
}

/// Power-up effect data
class PowerUpEffect {
  final PowerUpType type;
  final Map<String, dynamic> data;
  final DateTime appliedAt;
  final bool isConsumed;

  const PowerUpEffect({
    required this.type,
    required this.data,
    required this.appliedAt,
    this.isConsumed = false,
  });

  /// Create a copy with modified values
  PowerUpEffect copyWith({
    PowerUpType? type,
    Map<String, dynamic>? data,
    DateTime? appliedAt,
    bool? isConsumed,
  }) {
    return PowerUpEffect(
      type: type ?? this.type,
      data: data ?? this.data,
      appliedAt: appliedAt ?? this.appliedAt,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }
}

/// Power-up manager for handling active effects
class PowerUpManager {
  final List<PowerUpEffect> _activeEffects = [];
  final Map<PowerUpType, int> _usageCount = {};

  /// Get all active effects
  List<PowerUpEffect> get activeEffects => List.unmodifiable(_activeEffects);

  /// Check if a specific power-up type is active
  bool isActive(PowerUpType type) {
    return _activeEffects.any((effect) => effect.type == type && !effect.isConsumed);
  }

  /// Apply a power-up effect
  void applyPowerUp(PowerUpType type, {Map<String, dynamic>? data}) {
    final effect = PowerUpEffect(
      type: type,
      data: data ?? {},
      appliedAt: DateTime.now(),
    );
    
    _activeEffects.add(effect);
    _usageCount[type] = (_usageCount[type] ?? 0) + 1;
  }

  /// Consume a power-up effect (mark as used)
  void consumeEffect(PowerUpType type) {
    final index = _activeEffects.indexWhere(
      (effect) => effect.type == type && !effect.isConsumed
    );
    
    if (index != -1) {
      _activeEffects[index] = _activeEffects[index].copyWith(isConsumed: true);
    }
  }

  /// Remove expired effects
  void cleanupExpiredEffects() {
    final now = DateTime.now();
    _activeEffects.removeWhere((effect) {
      final config = PowerUpConfig.getConfig(effect.type);
      if (config.duration == 0) return effect.isConsumed;
      
      final elapsed = now.difference(effect.appliedAt).inSeconds;
      return elapsed >= config.duration || effect.isConsumed;
    });
  }

  /// Get usage count for a power-up type
  int getUsageCount(PowerUpType type) => _usageCount[type] ?? 0;

  /// Reset all effects
  void reset() {
    _activeEffects.clear();
    _usageCount.clear();
  }
}
