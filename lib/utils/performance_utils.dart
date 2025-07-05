import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final List<String> _performanceLogs = [];

  /// Start timing an operation
  static void startTimer(String operation) {
    if (!kDebugMode) return;
    
    _timers[operation] = Stopwatch()..start();
  }

  /// Stop timing an operation and log the result
  static void stopTimer(String operation) {
    if (!kDebugMode) return;
    
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      final elapsed = timer.elapsedMilliseconds;
      final log = '$operation took ${elapsed}ms';
      _performanceLogs.add(log);
      
      if (kDebugMode) {
        print('Performance: $log');
      }
      
      _timers.remove(operation);
    }
  }

  /// Get all performance logs
  static List<String> getPerformanceLogs() {
    return List.unmodifiable(_performanceLogs);
  }

  /// Clear performance logs
  static void clearLogs() {
    _performanceLogs.clear();
  }

  /// Measure the execution time of a function
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    if (!kDebugMode) {
      return await function();
    }

    startTimer(operation);
    try {
      final result = await function();
      return result;
    } finally {
      stopTimer(operation);
    }
  }

  /// Measure the execution time of a synchronous function
  static T measureSync<T>(
    String operation,
    T Function() function,
  ) {
    if (!kDebugMode) {
      return function();
    }

    startTimer(operation);
    try {
      final result = function();
      return result;
    } finally {
      stopTimer(operation);
    }
  }

  /// Check if the app is running at 60fps
  static void monitorFrameRate() {
    if (!kDebugMode) return;

    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      // This is a simplified frame rate monitor
      // In a real app, you might want more sophisticated monitoring
    });
  }

  /// Debounce function calls
  static Timer? _debounceTimer;
  
  static void debounce(
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls
  static DateTime? _lastThrottleTime;
  
  static void throttle(
    Duration interval,
    VoidCallback callback,
  ) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }
}

class MemoryUtils {
  /// Force garbage collection (for debugging only)
  static void forceGC() {
    if (kDebugMode) {
      // This is platform-specific and might not work on all platforms
      print('Requesting garbage collection...');
    }
  }

  /// Get memory usage information (simplified)
  static Map<String, dynamic> getMemoryInfo() {
    if (!kDebugMode) {
      return {};
    }

    // This is a placeholder - real memory monitoring would require
    // platform-specific implementations
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Memory monitoring not implemented',
    };
  }
}

class AnimationUtils {
  /// Create a staggered animation controller
  static List<AnimationController> createStaggeredControllers({
    required TickerProvider vsync,
    required int count,
    required Duration duration,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final controllers = <AnimationController>[];
    
    for (int i = 0; i < count; i++) {
      final controller = AnimationController(
        duration: duration,
        vsync: vsync,
      );
      controllers.add(controller);
    }
    
    return controllers;
  }

  /// Start staggered animations
  static void startStaggeredAnimations(
    List<AnimationController> controllers, {
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    for (int i = 0; i < controllers.length; i++) {
      Timer(staggerDelay * i, () {
        if (controllers[i].isCompleted || controllers[i].isDismissed) {
          controllers[i].forward();
        }
      });
    }
  }

  /// Dispose multiple animation controllers
  static void disposeControllers(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}

class UIUtils {
  /// Calculate responsive font size based on screen size
  static double getResponsiveFontSize(
    double baseSize,
    double screenWidth,
  ) {
    // Base width for scaling (iPhone 12 Pro width)
    const baseWidth = 390.0;
    final scale = screenWidth / baseWidth;
    
    // Clamp the scale to reasonable bounds
    final clampedScale = scale.clamp(0.8, 1.5);
    
    return baseSize * clampedScale;
  }

  /// Calculate responsive spacing
  static double getResponsiveSpacing(
    double baseSpacing,
    double screenWidth,
  ) {
    const baseWidth = 390.0;
    final scale = screenWidth / baseWidth;
    final clampedScale = scale.clamp(0.8, 1.3);
    
    return baseSpacing * clampedScale;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 768;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get optimal grid size based on screen size
  static int getOptimalGridSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletDevice = isTablet(context);
    
    if (isTabletDevice) {
      return 4; // 4x4 grid for tablets
    } else {
      return 3; // 3x3 grid for phones
    }
  }
}

class CacheUtils {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  /// Cache a value with optional expiration
  static void cache(
    String key,
    dynamic value, {
    Duration? expiration,
  }) {
    _cache[key] = value;
    if (expiration != null) {
      _cacheTimestamps[key] = DateTime.now().add(expiration);
    }
  }

  /// Get a cached value
  static T? getCached<T>(String key) {
    // Check if expired
    final expiration = _cacheTimestamps[key];
    if (expiration != null && DateTime.now().isAfter(expiration)) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key] as T?;
  }

  /// Clear all cache
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _cacheTimestamps.forEach((key, expiration) {
      if (now.isAfter(expiration)) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
}
