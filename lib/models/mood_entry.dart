import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject{
  @HiveField(0)
  final int rating;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String? notes;

  MoodEntry({
    required this.rating,
    required this.date,
    this.notes,
  });
}