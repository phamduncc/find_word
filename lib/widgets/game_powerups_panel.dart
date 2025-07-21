import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/power_up.dart';
import '../providers/powerup_provider.dart';

class GamePowerupsPanel extends StatelessWidget {
  final VoidCallback? onPowerupUsed;
  
  const GamePowerupsPanel({
    super.key,
    this.onPowerupUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PowerupProvider>(
      builder: (context, provider, _) {
        // Get only owned power-ups
        final ownedPowerups = provider.powerUps
            .where((powerup) => powerup.quantity > 0)
            .toList();

        if (ownedPowerups.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No Power-ups',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          );
        }

        return Container(
          constraints: const BoxConstraints(maxWidth: 120), // Limit max width
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PowerUp>(
              isExpanded: true, // Allow dropdown to expand to fit container
              hint: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: Colors.yellow,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Power-ups (${ownedPowerups.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 16,
              ),
              dropdownColor: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              items: ownedPowerups.map((powerup) {
                return DropdownMenuItem<PowerUp>(
                  value: powerup,
                  child: Container(
                    width: 200, // Fixed width to prevent unbounded constraints
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Power-up icon with background
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: powerup.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            powerup.icon,
                            color: powerup.color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Power-up info
                        Expanded(
                          child: Text(
                            powerup.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quantity badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: powerup.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${powerup.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (PowerUp? selectedPowerup) {
                if (selectedPowerup != null) {
                  _usePowerup(context, selectedPowerup);
                }
              },
            ),
          ),
        );
      },
    );
  }
  
  void _usePowerup(BuildContext context, PowerUp powerup) async {
    final provider = context.read<PowerupProvider>();
    
    // Check if power-up can be used
    if (powerup.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ${powerup.name} remaining!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Use the power-up
    final success = provider.usePowerUp(powerup.type);
    
    if (success) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(powerup.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('${powerup.name} activated!'),
            ],
          ),
          backgroundColor: powerup.color,
          duration: Duration(seconds: powerup.duration),
        ),
      );
      
      // Notify parent
      onPowerupUsed?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to use power-up!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// Power-up effects that can be applied to game
class PowerupEffects {
  static const Map<PowerUpType, String> descriptions = {
    PowerUpType.timeFreeze: 'Time frozen for 10 seconds!',
    PowerUpType.doublePoints: 'Double score for next 3 words!',
    PowerUpType.wordHint: 'Word hints revealed!',
    PowerUpType.letterShuffle: 'Letters shuffled!',
    PowerUpType.extraTime: '+30 seconds added!',
    PowerUpType.comboBoost: 'Combo boost activated!',
    PowerUpType.clearMistakes: 'Mistakes cleared!',
    PowerUpType.xrayVision: 'X-ray vision activated!',
  };

  static String getDescription(PowerUpType type) {
    return descriptions[type] ?? 'Power-up activated!';
  }

  static Duration getDuration(PowerUpType type) {
    switch (type) {
      case PowerUpType.timeFreeze:
        return const Duration(seconds: 10);
      case PowerUpType.doublePoints:
        return const Duration(seconds: 30);
      case PowerUpType.comboBoost:
        return const Duration(seconds: 60);
      case PowerUpType.extraTime:
        return const Duration(seconds: 45);
      default:
        return const Duration(seconds: 5);
    }
  }
}
