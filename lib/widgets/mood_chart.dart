import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';

class MoodChart extends StatefulWidget {
  final List<MoodEntry> data;
  final String timeFrame;

  const MoodChart({super.key, required this.data, required this.timeFrame});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  MoodEntry? _selectedEntry;

  Color _getSegmentColor(double value) {
    if (value <= 3) return Colors.red;
    if (value <= 6) return Colors.orange;
    if (value <= 8) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildChart(), if (_selectedEntry != null) _buildNotesCard()],
    );
  }

  Widget _buildChart() {
    final lineColors = widget.data
        .map((e) => _getSegmentColor(e.rating.toDouble()))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.moodTimeFrame(widget.timeFrame),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: widget.data.isEmpty ? 1 : (widget.data.length - 1).toDouble(),
                      minY: 0.8,
                      maxY: 10.2,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: value == 1 || value == 10
                              ? Colors.grey
                              : Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                        verticalInterval: 1,
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _calculateXInterval(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < widget.data.length) {
                                final date = widget.data[index].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _formatXLabel(date),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: value >= 1 && value <= 10
                                      ? Colors.grey[600]
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.data
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry.value.rating.clamp(1.0, 10.0).toDouble(),
                                  ))
                              .toList(),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          gradient: LinearGradient(colors: lineColors),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: _getSegmentColor(
                                    widget.data[index].rating.toDouble()),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchCallback:
                            (FlTouchEvent event, LineTouchResponse? response) {
                          if (event is FlTapUpEvent && response != null) {
                            final spotIndex =
                                response.lineBarSpots?.first.spotIndex;
                            if (spotIndex != null &&
                                spotIndex < widget.data.length) {
                              setState(() {
                                _selectedEntry = widget.data[spotIndex];
                              });
                            }
                          }
                        },
                        handleBuiltInTouches: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateXInterval() {
    final dataLength = widget.data.length;
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 7;
  }

  String _formatXLabel(DateTime date) {
    if (widget.timeFrame == 'Semanal') {
      return '${date.day}/${date.month}';
    }
    return '${date.day}';
  }

  Widget _buildNotesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notas del ${_formattedDate(_selectedEntry!.date)}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedEntry!.notes?.isNotEmpty == true
                    ? _selectedEntry!.notes!
                    : AppLocalizations.of(context)!.noNotesForThisDay,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}