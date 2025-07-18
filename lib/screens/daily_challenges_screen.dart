import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_challenge.dart';
import '../models/game_settings.dart';
import '../providers/challenge_provider.dart';
import '../providers/powerup_provider.dart';

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  late DailyChallenge todayChallenge;
  List<DailyChallenge> weekChallenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  void _loadChallenges() {
    final today = DateTime.now();
    todayChallenge = DailyChallengeGenerator.generateForDate(today);
    
    // Generate challenges for the week
    weekChallenges = List.generate(7, (index) {
      final date = today.subtract(Duration(days: index));
      return DailyChallengeGenerator.generateForDate(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenges'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.purple, Colors.indigo],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Today's Challenge Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: Colors.yellow,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Today\'s Challenge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(todayChallenge, isToday: true),
                  ],
                ),
              ),

              // Weekly Challenges
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'This Week',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: weekChallenges.length,
                          itemBuilder: (context, index) {
                            final challenge = weekChallenges[index];
                            final isToday = index == 0;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: _buildChallengeCard(challenge, isToday: isToday),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, {bool isToday = false}) {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, _) {
        final isCompleted = challengeProvider.isChallengeCompleted(challenge.id);
        final progress = challengeProvider.getChallengeProgress(challenge.id);
        final progressPercentage = challengeProvider.getChallengeCompletionPercentage(challenge);

        return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday 
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday 
              ? Colors.yellow.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Challenge Type Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getChallengeColor(challenge.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getChallengeIcon(challenge.type),
                  color: _getChallengeColor(challenge.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Challenge Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Completion Status
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Reward Info
          Row(
            children: [
              Icon(
                Icons.stars,
                color: Colors.yellow,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${challenge.rewardPoints} points',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              
              // Date
              Text(
                _formatDate(challenge.date),
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // Action Button
          if (isToday && !isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startChallenge(challenge),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start Challenge',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
      },
    );
  }

  Color _getChallengeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.wordCount:
        return Colors.blue;
      case ChallengeType.timeLimit:
        return Colors.red;
      case ChallengeType.longWords:
        return Colors.green;
      case ChallengeType.noHints:
        return Colors.orange;
      case ChallengeType.perfectScore:
        return Colors.purple;
      case ChallengeType.speedRun:
        return Colors.cyan;
      case ChallengeType.themeWords:
        return Colors.pink;
    }
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.wordCount:
        return Icons.format_list_numbered;
      case ChallengeType.timeLimit:
        return Icons.timer;
      case ChallengeType.longWords:
        return Icons.text_fields;
      case ChallengeType.noHints:
        return Icons.visibility_off;
      case ChallengeType.perfectScore:
        return Icons.star;
      case ChallengeType.speedRun:
        return Icons.speed;
      case ChallengeType.themeWords:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${date.day}/${date.month}';
  }

  void _startChallenge(DailyChallenge challenge) {
    // Create challenge-specific game settings
    final challengeSettings = GameSettings.fromChallenge(challenge);

    Navigator.of(context).pushNamed(
      '/game',
      arguments: challengeSettings,
    );
  }
}
