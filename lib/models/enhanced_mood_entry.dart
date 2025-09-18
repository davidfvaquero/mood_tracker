import 'package:hive/hive.dart';

part 'enhanced_mood_entry.g.dart';

@HiveType(typeId: 1)
class EnhancedMoodEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int overallMood; // 1-10 overall mood rating

  @HiveField(2)
  final Map<String, int> emotions; // emotion name -> intensity (1-5)

  @HiveField(3)
  final List<String> activities; // activities done during this time

  @HiveField(4)
  final String? notes; // optional notes

  @HiveField(5)
  final int energyLevel; // 1-5 energy level

  @HiveField(6)
  final int stressLevel; // 1-5 stress level

  @HiveField(7)
  final List<String> triggers; // mood triggers/causes

  @HiveField(8)
  final String? location; // optional location context

  @HiveField(9)
  final bool isQuickEntry; // whether this was a quick check-in

  @HiveField(10)
  final DateTime? reminderTime; // when reminder was set (if applicable)

  EnhancedMoodEntry({
    required this.date,
    required this.overallMood,
    this.emotions = const {},
    this.activities = const [],
    this.notes,
    this.energyLevel = 3,
    this.stressLevel = 3,
    this.triggers = const [],
    this.location,
    this.isQuickEntry = false,
    this.reminderTime,
  });

  // Helper methods for easy access
  bool get hasEmotions => emotions.isNotEmpty;
  bool get hasActivities => activities.isNotEmpty;
  bool get hasTriggers => triggers.isNotEmpty;
  
  List<String> get primaryEmotions {
    // Returns emotions with intensity >= 4
    return emotions.entries
        .where((entry) => entry.value >= 4)
        .map((entry) => entry.key)
        .toList();
  }

  double get averageEmotionIntensity {
    if (emotions.isEmpty) return 0.0;
    final total = emotions.values.reduce((a, b) => a + b);
    return total / emotions.length;
  }

  // Convert from legacy MoodEntry
  factory EnhancedMoodEntry.fromLegacy({
    required DateTime date,
    required int rating,
    String? notes,
  }) {
    return EnhancedMoodEntry(
      date: date,
      overallMood: rating,
      notes: notes,
      isQuickEntry: false,
    );
  }

  // Convert to legacy format for backward compatibility
  Map<String, dynamic> toLegacyJson() {
    return {
      'rating': overallMood,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Full JSON serialization for enhanced features
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'overallMood': overallMood,
      'emotions': emotions,
      'activities': activities,
      'notes': notes,
      'energyLevel': energyLevel,
      'stressLevel': stressLevel,
      'triggers': triggers,
      'location': location,
      'isQuickEntry': isQuickEntry,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory EnhancedMoodEntry.fromJson(Map<String, dynamic> json) {
    return EnhancedMoodEntry(
      date: DateTime.parse(json['date']),
      overallMood: json['overallMood'],
      emotions: Map<String, int>.from(json['emotions'] ?? {}),
      activities: List<String>.from(json['activities'] ?? []),
      notes: json['notes'],
      energyLevel: json['energyLevel'] ?? 3,
      stressLevel: json['stressLevel'] ?? 3,
      triggers: List<String>.from(json['triggers'] ?? []),
      location: json['location'],
      isQuickEntry: json['isQuickEntry'] ?? false,
      reminderTime: json['reminderTime'] != null 
          ? DateTime.parse(json['reminderTime'])
          : null,
    );
  }
}

// Predefined emotion types
class EmotionType {
  static const String happy = 'Happy';
  static const String sad = 'Sad';
  static const String anxious = 'Anxious';
  static const String calm = 'Calm';
  static const String excited = 'Excited';
  static const String angry = 'Angry';
  static const String grateful = 'Grateful';
  static const String lonely = 'Lonely';
  static const String confident = 'Confident';
  static const String overwhelmed = 'Overwhelmed';
  static const String content = 'Content';
  static const String frustrated = 'Frustrated';
  static const String hopeful = 'Hopeful';
  static const String tired = 'Tired';
  static const String energetic = 'Energetic';

  static const List<String> all = [
    happy, sad, anxious, calm, excited, angry, grateful, lonely,
    confident, overwhelmed, content, frustrated, hopeful, tired, energetic
  ];

  static const Map<String, String> emotionIcons = {
    happy: '😊',
    sad: '😢',
    anxious: '😰',
    calm: '😌',
    excited: '🤗',
    angry: '😠',
    grateful: '🙏',
    lonely: '😔',
    confident: '💪',
    overwhelmed: '😵',
    content: '😊',
    frustrated: '😤',
    hopeful: '🌟',
    tired: '😴',
    energetic: '⚡',
  };
}

// Predefined activity types
class ActivityType {
  static const String work = 'Work';
  static const String exercise = 'Exercise';
  static const String socializing = 'Socializing';
  static const String family = 'Family Time';
  static const String hobby = 'Hobby';
  static const String relaxation = 'Relaxation';
  static const String learning = 'Learning';
  static const String travel = 'Travel';
  static const String shopping = 'Shopping';
  static const String cooking = 'Cooking';
  static const String reading = 'Reading';
  static const String music = 'Music';
  static const String nature = 'Nature';
  static const String meditation = 'Meditation';
  static const String gaming = 'Gaming';

  static const List<String> all = [
    work, exercise, socializing, family, hobby, relaxation, learning,
    travel, shopping, cooking, reading, music, nature, meditation, gaming
  ];

  static const Map<String, String> activityIcons = {
    work: '💼',
    exercise: '🏃',
    socializing: '👥',
    family: '👨‍👩‍👧‍👦',
    hobby: '🎨',
    relaxation: '🛋️',
    learning: '📚',
    travel: '✈️',
    shopping: '🛒',
    cooking: '👨‍🍳',
    reading: '📖',
    music: '🎵',
    nature: '🌳',
    meditation: '🧘',
    gaming: '🎮',
  };
}

// Common mood triggers
class TriggerType {
  static const String workStress = 'Work Stress';
  static const String relationships = 'Relationships';
  static const String health = 'Health';
  static const String weather = 'Weather';
  static const String sleep = 'Sleep';
  static const String finances = 'Finances';
  static const String socialMedia = 'Social Media';
  static const String news = 'News';
  static const String family = 'Family';
  static const String traffic = 'Traffic';
  static const String deadlines = 'Deadlines';
  static const String conflict = 'Conflict';
  static const String achievement = 'Achievement';
  static const String support = 'Support';
  static const String exercise = 'Exercise';

  static const List<String> all = [
    workStress, relationships, health, weather, sleep, finances,
    socialMedia, news, family, traffic, deadlines, conflict,
    achievement, support, exercise
  ];
}