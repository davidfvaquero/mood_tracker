import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chart_models.dart';

class MoodHeatmapChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final ChartTheme chartTheme;
  final void Function(DateTime date, double? mood)? onDayTap;

  const MoodHeatmapChart({
    super.key,
    required this.data,
    required this.chartTheme,
    this.onDayTap,
  });

  @override
  State<MoodHeatmapChart> createState() => _MoodHeatmapChartState();
}

class _MoodHeatmapChartState extends State<MoodHeatmapChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, double> _moodData = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _processMoodData();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(MoodHeatmapChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _processMoodData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _processMoodData() {
    _moodData.clear();
    for (final dataPoint in widget.data) {
      final date = DateTime(
        dataPoint.date.year,
        dataPoint.date.month,
        dataPoint.date.day,
      );
      _moodData[date] = dataPoint.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 4),
          SizedBox(
            height: 160,
            child: _buildCalendar(),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 15,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                  1,
                );
              });
              _animationController.reset();
              _animationController.forward();
            },
            icon: Icon(
              Icons.chevron_left,
              color: widget.chartTheme.textColor,
            ),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.chartTheme.textColor,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                  1,
                );
              });
              _animationController.reset();
              _animationController.forward();
            },
            icon: Icon(
              Icons.chevron_right,
              color: widget.chartTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildWeekdayHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildCalendarGrid(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      children: weekdays.map((weekday) {
        return Expanded(
          child: Center(
            child: Text(
              weekday,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.chartTheme.textColor.withOpacity(0.7),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate how many weeks we need
    final totalCells = daysInMonth + (firstDayOfWeek - 1);
    final weeksNeeded = (totalCells / 7).ceil();

    return Column(
      children: List.generate(weeksNeeded, (weekIndex) {
        return Expanded(
          child: Row(
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNumber = cellIndex - (firstDayOfWeek - 1) + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final currentDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
              );
              final mood = _moodData[currentDate];

              return Expanded(
                child: _buildDayCell(currentDate, mood, dayNumber),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime date, double? mood, int dayNumber) {
    final isToday = _isToday(date);
    final hasData = mood != null;
    final intensity = hasData ? mood / 10.0 : 0.0;
    
    return Container(
      margin: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onDayTap?.call(date, mood),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: 300 + (dayNumber * 20),
            ),
            curve: Curves.elasticOut,
            height: double.infinity,
            decoration: BoxDecoration(
              color: hasData
                  ? _getMoodColor(intensity).withOpacity(
                      0.2 + (intensity * 0.8 * _animation.value),
                    )
                  : widget.chartTheme.backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isToday
                    ? widget.chartTheme.colors.first
                    : hasData
                        ? _getMoodColor(intensity).withOpacity(0.3)
                        : widget.chartTheme.textColor.withOpacity(0.1),
                width: isToday ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: hasData
                          ? _getContrastingTextColor(_getMoodColor(intensity))
                          : widget.chartTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                ),
                if (hasData)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 6 * _animation.value,
                      height: 6 * _animation.value,
                      decoration: BoxDecoration(
                        color: _getMoodColor(intensity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (isToday)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    right: 2,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: widget.chartTheme.colors.first,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.chartTheme.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final intensity = (index + 1) / 5.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getMoodColor(intensity).withOpacity(0.2 + (intensity * 0.8)),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: _getMoodColor(intensity).withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.chartTheme.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap on a day to see mood details',
            style: TextStyle(
              fontSize: 11,
              color: widget.chartTheme.textColor.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getMoodColor(double intensity) {
    // Create a gradient from red (low mood) to green (high mood)
    if (intensity < 0.5) {
      // Red to yellow
      return Color.lerp(
        const Color(0xFFFF4444), // Red
        const Color(0xFFFFAA00), // Orange
        intensity * 2,
      )!;
    } else {
      // Yellow to green
      return Color.lerp(
        const Color(0xFFFFAA00), // Orange
        const Color(0xFF44AA44), // Green
        (intensity - 0.5) * 2,
      )!;
    }
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}