import 'package:flutter/material.dart';
import 'package:mood_tracker/screens/enhanced_mood_rating_screen.dart';
import 'package:mood_tracker/widgets/quick_mood_checkin.dart';
import 'package:mood_tracker/services/enhanced_mood_storage.dart';
import 'package:mood_tracker/models/enhanced_mood_entry.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  final EnhancedMoodStorage _storage = EnhancedMoodStorage();
  List<EnhancedMoodEntry> _recentEntries = [];
  EnhancedMoodEntry? _todayEntry;
  
  @override
  void initState() {
    super.initState();
    _loadRecentEntries();
  }

  Future<void> _loadRecentEntries() async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayEntries = _storage.getMoodEntriesForDate(today);
    final recentEntries = _storage.getMoodEntriesInRange(
      yesterday,
      today,
    )..sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _todayEntry = todayEntries.isNotEmpty ? todayEntries.last : null;
      _recentEntries = recentEntries.take(5).toList();
    });
  }

  void _onMoodSaved() {
    _loadRecentEntries();
  }

  Widget _buildWelcomeCard() {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    String icon;

    if (hour < 12) {
      greeting = localizations.goodMorning;
      icon = '🌅';
    } else if (hour < 18) {
      greeting = localizations.goodAfternoon;
      icon = '☀️';
    } else {
      greeting = localizations.goodEvening;
      icon = '🌙';
    }

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$greeting!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _todayEntry != null
                  ? localizations.howAreYouNow
                  : localizations.howAreYouToday,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Registro Detallado',
            subtitle: 'Emociones, actividades y más',
            icon: Icons.sentiment_very_satisfied,
            color: Colors.blue,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnhancedMoodRatingScreen(),
                ),
              );
              _onMoodSaved();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: 'Check-in Rápido',
            subtitle: 'Solo estado de ánimo',
            icon: Icons.speed,
            color: Colors.green,
            onTap: () {
              // This will be handled by the QuickMoodCheckInWidget
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysSummary() {
    if (_todayEntry == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tu día hasta ahora',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMoodColor(_todayEntry!.overallMood),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Estado: ${_todayEntry!.overallMood}/10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Energía: ${_todayEntry!.energyLevel}/5',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (_todayEntry!.hasEmotions) ...[
              const SizedBox(height: 8),
              Text(
                'Emociones: ${_todayEntry!.emotions.keys.take(3).join(', ')}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            
            if (_todayEntry!.hasActivities) ...[
              const SizedBox(height: 4),
              Text(
                'Actividades: ${_todayEntry!.activities.take(3).join(', ')}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries() {
    if (_recentEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Entradas Recientes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...(_recentEntries.take(3).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getMoodColor(entry.overallMood),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        entry.overallMood.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(entry.date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (entry.notes?.isNotEmpty == true)
                          Text(
                            entry.notes!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (entry.isQuickEntry)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Rápido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            )).toList()),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(int mood) {
    if (mood <= 3) return Colors.red;
    if (mood <= 5) return Colors.orange;
    if (mood <= 7) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentEntries,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecentEntries,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildActionCards(),
              const SizedBox(height: 16),
              QuickMoodCheckInWidget(onMoodSaved: _onMoodSaved),
              const SizedBox(height: 16),
              _buildTodaysSummary(),
              const SizedBox(height: 16),
              _buildRecentEntries(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}