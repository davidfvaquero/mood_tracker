class MoodEntry {
  final int rating;
  final DateTime date;

  MoodEntry({
    required this.rating,
    required this.date,
  });

  @override
  String toString() {
    return 'MoodEntry{rating: $rating, date: $date}';
  }
}