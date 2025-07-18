import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/power_up.dart';
import '../providers/powerup_provider.dart';

class PowerupsShopScreen extends StatefulWidget {
  const PowerupsShopScreen({super.key});

  @override
  State<PowerupsShopScreen> createState() => _PowerupsShopScreenState();
}

class _PowerupsShopScreenState extends State<PowerupsShopScreen> {
  @override
  void initState() {
    super.initState();
    // Force initialize PowerupProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PowerupProvider>();
      print('🔧 Force initializing PowerupProvider...');
      provider.forceReset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power-ups Shop'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Coins Display
          Consumer<PowerupProvider>(
            builder: (context, provider, _) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.playerCoins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange, Colors.orange, Colors.amber],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Text(
                      'Boost Your Game!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Purchase power-ups to enhance your gameplay',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Power-ups Grid
              Expanded(
                child: Consumer<PowerupProvider>(
                  builder: (context, provider, _) {
                    print('🎮 PowerupProvider has ${provider.powerUps.length} power-ups');

                    // If no power-ups, show hardcoded data
                    if (provider.powerUps.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _getHardcodedPowerUps().length,
                          itemBuilder: (context, index) {
                            final powerUp = _getHardcodedPowerUps()[index];
                            return _buildHardcodedPowerUpCard(powerUp);
                          },
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: provider.powerUps.length,
                        itemBuilder: (context, index) {
                          print('🎮 Building power-up card $index of ${provider.powerUps.length}');
                          final powerUp = provider.powerUps[index];
                          return _buildPowerUpCard(powerUp, provider);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpCard(PowerUp powerUp, PowerupProvider provider) {
    final canAfford = provider.canAfford(powerUp.type);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Header with icon and quantity
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Power-up Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: powerUp.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    powerUp.icon,
                    color: powerUp.color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                
                // Quantity owned
                if (powerUp.quantity > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${powerUp.quantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Power-up Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    powerUp.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      powerUp.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Duration info
                  if (powerUp.duration > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${powerUp.duration}s',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Purchase Button
          Container(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford ? () => _purchasePowerUp(powerUp, provider) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? powerUp.color : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${powerUp.cost}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _purchasePowerUp(PowerUp powerUp, PowerupProvider provider) async {
    final success = await provider.purchasePowerUp(powerUp.type);
    
    if (success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${powerUp.name} purchased!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough coins!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Get hardcoded power-ups for testing
  List<PowerUp> _getHardcodedPowerUps() {
    return [
      PowerUp(
        type: PowerUpType.timeFreeze,
        name: 'Time Freeze',
        description: 'Freeze time for 10 seconds',
        cost: 50,
        icon: Icons.pause,
        color: Colors.blue,
        duration: 10,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.doublePoints,
        name: 'Double Points',
        description: 'Double points for next 3 words',
        cost: 75,
        icon: Icons.star,
        color: Colors.orange,
        duration: 30,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.wordHint,
        name: 'Word Hint',
        description: 'Reveal a random word',
        cost: 30,
        icon: Icons.lightbulb,
        color: Colors.yellow,
        duration: 0,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.letterShuffle,
        name: 'Letter Shuffle',
        description: 'Shuffle letters for new perspective',
        cost: 25,
        icon: Icons.shuffle,
        color: Colors.purple,
        duration: 0,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.extraTime,
        name: 'Extra Time',
        description: 'Add 30 seconds to timer',
        cost: 40,
        icon: Icons.timer,
        color: Colors.green,
        duration: 0,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.comboBoost,
        name: 'Combo Boost',
        description: 'Boost combo multiplier',
        cost: 60,
        icon: Icons.trending_up,
        color: Colors.red,
        duration: 45,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.clearMistakes,
        name: 'Clear Mistakes',
        description: 'Clear all mistakes',
        cost: 35,
        icon: Icons.clear,
        color: Colors.teal,
        duration: 0,
        quantity: 0,
      ),
      PowerUp(
        type: PowerUpType.xrayVision,
        name: 'X-Ray Vision',
        description: 'See hidden word patterns',
        cost: 80,
        icon: Icons.visibility,
        color: Colors.indigo,
        duration: 20,
        quantity: 0,
      ),
    ];
  }

  /// Build hardcoded power-up card
  Widget _buildHardcodedPowerUpCard(PowerUp powerUp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Header with icon
          Container(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: powerUp.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                powerUp.icon,
                color: powerUp.color,
                size: 24,
              ),
            ),
          ),

          // Power-up Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    powerUp.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      powerUp.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Purchase Button
          Container(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _purchaseHardcodedPowerUp(powerUp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: powerUp.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${powerUp.cost}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseHardcodedPowerUp(PowerUp powerUp) async {
    final provider = context.read<PowerupProvider>();

    // Check if player has enough coins
    if (provider.playerCoins < powerUp.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! Need ${powerUp.cost} coins.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // For testing, directly add the power-up to provider
    // This simulates purchasing from the hardcoded list
    final success = await provider.purchasePowerUp(powerUp.type);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(powerUp.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('${powerUp.name} purchased!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase failed!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Power-ups system is being initialized...'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
