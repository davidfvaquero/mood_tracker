import 'package:flutter/material.dart';

import 'screens/mood_rating_screen.dart';
import 'screens/mood_charts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tips_screen.dart';

void main() => runApp(const MoodTrackerApp());

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
    const MoodRatingScreen(),
    const MoodChartsScreen(),
    const TipsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied),
            label: 'Estado de ánimo'
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Gráficas'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Consejos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
