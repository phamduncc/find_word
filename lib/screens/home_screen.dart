import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() async {
    final settingsProvider = context.read<SettingsProvider>();
    if (context.mounted) {
      Navigator.pushNamed(
        context,
        '/game',
        arguments: settingsProvider.settings,
      );
    }
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _openDailyChallenges() {
    Navigator.pushNamed(context, '/daily-challenges');
  }

  void _openPowerupsShop() {
    Navigator.pushNamed(context, '/powerups-shop');
  }

  void _openLeaderboard() {
    Navigator.pushNamed(context, '/leaderboard');
  }

  void _openAchievements() {
    Navigator.pushNamed(context, '/achievements');
  }

  void _openMyDictionary() {
    Navigator.pushNamed(context, '/my-dictionary');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor, // Cyan
                AppConstants.secondaryColor, // Dark cyan
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Crown icon
                          Container(
                            margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
                            child: Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: Colors.yellow.shade600,
                            ),
                          ),
                          
                          // App title
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingL),
                            decoration: BoxDecoration(
                              color: AppConstants.secondaryColor,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'FIND',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingS),
                                Container(
                                  padding: const EdgeInsets.all(AppConstants.spacingM),
                                  decoration: BoxDecoration(
                                    color: AppConstants.accentColor,
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                  ),
                                  child: const Text(
                                    'WORDS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: AppConstants.spacingXL * 2),
                          
                          // Menu buttons
                          MenuButton(
                            text: 'START GAME',
                            backgroundColor: AppConstants.successColor,
                            onPressed: _startGame,
                            icon: Icons.play_arrow,
                          ),

                          MenuButton(
                            text: 'ACHIEVEMENTS',
                            backgroundColor: AppConstants.hardColor,
                            onPressed: _openAchievements,
                            icon: Icons.emoji_events,
                          ),

                          MenuButton(
                            text: 'LEADERBOARD',
                            backgroundColor: AppConstants.primaryColor,
                            onPressed: _openLeaderboard,
                            icon: Icons.leaderboard,
                          ),

                          MenuButton(
                            text: 'DAILY CHALLENGES',
                            backgroundColor: Colors.deepPurple,
                            onPressed: _openDailyChallenges,
                            icon: Icons.today,
                          ),

                          MenuButton(
                            text: 'POWER-UPS SHOP',
                            backgroundColor: Colors.deepOrange,
                            onPressed: _openPowerupsShop,
                            icon: Icons.flash_on,
                          ),

                          Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              // Only show My Dictionary if Learning Mode is enabled
                              if (settingsProvider.settings.learningModeEnabled) {
                                return MenuButton(
                                  text: 'MY DICTIONARY',
                                  backgroundColor: AppConstants.secondaryColor,
                                  onPressed: _openMyDictionary,
                                  icon: Icons.book,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          MenuButton(
                            text: 'SETTINGS',
                            backgroundColor: AppConstants.mediumColor,
                            onPressed: _openSettings,
                            icon: Icons.settings,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
