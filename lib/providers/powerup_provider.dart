import 'package:flutter/foundation.dart';
import '../models/power_up.dart';
import '../services/storage_service.dart';

class PowerupProvider extends ChangeNotifier {
  static const String _storageKey = 'powerups_data';
  
  List<PowerUp> _powerUps = [];
  int _playerCoins = 500; // Starting coins
  final PowerUpManager _manager = PowerUpManager();

  // Constructor
  PowerupProvider() {
    print('🚀 PowerupProvider constructor called');
    initialize();
  }

  // Getters
  List<PowerUp> get powerUps => List.unmodifiable(_powerUps);
  int get playerCoins => _playerCoins;
  PowerUpManager get manager => _manager;

  /// Initialize power-ups data
  Future<void> initialize() async {
    try {
      await _loadPowerUps();
      await _loadPlayerCoins();
    } catch (e) {
      print('Error initializing PowerupProvider: $e');
      _initializeDefaults();
    }
  }

  /// Load power-ups from storage
  Future<void> _loadPowerUps() async {
    try {
      final data = await StorageService.getData(_storageKey);
      if (data != null && data is Map<String, dynamic>) {
        final powerUpsData = data['powerUps'] as List<dynamic>?;
        if (powerUpsData != null) {
          _powerUps = powerUpsData.map((item) {
            final powerUpData = item as Map<String, dynamic>;
            final type = PowerUpType.values[powerUpData['type'] as int];
            return PowerUp.fromJson(powerUpData, type);
          }).toList();
        } else {
          _initializeDefaults();
        }
        
        _playerCoins = data['playerCoins'] as int? ?? 500;
      } else {
        _initializeDefaults();
      }
    } catch (e) {
      print('Error loading power-ups: $e');
      _initializeDefaults();
    }
  }

  /// Load player coins from storage
  Future<void> _loadPlayerCoins() async {
    try {
      final data = await StorageService.getData(_storageKey);
      if (data != null && data is Map<String, dynamic>) {
        _playerCoins = data['playerCoins'] as int? ?? 500;
      }
    } catch (e) {
      print('Error loading player coins: $e');
    }
  }

  /// Initialize default power-ups
  void _initializeDefaults() {
    _powerUps = PowerUpConfig.getAllPowerUps();
    _playerCoins = 500;
    print('🔧 Initialized ${_powerUps.length} power-ups with $_playerCoins coins');
    notifyListeners();
  }

  /// Force reset to defaults (for debugging)
  void forceReset() {
    print('🔄 Force resetting PowerupProvider...');
    _initializeDefaults();
  }

  /// Save power-ups data to storage
  Future<void> _savePowerUps() async {
    try {
      final data = {
        'powerUps': _powerUps.map((powerUp) => powerUp.toJson()).toList(),
        'playerCoins': _playerCoins,
      };
      await StorageService.saveData(_storageKey, data);
    } catch (e) {
      print('Error saving power-ups: $e');
    }
  }

  /// Purchase a power-up
  Future<bool> purchasePowerUp(PowerUpType type) async {
    try {
      final index = _powerUps.indexWhere((p) => p.type == type);
      if (index == -1) return false;

      final powerUp = _powerUps[index];
      if (_playerCoins < powerUp.cost) return false;

      _playerCoins -= powerUp.cost;
      _powerUps[index] = powerUp.copyWith(quantity: powerUp.quantity + 1);

      await _savePowerUps();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error purchasing power-up: $e');
      return false;
    }
  }

  /// Use a power-up
  bool usePowerUp(PowerUpType type) {
    try {
      final index = _powerUps.indexWhere((p) => p.type == type);
      if (index == -1) return false;

      final powerUp = _powerUps[index];
      if (!powerUp.canUse) return false;

      // Decrease quantity
      _powerUps[index] = powerUp.copyWith(quantity: powerUp.quantity - 1);

      // Apply power-up effect
      _manager.applyPowerUp(type);

      // Save and notify
      _savePowerUps();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error using power-up: $e');
      return false;
    }
  }

  /// Add coins (from gameplay rewards)
  Future<void> addCoins(int amount) async {
    _playerCoins += amount;
    await _savePowerUps();
    notifyListeners();
  }

  /// Get power-up by type
  PowerUp? getPowerUp(PowerUpType type) {
    try {
      return _powerUps.firstWhere((p) => p.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Check if power-up is active
  bool isPowerUpActive(PowerUpType type) {
    return _manager.isActive(type);
  }

  /// Get active power-ups
  List<PowerUpEffect> getActiveEffects() {
    return _manager.activeEffects;
  }

  /// Consume power-up effect (mark as used)
  void consumePowerUpEffect(PowerUpType type) {
    _manager.consumeEffect(type);
    notifyListeners();
  }

  /// Clean up expired effects
  void cleanupExpiredEffects() {
    _manager.cleanupExpiredEffects();
    notifyListeners();
  }

  /// Reset all power-up effects (for new game)
  void resetEffects() {
    _manager.reset();
    notifyListeners();
  }

  /// Get power-up usage statistics
  Map<PowerUpType, int> getUsageStats() {
    final stats = <PowerUpType, int>{};
    for (final type in PowerUpType.values) {
      stats[type] = _manager.getUsageCount(type);
    }
    return stats;
  }

  /// Award coins based on game performance
  Future<void> awardCoinsForGame({
    required int score,
    required int wordsFound,
    required bool perfectGame,
    required int comboLevel,
  }) async {
    int coinsEarned = 0;

    // Base coins from score
    coinsEarned += (score / 100).floor();

    // Bonus for words found
    coinsEarned += wordsFound * 2;

    // Perfect game bonus
    if (perfectGame) {
      coinsEarned += 50;
    }

    // Combo bonus
    if (comboLevel >= 3) {
      coinsEarned += comboLevel * 10;
    }

    // Minimum 5 coins per game
    coinsEarned = coinsEarned.clamp(5, 1000);

    await addCoins(coinsEarned);
  }

  /// Get daily login bonus
  Future<void> claimDailyBonus() async {
    const dailyBonus = 100;
    await addCoins(dailyBonus);
  }

  /// Check if player can afford power-up
  bool canAfford(PowerUpType type) {
    final powerUp = getPowerUp(type);
    return powerUp != null && _playerCoins >= powerUp.cost;
  }


  /// Get recommended power-ups based on player stats
  List<PowerUpType> getRecommendedPowerUps() {
    final recommendations = <PowerUpType>[];
    
    // Basic recommendations for new players
    if (_playerCoins >= 25) {
      recommendations.add(PowerUpType.letterShuffle);
    }
    
    if (_playerCoins >= 30) {
      recommendations.add(PowerUpType.wordHint);
    }
    
    if (_playerCoins >= 50) {
      recommendations.add(PowerUpType.timeFreeze);
    }
    
    return recommendations;
  }

  /// Debug method to add test coins
  Future<void> addTestCoins() async {
    await addCoins(1000);
  }
}
