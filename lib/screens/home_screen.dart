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

  void _openLeaderboard() {
    Navigator.pushNamed(context, '/leaderboard');
  }

  void _openAchievements() {
    Navigator.pushNamed(context, '/achievements');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF5722), // Orange-red like in the image
              Color(0xFFE91E63), // Pink-red
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
                            color: Colors.pink.shade600,
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
                                'KING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacingM,
                                  vertical: AppConstants.spacingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'OF',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Container(
                                padding: const EdgeInsets.all(AppConstants.spacingM),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                ),
                                child: const Text(
                                  'ENGLISH',
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
                          backgroundColor: Colors.yellow.shade600,
                          onPressed: _startGame,
                          icon: Icons.play_arrow,
                        ),
                        
                        MenuButton(
                          text: 'SETTINGS',
                          backgroundColor: Colors.pink.shade600,
                          onPressed: _openSettings,
                          icon: Icons.settings,
                        ),
                        
                        MenuButton(
                          text: 'LEADERBOARD',
                          backgroundColor: Colors.teal.shade600,
                          onPressed: _openLeaderboard,
                          icon: Icons.leaderboard,
                        ),

                        MenuButton(
                          text: 'ACHIEVEMENTS',
                          backgroundColor: Colors.purple.shade600,
                          onPressed: _openAchievements,
                          icon: Icons.emoji_events,
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
    );
  }
}
