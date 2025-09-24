import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_tracker/services/mood_storage.dart';
import 'package:mood_tracker/services/notification_service.dart';
import 'package:mood_tracker/services/migration_service.dart';
import 'package:mood_tracker/providers/locale_provider.dart';
import 'package:provider/provider.dart';

import 'models/mood_entry.dart';
import 'models/enhanced_mood_entry.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/enhanced_analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tips_screen.dart';
import 'themes/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register adapters for both legacy and enhanced mood entries
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(EnhancedMoodEntryAdapter());
  
  // Open boxes for both models
  await Hive.openBox<MoodEntry>('moodEntries');
  await Hive.openBox<EnhancedMoodEntry>('enhancedMoodEntries');
  
  // Run data migration if needed
  await MigrationService.migrateLegacyData();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemePrefs();

  final localeProvider = LocaleProvider();
  await localeProvider.initializeLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeNotifier),
        ChangeNotifierProvider(create: (_) => localeProvider),
        Provider(create: (_) => MoodStorage()),
        Provider(create: (_) => notificationService),
      ],
      child: const MoodTrackerApp(),
    ),
  );
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Tracker',
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleProvider.supportedLocales,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeNotifier.themeMode,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EnhancedHomeScreen(),
    const EnhancedAnalyticsScreen(),
    TipsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.sentiment_satisfied),
            label: localizations.moodNavigation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: localizations.chartsNavigation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.lightbulb),
            label: localizations.tipsNavigation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: localizations.settingsNavigation,
          ),
        ],
      ),
    );
  }
}