import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../widgets/mood_chart.dart';

class MoodChartsScreen extends StatefulWidget {
  const MoodChartsScreen({super.key});

  @override
  State<MoodChartsScreen> createState() => _MoodChartsScreenState();
}

class _MoodChartsScreenState extends State<MoodChartsScreen> {
  final MoodStorage _storage = MoodStorage();
  late Future<List<MoodEntry>> _futureData;
  String _selectedTimeFrame = 'Semanal';

  @override
  void initState() {
    super.initState();
    _futureData = _storage.getAllEntries();
  }

  List<MoodEntry> _getFilteredData(List<MoodEntry> allData) {
    final days = _selectedTimeFrame == 'Semanal' ? 7 : 30;
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return allData
        .where((entry) => entry.date.isAfter(cutoff))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: FutureBuilder<List<MoodEntry>>(
        future: _futureData,
        builder: (context, snapshot) {
          // Manejo de estados de carga y error
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Verificar si hay datos
          final allData = snapshot.data;
          if (allData == null || allData.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          // Filtrar datos
          final filteredData = _getFilteredData(allData);

          return Column(
            children: [
              _buildTimeFrameSelector(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      filteredData.isEmpty
                          ? const Center(
                            child: Text('No hay datos en este rango'),
                          )
                          : MoodChart(
                            data: filteredData,
                            timeFrame: _selectedTimeFrame,
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(backgroundColor: Colors.grey[200]),
        segments: const [
          ButtonSegment(value: 'Semanal', label: Text('Semanal')),
          ButtonSegment(value: 'Mensual', label: Text('Mensual')),
        ],
        selected: {_selectedTimeFrame},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedTimeFrame = newSelection.first;
            _futureData = _storage.getAllEntries();
          });
        },
      ),
    );
  }
}
