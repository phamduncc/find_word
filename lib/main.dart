import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'models/models.dart';
import 'services/haptic_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HapticService.initialize();
  await TTSService.initialize();
  runApp(const FindWordsApp());
}

class FindWordsApp extends StatelessWidget {
  const FindWordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => HighScoreProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProxyProvider4<GameProvider, SettingsProvider, HighScoreProvider, AchievementProvider, AppProvider>(
          create: (context) => AppProvider(
            gameProvider: context.read<GameProvider>(),
            settingsProvider: context.read<SettingsProvider>(),
            highScoreProvider: context.read<HighScoreProvider>(),
            achievementProvider: context.read<AchievementProvider>(),
          ),
          update: (context, gameProvider, settingsProvider, highScoreProvider, achievementProvider, appProvider) =>
              appProvider ?? AppProvider(
                gameProvider: gameProvider,
                settingsProvider: settingsProvider,
                highScoreProvider: highScoreProvider,
                achievementProvider: achievementProvider,
              ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: const AppInitializer(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/game': (context) => const GameScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/achievements': (context) => const AchievementsScreen(),
              '/my-dictionary': (context) => const MyDictionaryScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/results':
                  final gameSession = settings.arguments as GameSession;
                  return MaterialPageRoute(
                    builder: (context) => ResultsScreen(gameSession: gameSession),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.initialize();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              AppConstants.secondaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.yellow,
              ),
              SizedBox(height: 24),
              Text(
                'Find Words',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
