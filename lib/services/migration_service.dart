import 'package:hive/hive.dart';
import 'package:mood_tracker/models/mood_entry.dart';
import 'package:mood_tracker/models/enhanced_mood_entry.dart';

class MigrationService {
  static const String _migrationKey = 'data_migration_completed';
  
  /// Migrates legacy MoodEntry data to EnhancedMoodEntry format
  static Future<void> migrateLegacyData() async {
    final migrationBox = await Hive.openBox('migration_status');
    
    // Check if migration has already been completed
    if (migrationBox.get(_migrationKey, defaultValue: false)) {
      print('Data migration already completed');
      return;
    }

    try {
      // Get legacy mood entries
      final legacyBox = Hive.box<MoodEntry>('moodEntries');
      final enhancedBox = Hive.box<EnhancedMoodEntry>('enhancedMoodEntries');
      
      print('Starting data migration from ${legacyBox.length} legacy entries...');
      
      // Convert each legacy entry to enhanced format
      for (int i = 0; i < legacyBox.length; i++) {
        final legacyEntry = legacyBox.getAt(i);
        if (legacyEntry != null) {
          final enhancedEntry = EnhancedMoodEntry.fromLegacy(
            date: legacyEntry.date,
            rating: legacyEntry.rating,
            notes: legacyEntry.notes,
          );
          
          await enhancedBox.add(enhancedEntry);
        }
      }
      
      // Mark migration as completed
      await migrationBox.put(_migrationKey, true);
      
      print('Data migration completed successfully! Migrated ${enhancedBox.length} entries.');
      
      // Optionally, you can backup or clear legacy data
      // For now, we'll keep it for safety
      
    } catch (e) {
      print('Error during data migration: $e');
      // Don't mark as completed if there was an error
    }
  }
  
  /// Checks if migration has been completed
  static Future<bool> isMigrationCompleted() async {
    final migrationBox = await Hive.openBox('migration_status');
    return migrationBox.get(_migrationKey, defaultValue: false);
  }
  
  /// Forces a re-migration (use with caution)
  static Future<void> resetMigrationStatus() async {
    final migrationBox = await Hive.openBox('migration_status');
    await migrationBox.delete(_migrationKey);
  }
  
  /// Gets the count of entries in both boxes for comparison
  static Future<Map<String, int>> getEntryCounts() async {
    final legacyBox = Hive.box<MoodEntry>('moodEntries');
    final enhancedBox = Hive.box<EnhancedMoodEntry>('enhancedMoodEntries');
    
    return {
      'legacy': legacyBox.length,
      'enhanced': enhancedBox.length,
    };
  }
  
  /// Backup legacy data to a JSON format (optional)
  static Future<List<Map<String, dynamic>>> backupLegacyData() async {
    final legacyBox = Hive.box<MoodEntry>('moodEntries');
    final backup = <Map<String, dynamic>>[];
    
    for (int i = 0; i < legacyBox.length; i++) {
      final entry = legacyBox.getAt(i);
      if (entry != null) {
        backup.add({
          'rating': entry.rating,
          'date': entry.date.toIso8601String(),
          'notes': entry.notes,
        });
      }
    }
    
    return backup;
  }
}