import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'models/models.dart';

void main() {
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
        ChangeNotifierProxyProvider3<GameProvider, SettingsProvider, HighScoreProvider, AppProvider>(
          create: (context) => AppProvider(
            gameProvider: context.read<GameProvider>(),
            settingsProvider: context.read<SettingsProvider>(),
            highScoreProvider: context.read<HighScoreProvider>(),
          ),
          update: (context, gameProvider, settingsProvider, highScoreProvider, appProvider) =>
              appProvider ?? AppProvider(
                gameProvider: gameProvider,
                settingsProvider: settingsProvider,
                highScoreProvider: highScoreProvider,
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
              Color(0xFF2196F3),
              Color(0xFF1976D2),
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
