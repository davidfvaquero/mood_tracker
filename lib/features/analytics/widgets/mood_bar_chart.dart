import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_models.dart';

/// Modern bar chart widget for mood data visualization
class MoodBarChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final ChartTheme chartTheme;
  final Function(ChartDataPoint?)? onBarTapped;
  final String title;

  const MoodBarChart({
    Key? key,
    required this.data,
    required this.chartTheme,
    this.onBarTapped,
    this.title = 'Daily Mood Averages',
  }) : super(key: key);

  @override
  State<MoodBarChart> createState() => _MoodBarChartState();
}

class _MoodBarChartState extends State<MoodBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10.5,
                    minY: 0,
                    barTouchData: _buildBarTouchData(),
                    titlesData: _buildTitlesData(),
                    borderData: _buildBorderData(),
                    barGroups: _buildBarGroups(),
                    gridData: _buildGridData(),
                    backgroundColor: widget.chartTheme.backgroundColor,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  swapAnimationCurve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.bar_chart,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (widget.data.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.data.length} days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No mood data available',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your mood to see charts',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Theme.of(context).colorScheme.surfaceVariant,
        tooltipRoundedRadius: 8,
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex >= widget.data.length) return null;
          
          final dataPoint = widget.data[groupIndex];
          final date = dataPoint.date;
          final value = dataPoint.value;
          
          return BarTooltipItem(
            '${date.day}/${date.month}\n',
            TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: 'Mood: ${value.toStringAsFixed(1)}/10',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
              if (dataPoint.metadata?['entryCount'] != null)
                TextSpan(
                  text: '\nEntries: ${dataPoint.metadata!['entryCount']}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
            ],
          );
        },
      ),
      touchCallback: (FlTouchEvent event, barTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            touchedIndex = -1;
            widget.onBarTapped?.call(null);
            return;
          }
          
          touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          if (touchedIndex >= 0 && touchedIndex < widget.data.length) {
            widget.onBarTapped?.call(widget.data[touchedIndex]);
          }
        });
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _buildBottomTitles,
          reservedSize: 38,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 2,
          getTitlesWidget: _buildLeftTitles,
        ),
      ),
    );
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= widget.data.length) {
      return const SizedBox.shrink();
    }

    final dataPoint = widget.data[index];
    final date = dataPoint.date;
    
    return SideTitleWidget(
      meta: meta,
      child: Transform.rotate(
        angle: -0.3,
        child: Text(
          '${date.day}/${date.month}',
          style: TextStyle(
            color: widget.chartTheme.textColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toInt().toString(),
        style: TextStyle(
          color: widget.chartTheme.textColor.withOpacity(0.7),
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: widget.chartTheme.textColor.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: widget.chartTheme.showGrid,
      checkToShowHorizontalLine: (value) => value % 2 == 0,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: widget.chartTheme.textColor.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
      drawVerticalLine: false,
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final dataPoint = entry.value;
      final isTouched = index == touchedIndex;
      
      final color = _getMoodColor(dataPoint.value);
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dataPoint.value * _animation.value,
            color: isTouched ? color.withOpacity(0.8) : color,
            width: isTouched ? 20 : 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 10,
              color: widget.chartTheme.textColor.withOpacity(0.05),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getMoodColor(double mood) {
    if (mood <= 3) return const Color(0xFFEF4444); // Red
    if (mood <= 5) return const Color(0xFFF59E0B); // Orange
    if (mood <= 7) return const Color(0xFFFBBF24); // Yellow
    if (mood <= 8.5) return const Color(0xFF84CC16); // Lime
    return const Color(0xFF10B981); // Green
  }
}