import 'package:flutter/material.dart';
import '../models/chart_models.dart';
import '../../../models/mood_entry.dart';
import '../../../models/enhanced_mood_entry.dart';
import '../../../services/enhanced_mood_storage.dart';

/// Controller for managing chart state and data processing
class ChartController extends ChangeNotifier {
  final EnhancedMoodStorage _storage;
  
  ChartType _chartType = ChartType.line;
  TimePeriod _timePeriod = TimePeriod.last30Days; // More forgiving default
  List<EnhancedMoodEntry> _allEntries = [];
  List<EnhancedMoodEntry> _filteredEntries = [];
  MoodStatistics? _statistics;
  bool _isLoading = false;
  String? _error;

  ChartController(this._storage);

  // Getters
  ChartType get chartType => _chartType;
  TimePeriod get timePeriod => _timePeriod;
  List<EnhancedMoodEntry> get filteredEntries => _filteredEntries;
  MoodStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _filteredEntries.isNotEmpty;

  /// Update chart type and notify listeners
  void updateChartType(ChartType type) {
    if (_chartType != type) {
      _chartType = type;
      notifyListeners();
    }
  }

  /// Update time period, filter data, and recalculate statistics
  void updateTimePeriod(TimePeriod period) {
    if (_timePeriod != period) {
      _timePeriod = period;
      _filterEntries();
      _calculateStatistics();
      notifyListeners();
    }
  }

