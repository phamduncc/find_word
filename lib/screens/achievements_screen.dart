import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4CAF50), // Green
              Color(0xFF2E7D32), // Dark green
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    const Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Consumer<AchievementProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade600,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 20),
                              const SizedBox(width: AppConstants.spacingXS),
                              Text(
                                '${provider.totalAchievementPoints}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
              ),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  labelColor: Colors.green.shade700,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'UNLOCKED'),
                    Tab(text: 'LOCKED'),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingM),

              // Tab content
              Expanded(
                child: Consumer<AchievementProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (provider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 64,
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            Text(
                              provider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // Unlocked achievements
                        _buildAchievementsList(provider.unlockedAchievements, true),
                        // Locked achievements
                        _buildAchievementsList(provider.lockedAchievements, false),
                      ],
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

  Widget _buildAchievementsList(List<Achievement> achievements, bool isUnlocked) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              isUnlocked 
                  ? 'No achievements unlocked yet.\nStart playing to earn your first badge!'
                  : 'All achievements unlocked!\nYou\'re a true Word Master!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          achievement: achievement,
          isUnlocked: isUnlocked,
        );
      },
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? achievement.type.color 
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.type.icon,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: AppConstants.spacingM),

          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.type.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  achievement.type.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnlocked ? Colors.black54 : Colors.grey.shade500,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: AppConstants.spacingS),
                  // Progress bar
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.type.color,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    '${achievement.progress}/${achievement.target}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (isUnlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Points badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingS,
              vertical: AppConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? achievement.type.color.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Text(
              '+${achievement.type.points}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked 
                    ? achievement.type.color
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
