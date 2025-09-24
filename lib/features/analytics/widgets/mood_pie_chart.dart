import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_models.dart';

class MoodPieChart extends StatefulWidget {
  final Map<String, int> emotionData;
  final ChartTheme chartTheme;
  final void Function(String emotion)? onEmotionTap;

  const MoodPieChart({
    super.key,
    required this.emotionData,
    required this.chartTheme,
    this.onEmotionTap,
  });

  @override
  State<MoodPieChart> createState() => _MoodPieChartState();
}

class _MoodPieChartState extends State<MoodPieChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.emotionData.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 300,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 80,
                sections: _buildPieChartSections(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: widget.chartTheme.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No emotion data available',
            style: TextStyle(
              fontSize: 16,
              color: widget.chartTheme.textColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log some moods to see your emotion breakdown',
            style: TextStyle(
              fontSize: 14,
              color: widget.chartTheme.textColor.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final emotions = widget.emotionData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return emotions.asMap().entries.map((entry) {
      final index = entry.key;
      final emotion = entry.value.key;
      final count = entry.value.value;
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        color: _getEmotionColor(emotion),
        value: count.toDouble(),
        title: _getDisplayName(emotion),
        radius: (isTouched ? 120 : 100) * _animation.value,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : _getFontSizeForSegment(count, emotions.length),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
        titlePositionPercentageOffset: 0.7,
        badgeWidget: isTouched ? _buildBadge(emotion, count) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(String emotion, int count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.chartTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getEmotionColor(emotion),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getEmotionIcon(emotion),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            emotion,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.chartTheme.textColor,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 10,
              color: widget.chartTheme.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName(String emotion) {
    // Shorten long emotion names for better display in pie chart segments
    final shortNames = {
      'disappointment': 'Disappointed',
      'contentment': 'Content',
      'frustration': 'Frustrated',
      'excitement': 'Excited',
      'relaxation': 'Relaxed',
      'loneliness': 'Lonely',
      'happiness': 'Happy',
      'gratitude': 'Grateful',
      'confusion': 'Confused',
      'motivated': 'Motivated',
      'energetic': 'Energetic',
    };

    final displayName = shortNames[emotion.toLowerCase()] ?? emotion;
    
    // Capitalize first letter
    return displayName.isEmpty 
        ? emotion 
        : displayName[0].toUpperCase() + displayName.substring(1).toLowerCase();
  }

  double _getFontSizeForSegment(int count, int totalSegments) {
    // Adjust font size based on segment size and total number of segments
    if (totalSegments > 6) {
      return 8.0; // Smaller font for many segments
    } else if (totalSegments > 4) {
      return 9.0; // Medium font for moderate segments
    } else {
      return 10.0; // Larger font for few segments
    }
  }

  Color _getEmotionColor(String emotion) {
    final colors = {
      'joy': const Color(0xFFFFD700),
      'happiness': const Color(0xFFFFD700),
      'excitement': const Color(0xFFFF8C00),
      'love': const Color(0xFFFF69B4),
      'contentment': const Color(0xFF98FB98),
      'pride': const Color(0xFF9370DB),
      'hope': const Color(0xFF87CEEB),
      'gratitude': const Color(0xFFFFA500),
      'calm': const Color(0xFF20B2AA),
      'relaxation': const Color(0xFF20B2AA),
      'sadness': const Color(0xFF4169E1),
      'anger': const Color(0xFFDC143C),
      'frustration': const Color(0xFFFF4500),
      'anxiety': const Color(0xFF8B008B),
      'fear': const Color(0xFF2F4F4F),
      'disappointment': const Color(0xFF708090),
      'loneliness': const Color(0xFF483D8B),
      'stress': const Color(0xFFB22222),
      'guilt': const Color(0xFF8B4513),
      'shame': const Color(0xFF800080),
      'neutral': const Color(0xFF696969),
      'confused': const Color(0xFFDDA0DD),
      'tired': const Color(0xFF778899),
      'energetic': const Color(0xFFFF6347),
      'motivated': const Color(0xFF32CD32),
      'focused': const Color(0xFF4682B4),
    };

    return colors[emotion.toLowerCase()] ?? 
           widget.chartTheme.colors.first.withOpacity(0.7);
  }

  String _getEmotionIcon(String emotion) {
    final icons = {
      'joy': '😄',
      'happiness': '😊',
      'excitement': '🤩',
      'love': '❤️',
      'contentment': '😌',
      'pride': '😤',
      'hope': '🌟',
      'gratitude': '🙏',
      'calm': '😇',
      'relaxation': '😴',
      'sadness': '😢',
      'anger': '😠',
      'frustration': '😤',
      'anxiety': '😰',
      'fear': '😨',
      'disappointment': '😞',
      'loneliness': '😔',
      'stress': '😫',
      'guilt': '😳',
      'shame': '😞',
      'neutral': '😐',
      'confused': '😕',
      'tired': '😴',
      'energetic': '⚡',
      'motivated': '💪',
      'focused': '🎯',
    };

    return icons[emotion.toLowerCase()] ?? '😐';
  }
}