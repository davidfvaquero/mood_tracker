import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/mood_chart.dart';
import '../models/mood_entry.dart';

class MoodChartsScreen extends StatefulWidget {
  const MoodChartsScreen({super.key});

  @override
  State<MoodChartsScreen> createState() => _MoodChartsScreenState();
}

class _MoodChartsScreenState extends State<MoodChartsScreen> {
  String _selectedTimeFrame = 'Semanal';
  late final List<MoodEntry> sampleData;

  @override
  void initState() {
    super.initState();
    sampleData = _generateSampleData();
  }

  List<MoodEntry> _generateSampleData() {
    final random = Random();
    return List.generate(30, (index) {
      return MoodEntry(
        rating: random.nextInt(10) + 1, // 1-10
        date: DateTime.now().subtract(Duration(days: 29 - index)),
      );
    });
  }

  List<MoodEntry> _getFilteredData() {
    if (_selectedTimeFrame == 'Semanal') {
      return sampleData.sublist(sampleData.length - 7);
    }
    return sampleData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTimeFrameSelector(),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: MoodChart(
                  data: _getFilteredData(),
                  timeFrame: _selectedTimeFrame,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Semanal', label: Text('Últimos 7 días')),
        ButtonSegment(value: 'Mensual', label: Text('Últimos 30 días')),
      ],
      selected: {_selectedTimeFrame},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedTimeFrame = newSelection.first;
        });
      },
    );
  }
}
