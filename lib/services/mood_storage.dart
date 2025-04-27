import 'package:hive/hive.dart';
import '../models/mood_entry.dart';

class MoodStorage {
  static const String _boxName = 'moodEntries';

  Future<Box<MoodEntry>> _openBox() async {
    return await Hive.openBox<MoodEntry>(_boxName);
  }

  Future<void> saveOrUpdateMood(MoodEntry newEntry) async {
    final box = await _openBox();
    final existingEntry = await getEntryByDate(newEntry.date);

    if (existingEntry != null) {
      await box.delete(existingEntry.key);
    }

    await box.add(newEntry);
  }

  Future<void> deleteDuplicates() async {
    final box = await _openBox();
    final uniqueDates = <String>{};

    final entriesToDelete = <dynamic>[];

    for (var entry in box.values) {
      final dateKey =
          "${entry.date.day}-${entry.date.month}-${entry.date.year}";

      if (uniqueDates.contains(dateKey)) {
        entriesToDelete.add(entry.key);
      } else {
        uniqueDates.add(dateKey);
      }
    }

    await box.deleteAll(entriesToDelete);
  }

  Future<MoodEntry?> getEntryByDate(DateTime date) async {
    final box = await _openBox();
    try {
      return box.values.firstWhere((entry) => _isSameDate(entry.date, date));
    } catch (_) {
      return null;
    }
  }

  Future<List<MoodEntry>> getLastDays(int days) async {
    final box = await _openBox();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return box.values
        .where((entry) => entry.date.isAfter(cutoff))
        .toList()
        .reversed
        .toList();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<List<MoodEntry>> getAllEntries() async {
    final box = await _openBox();
    return box.values.toList().reversed.toList();
  }
}
