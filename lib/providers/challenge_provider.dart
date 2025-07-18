import 'package:flutter/foundation.dart';
import '../models/daily_challenge.dart';
import '../models/game_session.dart';
import '../services/storage_service.dart';

class ChallengeProvider extends ChangeNotifier {
  static const String _storageKey = 'challenge_progress';
  
  Map<String, bool> _completedChallenges = {};
  Map<String, int> _challengeProgress = {};
  int _dailyStreak = 0;
  DateTime? _lastCompletionDate;
  
  // Getters
  Map<String, bool> get completedChallenges => _completedChallenges;
  Map<String, int> get challengeProgress => _challengeProgress;
  int get dailyStreak => _dailyStreak;
  DateTime? get lastCompletionDate => _lastCompletionDate;
  
  ChallengeProvider() {
    _loadProgress();
  }
  
  /// Load challenge progress from storage
  Future<void> _loadProgress() async {
    try {
      final data = await StorageService.getData(_storageKey);
      if (data != null) {
        _completedChallenges = Map<String, bool>.from(data['completed'] ?? {});
        _challengeProgress = Map<String, int>.from(data['progress'] ?? {});
        _dailyStreak = data['streak'] ?? 0;
        
        final lastDateStr = data['lastCompletion'] as String?;
        if (lastDateStr != null) {
          _lastCompletionDate = DateTime.parse(lastDateStr);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading challenge progress: $e');
    }
  }
  
  /// Save challenge progress to storage
  Future<void> _saveProgress() async {
    try {
      final data = {
        'completed': _completedChallenges,
        'progress': _challengeProgress,
        'streak': _dailyStreak,
        'lastCompletion': _lastCompletionDate?.toIso8601String(),
      };
      await StorageService.saveData(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving challenge progress: $e');
    }
  }
  
  /// Check if challenge is completed
  bool isChallengeCompleted(String challengeId) {
    return _completedChallenges[challengeId] ?? false;
  }
  
  /// Get challenge progress
  int getChallengeProgress(String challengeId) {
    return _challengeProgress[challengeId] ?? 0;
  }
  
  /// Update challenge progress based on game session
  Future<void> updateChallengeProgress(GameSession session) async {
    if (!session.settings.isChallengeMode || session.settings.challengeId == null) {
      return;
    }
    
    final challengeId = session.settings.challengeId!;
    final targetScore = session.settings.targetScore;
    final targetWords = session.settings.targetWords;
    
    bool challengeCompleted = false;
    
    // Check completion based on challenge type
    if (targetScore != null && session.totalScore >= targetScore) {
      challengeCompleted = true;
    } else if (targetWords != null && session.foundWords.length >= targetWords) {
      challengeCompleted = true;
    }

    // Update progress
    if (targetScore != null) {
      _challengeProgress[challengeId] = session.totalScore;
    } else if (targetWords != null) {
      _challengeProgress[challengeId] = session.foundWords.length;
    }
    
    // Mark as completed if achieved
    if (challengeCompleted && !_completedChallenges.containsKey(challengeId)) {
      _completedChallenges[challengeId] = true;
      await _updateDailyStreak();
    }
    
    await _saveProgress();
    notifyListeners();
  }
  
  /// Update daily streak
  Future<void> _updateDailyStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastCompletionDate == null) {
      // First completion
      _dailyStreak = 1;
      _lastCompletionDate = today;
    } else {
      final lastDate = DateTime(
        _lastCompletionDate!.year,
        _lastCompletionDate!.month,
        _lastCompletionDate!.day,
      );
      
      final daysDifference = today.difference(lastDate).inDays;
      
      if (daysDifference == 1) {
        // Consecutive day
        _dailyStreak++;
        _lastCompletionDate = today;
      } else if (daysDifference == 0) {
        // Same day, no change
      } else {
        // Streak broken
        _dailyStreak = 1;
        _lastCompletionDate = today;
      }
    }
  }
  
  /// Reset daily challenges (for testing)
  Future<void> resetDailyChallenges() async {
    _completedChallenges.clear();
    _challengeProgress.clear();
    await _saveProgress();
    notifyListeners();
  }
  
  /// Get challenge completion percentage
  double getChallengeCompletionPercentage(DailyChallenge challenge) {
    final progress = getChallengeProgress(challenge.id);
    final target = challenge.target;
    
    if (target <= 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }
  
  /// Check if player can claim daily reward
  bool canClaimDailyReward() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastCompletionDate == null) return false;
    
    final lastDate = DateTime(
      _lastCompletionDate!.year,
      _lastCompletionDate!.month,
      _lastCompletionDate!.day,
    );
    
    return today == lastDate && _dailyStreak > 0;
  }
  
  /// Get reward coins based on streak
  int getStreakRewardCoins() {
    if (_dailyStreak <= 0) return 0;
    
    // Base reward + bonus for streak
    int baseReward = 50;
    int streakBonus = (_dailyStreak - 1) * 10;
    int maxBonus = 200; // Cap at 200 bonus coins
    
    return baseReward + (streakBonus > maxBonus ? maxBonus : streakBonus);
  }
}
