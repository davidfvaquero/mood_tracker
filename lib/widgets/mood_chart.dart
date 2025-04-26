import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> data;
  final String timeFrame;

  const MoodChart({super.key, required this.data, required this.timeFrame});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Estado de ánimo - $timeFrame',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: data.length.toDouble(),
                  minY: 0,
                  maxY: 10,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    // Configuración Eje Y (izquierda)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                      ),
                    ),
                    // Configuración Eje X (abajo)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: timeFrame == 'Semanal' ? 1 : 3,
                        reservedSize: 20,
                        getTitlesWidget:
                            (value, meta) => Text(
                              'D${value.toInt()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                      ),
                    ),
                    // Ocultar otros ejes
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
                          data.asMap().entries.map((entry) {
                            return FlSpot(
                              (entry.key + 1).toDouble(),
                              entry.value.rating.toDouble(),
                            );
                          }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
