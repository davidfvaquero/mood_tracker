import 'package:flutter/material.dart';
import '../widgets/mood_chart.dart';
import '../models/mood_entry.dart';

class MoodChartsScreen extends StatelessWidget {
  const MoodChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Obtener datos reales de la base de datos
    final sampleData = [
      MoodEntry(rating: 8, date: DateTime.now().subtract(const Duration(days: 3))),
      MoodEntry(rating: 6, date: DateTime.now().subtract(const Duration(days: 2))),
      MoodEntry(rating: 9, date: DateTime.now().subtract(const Duration(days: 1))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: MoodChart(
                data: sampleData,
                timeFrame: 'Semanal',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: MoodChart(
                data: sampleData,
                timeFrame: 'Mensual',
              ),
            ),
          ],
        ),
      ),
    );
  }
}