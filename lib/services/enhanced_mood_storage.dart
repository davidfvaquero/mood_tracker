import 'package:hive/hive.dart';
import 'package:mood_tracker/models/enhanced_mood_entry.dart';

class EnhancedMoodStorage {
  static const String boxName = 'enhancedMoodEntries';
  
  Box<EnhancedMoodEntry> get _box => Hive.box<EnhancedMoodEntry>(boxName);

  /// Add a new enhanced mood entry
  Future<void> addMoodEntry(EnhancedMoodEntry entry) async {
    await _box.add(entry);
  }

  /// Get all enhanced mood entries
  List<EnhancedMoodEntry> getAllMoodEntries() {
    return _box.values.toList();
  }

  /// Get enhanced mood entries for a specific date range
  List<EnhancedMoodEntry> getMoodEntriesInRange(DateTime start, DateTime end) {
    return _box.values.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get enhanced mood entries for a specific date
  List<EnhancedMoodEntry> getMoodEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box.values.where((entry) {
      return entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             entry.date.isBefore(endOfDay);
    }).toList();
  }

  /// Update an enhanced mood entry
  Future<void> updateMoodEntry(int index, EnhancedMoodEntry entry) async {
    await _box.putAt(index, entry);
  }

  /// Delete an enhanced mood entry
  Future<void> deleteMoodEntry(int index) async {
    await _box.deleteAt(index);
  }

  /// Get the latest mood entry
  EnhancedMoodEntry? getLatestMoodEntry() {
    if (_box.isEmpty) return null;
    return _box.values.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  /// Get average mood for a date range
  double getAverageMood(DateTime start, DateTime end) {
    final entries = getMoodEntriesInRange(start, end);
    if (entries.isEmpty) return 0.0;
    
    final sum = entries.fold(0, (sum, entry) => sum + entry.overallMood);
    return sum / entries.length;
  }

  /// Get mood statistics for analytics
  Map<String, dynamic> getMoodStatistics(DateTime start, DateTime end) {
    final entries = getMoodEntriesInRange(start, end);
    
    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMood': 0.0,
        'averageEnergy': 0.0,
        'averageStress': 0.0,
        'topEmotions': <String>[],
        'topActivities': <String>[],
        'topTriggers': <String>[],
      };
    }

    // Calculate averages
    final avgMood = entries.fold(0, (sum, e) => sum + e.overallMood) / entries.length;
    final avgEnergy = entries.fold(0, (sum, e) => sum + e.energyLevel) / entries.length;
    final avgStress = entries.fold(0, (sum, e) => sum + e.stressLevel) / entries.length;

    // Count emotions, activities, and triggers
    final emotionCounts = <String, int>{};
    final activityCounts = <String, int>{};
    final triggerCounts = <String, int>{};

    for (final entry in entries) {
      // Count emotions
      entry.emotions.forEach((emotion, intensity) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + intensity;
      });

      // Count activities
      for (final activity in entry.activities) {
        activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
      }

      // Count triggers
      for (final trigger in entry.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }

    // Get top items
    final topEmotions = emotionCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);
    
    final topActivities = activityCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);
    
    final topTriggers = triggerCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);

    return {
      'totalEntries': entries.length,
      'averageMood': avgMood,
      'averageEnergy': avgEnergy,
      'averageStress': avgStress,
      'topEmotions': topEmotions.map((e) => e.key).toList(),
      'topActivities': topActivities.map((e) => e.key).toList(),
      'topTriggers': topTriggers.map((e) => e.key).toList(),
      'emotionCounts': emotionCounts,
      'activityCounts': activityCounts,
      'triggerCounts': triggerCounts,
    };
  }

  /// Quick mood check-in with minimal data
  Future<void> addQuickMoodEntry({
    required int overallMood,
    Map<String, int>? emotions,
    List<String>? activities,
    String? notes,
  }) async {
    final entry = EnhancedMoodEntry(
      date: DateTime.now(),
      overallMood: overallMood,
      emotions: emotions ?? {},
      activities: activities ?? [],
      notes: notes,
      isQuickEntry: true,
    );
    
    await addMoodEntry(entry);
  }

  /// Get entries by mood range
  List<EnhancedMoodEntry> getEntriesByMoodRange(int minMood, int maxMood) {
    return _box.values.where((entry) {
      return entry.overallMood >= minMood && entry.overallMood <= maxMood;
    }).toList();
  }

  /// Get entries with specific emotion
  List<EnhancedMoodEntry> getEntriesWithEmotion(String emotion, {int? minIntensity}) {
    return _box.values.where((entry) {
      if (!entry.emotions.containsKey(emotion)) return false;
      if (minIntensity != null) {
        return entry.emotions[emotion]! >= minIntensity;
      }
      return true;
    }).toList();
  }

  /// Get entries with specific activity
  List<EnhancedMoodEntry> getEntriesWithActivity(String activity) {
    return _box.values.where((entry) {
      return entry.activities.contains(activity);
    }).toList();
  }

  /// Get entries with specific trigger
  List<EnhancedMoodEntry> getEntriesWithTrigger(String trigger) {
    return _box.values.where((entry) {
      return entry.triggers.contains(trigger);
    }).toList();
  }

  /// Clear all enhanced mood entries (use with caution)
  Future<void> clearAllEntries() async {
    await _box.clear();
  }

  /// Get total count of entries
  int get totalEntries => _box.length;

  /// Check if there are any entries
  bool get hasEntries => _box.isNotEmpty;

  /// Export data for backup
  Future<List<Map<String, dynamic>>> exportData() async {
    return _box.values.map((entry) => entry.toJson()).toList();
  }

  /// Import data from backup
  Future<void> importData(List<Map<String, dynamic>> data) async {
    for (final entryData in data) {
      final entry = EnhancedMoodEntry.fromJson(entryData);
      await _box.add(entry);
    }
  }
}