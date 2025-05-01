import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildChart(), if (_selectedEntry != null) _buildNotesCard()],
    );
  }

  Widget _buildChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de ánimo - ${widget.timeFrame}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX:
                      widget.data.isEmpty
                          ? 1
                          : (widget.data.length - 1).toDouble(),
                  minY: 0,
                  maxY: 10,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: _getBottomTitles()),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 2),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey),
                      left: BorderSide(color: Colors.grey),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          widget.data.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.rating.toDouble(),
                            );
                          }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback: (
                      FlTouchEvent event,
                      LineTouchResponse? response,
                    ) {
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
              ),
            ),
          ],
        ),
      ),
    );
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
                    : 'No hay notas para este día',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SideTitles _getBottomTitles() {
    return SideTitles(
      showTitles: true,
      interval: widget.timeFrame == 'Semanal' ? 1 : 3,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        if (index >= 0 && index < widget.data.length) {
          final date = widget.data[index].date;
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${date.day}/${date.month}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
        return const Text('');
      },
    );
  }

  String _formattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
