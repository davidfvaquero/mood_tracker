import 'package:hive/hive.dart';
import '../models/mood_entry.dart';

class MoodStorage {
  static const String _boxName = 'moodEntries';

  Future<Box<MoodEntry>> _openBox() async {
    return await Hive.openBox<MoodEntry>(_boxName);
  }

  Future<void> saveMood(MoodEntry entry) async {
    final box = await _openBox();
    await box.add(entry);
  }

  Future<List<MoodEntry>> getAllEntries() async {
    final box = await _openBox();
    return box.values.toList().reversed.toList(); // Más recientes primero
  }

  Future<List<MoodEntry>> getLastDays(int days) async {
    final allEntries = await getAllEntries();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return allEntries.where((entry) => entry.date.isAfter(cutoffDate)).toList();
  }
}