  /// Load all mood data from storage
  Future<void> loadData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allEntries = _storage.getAllMoodEntries();
      _filterEntries();
      _calculateStatistics();
    } catch (e) {
      _error = 'Failed to load mood data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data from storage
  Future<void> refreshData() async {
    await loadData();
  }

  /// Filter entries based on current time period
  void _filterEntries() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_timePeriod) {
      case TimePeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        startDate = DateTime(now.year, now.month - 1, 1); // Start of previous month
        break;
      case TimePeriod.quarter:
        startDate = DateTime(now.year, now.month - 3, 1); // Start of 3 months ago
        break;
      case TimePeriod.year:
        startDate = DateTime(now.year - 1, 1, 1); // Start of previous year
        break;
      case TimePeriod.last30Days:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.last90Days:
        startDate = now.subtract(const Duration(days: 90));
        break;
    }

    _filteredEntries = _allEntries
        .where((entry) => entry.date.isAfter(startDate) || _isSameDay(entry.date, startDate))
        .toList();
    _filteredEntries.sort((a, b) => a.date.compareTo(b.date));
    
    // Fallback: if no data in time period, show all data
    if (_filteredEntries.isEmpty && _allEntries.isNotEmpty) {
      _filteredEntries = List.from(_allEntries);
      _filteredEntries.sort((a, b) => a.date.compareTo(b.date));
      print('ChartController: No data in period, showing all data');
    }
    
    // Debug output
    print('ChartController: Total entries: ${_allEntries.length}');
    print('ChartController: Filtered entries: ${_filteredEntries.length}');
    print('ChartController: Start date: $startDate');
    print('ChartController: Time period: $_timePeriod');
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Calculate comprehensive mood statistics
  void _calculateStatistics() {
    if (_filteredEntries.isEmpty) {
      _statistics = null;
      return;
    }

    final moodValues = _filteredEntries.map((e) => e.overallMood.toDouble()).toList();
    
    // Basic statistics
    final average = moodValues.reduce((a, b) => a + b) / moodValues.length;
    
    final sortedValues = List<double>.from(moodValues)..sort();
    final median = sortedValues.length % 2 == 0
        ? (sortedValues[sortedValues.length ~/ 2 - 1] + sortedValues[sortedValues.length ~/ 2]) / 2
        : sortedValues[sortedValues.length ~/ 2];

    final variance = moodValues
        .map((value) => (value - average) * (value - average))
        .reduce((a, b) => a + b) / moodValues.length;

    final moodVariability = variance > 0 ? moodValues
        .map((value) => (value - average) * (value - average))
        .reduce((a, b) => a + b) / moodValues.length
        : 0.0;

    // Emotion breakdown (all entries are enhanced entries now)
    final emotionBreakdown = <String, double>{};
    int emotionCount = 0;
    
    for (final entry in _filteredEntries) {
      for (final emotion in entry.emotions.keys) {
        emotionBreakdown[emotion] = (emotionBreakdown[emotion] ?? 0) + 1;
        emotionCount++;
      }
    }
    
    // Convert to percentages
    if (emotionCount > 0) {
      emotionBreakdown.updateAll((key, value) => (value / emotionCount) * 100);
    }

    // Activity frequency (all entries are enhanced entries now)
    final activityFrequency = <String, int>{};
    for (final entry in _filteredEntries) {
      for (final activity in entry.activities) {
        activityFrequency[activity] = (activityFrequency[activity] ?? 0) + 1;
      }
    }

    // Calculate trend using linear regression
    final trend = _calculateTrend(moodValues);

    // Calculate current streak
    final streakDays = _calculateStreak();

    _statistics = MoodStatistics(
      average: average,
      median: median,
      variance: variance,
      totalEntries: _filteredEntries.length,
      streakDays: streakDays,
      emotionBreakdown: emotionBreakdown,
      activityFrequency: activityFrequency,
      trend: trend,
      moodVariability: moodVariability,
    );
  }

  /// Calculate mood trend using simple linear regression
  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;
    
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumXX = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    
    if (n * sumXX - sumX * sumX == 0) return 0.0;
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope;
  }

  /// Calculate the current mood logging streak
  int _calculateStreak() {
    if (_allEntries.isEmpty) return 0;
    
    final sortedEntries = List<MoodEntry>.from(_allEntries)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      
      if (lastDate == null) {
        // Check if the most recent entry is today or yesterday
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));
        
        if (entryDate.isAtSameMomentAs(todayDate) || entryDate.isAtSameMomentAs(yesterday)) {
          streak = 1;
          lastDate = entryDate;
        } else {
          break;
        }
      } else {
        final difference = lastDate.difference(entryDate).inDays;
        if (difference == 1) {
          streak++;
          lastDate = entryDate;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  /// Get chart data points based on current chart type
  List<ChartDataPoint> getChartData() {
    switch (_chartType) {
      case ChartType.line:
        return _getLineChartData();
      case ChartType.bar:
        return _getBarChartData();
      case ChartType.pie:
        return _getPieChartData();
      case ChartType.heatmap:
        return _getHeatmapData();
    }
  }

  /// Get data for line chart (mood over time)
  List<ChartDataPoint> _getLineChartData() {
    return _filteredEntries.map((entry) => ChartDataPoint(
      date: entry.date,
      value: entry.overallMood.toDouble(),
      metadata: {'entry': entry},
    )).toList();
  }

  /// Get data for bar chart (daily averages)
  List<ChartDataPoint> _getBarChartData() {
    final dailyAverages = <DateTime, List<double>>{};
    
    for (final entry in _filteredEntries) {
      final dayKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyAverages.putIfAbsent(dayKey, () => []).add(entry.overallMood.toDouble());
    }
    
    final result = dailyAverages.entries.map((e) => ChartDataPoint(
      date: e.key,
      value: e.value.reduce((a, b) => a + b) / e.value.length,
      label: '${e.key.day}/${e.key.month}',
      metadata: {'entryCount': e.value.length},
    )).toList()..sort((a, b) => a.date.compareTo(b.date));
    
    print('Bar chart data: ${result.length} points');
    return result;
  }

  /// Get data for pie chart (emotion breakdown)
  List<ChartDataPoint> _getPieChartData() {
    final emotionData = getEmotionBreakdown();
    
    final result = emotionData.entries.map((e) => ChartDataPoint(
      date: DateTime.now(), // Not relevant for pie chart
      value: e.value.toDouble(),
      label: e.key,
    )).toList();
    
    print('Pie chart data: ${result.length} points, emotions: $emotionData');
    return result;
  }

  /// Get data for heatmap (calendar view)
  List<ChartDataPoint> _getHeatmapData() {
    final heatmapData = <DateTime, List<double>>{};
    
    for (final entry in _filteredEntries) {
      final dayKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      heatmapData.putIfAbsent(dayKey, () => []).add(entry.overallMood.toDouble());
    }
    
    return heatmapData.entries.map((e) => ChartDataPoint(
      date: e.key,
      value: e.value.reduce((a, b) => a + b) / e.value.length,
      metadata: {'entryCount': e.value.length},
    )).toList();
  }

  /// Get formatted time period label
  String getTimePeriodLabel() {
    switch (_timePeriod) {
      case TimePeriod.week:
        return 'Last 7 days';
      case TimePeriod.month:
        return 'Last month';
      case TimePeriod.quarter:
        return 'Last 3 months';
      case TimePeriod.year:
        return 'Last year';
      case TimePeriod.last30Days:
        return 'Last 30 days';
      case TimePeriod.last90Days:
        return 'Last 90 days';
    }
  }

  /// Get chart type display name
  String getChartTypeLabel() {
    switch (_chartType) {
      case ChartType.line:
        return 'Line Chart';
      case ChartType.bar:
        return 'Bar Chart';
      case ChartType.pie:
        return 'Pie Chart';
      case ChartType.heatmap:
        return 'Heatmap';
    }
  }

  /// Get emotion breakdown data for pie chart
  Map<String, int> getEmotionBreakdown() {
    final emotionData = <String, int>{};
    
    // Use actual emotion data from enhanced mood entries
    for (final entry in _filteredEntries) {
      if (entry.emotions.isNotEmpty) {
        // Use actual emotions from the entry
        for (final emotion in entry.emotions.keys) {
          emotionData[emotion] = (emotionData[emotion] ?? 0) + 1;
        }
      } else {
        // Fallback: generate emotion based on overall mood for entries without emotions
        String emotion;
        if (entry.overallMood >= 8) {
          emotion = 'happiness';
        } else if (entry.overallMood >= 6) {
          emotion = 'contentment';
        } else if (entry.overallMood >= 4) {
          emotion = 'neutral';
        } else if (entry.overallMood >= 2) {
          emotion = 'sadness';
        } else {
          emotion = 'anxiety';
        }
        
        emotionData[emotion] = (emotionData[emotion] ?? 0) + 1;
      }
    }
    
    return emotionData;
  }

  @override
  void dispose() {
    super.dispose();
  }
}