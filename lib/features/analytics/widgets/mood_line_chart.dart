import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_models.dart';

class MoodLineChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final ChartTheme chartTheme;

  const MoodLineChart({
    super.key,
    required this.data,
    required this.chartTheme,
  });

  @override
  State<MoodLineChart> createState() => _MoodLineChartState();
}

class _MoodLineChartState extends State<MoodLineChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: widget.chartTheme.showGrid,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: widget.chartTheme.textColor.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: widget.chartTheme.textColor.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: widget.chartTheme.showLabels,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: _buildBottomTitles,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: _buildLeftTitles,
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: widget.chartTheme.textColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            minX: 0,
            maxX: widget.data.length.toDouble() - 1,
            minY: 0,
            maxY: 10,
            lineBarsData: [
              LineChartBarData(
                spots: _buildSpots(),
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    widget.chartTheme.colors.first,
                    widget.chartTheme.colors.first.withOpacity(0.3),
                  ],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: widget.chartTheme.colors.first,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      widget.chartTheme.colors.first.withOpacity(0.3),
                      widget.chartTheme.colors.first.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.blueGrey,
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final index = barSpot.x.toInt();
                    if (index >= 0 && index < widget.data.length) {
                      final dataPoint = widget.data[index];
                      return LineTooltipItem(
                        '${dataPoint.date.day}/${dataPoint.date.month}\n${barSpot.y.toStringAsFixed(1)}/10',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _buildSpots() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final dataPoint = entry.value;
      return FlSpot(
        index.toDouble(),
        dataPoint.value * _animation.value,
      );
    }).toList();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: widget.chartTheme.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No mood data available',
            style: TextStyle(
              fontSize: 16,
              color: widget.chartTheme.textColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log some moods to see your trend',
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
}