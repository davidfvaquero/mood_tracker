/// Chart data models and enums for mood tracking analytics
library;

import 'package:flutter/material.dart';

enum ChartType { 
  line, 
  bar, 
  pie, 
  heatmap 
}

enum TimePeriod { 
  week, 
  month, 
  quarter, 
  year, 
  last30Days, 
  last90Days 
}

/// Represents a data point in any chart visualization
class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? label;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartDataPoint &&
        other.date == date &&
        other.value == value &&
        other.label == label;
  }

  @override
  int get hashCode {
    return date.hashCode ^ value.hashCode ^ label.hashCode;
  }

  @override
  String toString() {
    return 'ChartDataPoint(date: $date, value: $value, label: $label)';
  }
}

/// Comprehensive mood statistics for analytics
class MoodStatistics {
  final double average;
  final double median;
  final double variance;
  final int totalEntries;
  final int streakDays;
  final Map<String, double> emotionBreakdown;
  final Map<String, int> activityFrequency;
  final double trend; // Linear regression slope
  final double moodVariability; // Standard deviation

  const MoodStatistics({
    required this.average,
    required this.median,
    required this.variance,
    required this.totalEntries,
    required this.streakDays,
    required this.emotionBreakdown,
    required this.activityFrequency,
    required this.trend,
    required this.moodVariability,
  });

  /// Returns a trend description based on the slope
  String get trendDescription {
    if (trend > 0.1) return 'improving';
    if (trend < -0.1) return 'declining';
    return 'stable';
  }

  /// Returns the most frequent emotion
  String? get dominantEmotion {
    if (emotionBreakdown.isEmpty) return null;
    return emotionBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Returns the most frequent activity
  String? get topActivity {
    if (activityFrequency.isEmpty) return null;
    return activityFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  String toString() {
    return 'MoodStatistics(average: $average, trend: $trendDescription, entries: $totalEntries)';
  }
}

/// Chart configuration and theming
class ChartTheme {
  final List<Color> colors;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final bool showGrid;
  final bool showLabels;

  const ChartTheme({
    required this.colors,
    required this.backgroundColor,
    required this.textColor,
    this.borderRadius = 8.0,
    this.showGrid = true,
    this.showLabels = true,
  });

  /// Default light theme
  static const ChartTheme light = ChartTheme(
    colors: [
      Color(0xFF6366F1), // Indigo
      Color(0xFF8B5CF6), // Purple
      Color(0xFF06B6D4), // Cyan
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Red
      Color(0xFFEC4899), // Pink
      Color(0xFF84CC16), // Lime
    ],
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF1F2937),
  );

  /// Default dark theme
  static const ChartTheme dark = ChartTheme(
    colors: [
      Color(0xFF818CF8), // Indigo-400
      Color(0xFFA78BFA), // Purple-400
      Color(0xFF22D3EE), // Cyan-400
      Color(0xFF34D399), // Emerald-400
      Color(0xFFFBBF24), // Amber-400
      Color(0xFFF87171), // Red-400
      Color(0xFFF472B6), // Pink-400
      Color(0xFFA3E635), // Lime-400
    ],
    backgroundColor: Color(0xFF1F2937),
    textColor: Color(0xFFF9FAFB),
  );

  /// Create theme from Flutter theme data
  factory ChartTheme.fromTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? ChartTheme.dark : ChartTheme.light;
  }
}