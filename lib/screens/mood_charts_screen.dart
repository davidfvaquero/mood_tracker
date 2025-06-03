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

    return allData.where((entry) => entry.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: FutureBuilder<List<MoodEntry>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar datos'));
          }

          final allData = snapshot.data!;
          final filteredData = _getFilteredData(allData);
          final average = _calculateAverage(filteredData);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildTimeFrameSelector(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: const Text('Promedio de estado de ánimo'),
                      subtitle: Text(
                        'En los últimos ${_selectedTimeFrame == 'Semanal' ? 7 : 30} días',
                      ),
                      trailing: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          average.toStringAsFixed(1),
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      filteredData.isEmpty
                          ? const Center(
                            child: Text('No hay datos disponibles'),
                          )
                          : MoodChart(
                            data: filteredData,
                            timeFrame: _selectedTimeFrame,
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateAverage(List<MoodEntry> data) {
    if (data.isEmpty) return 0.0;
    final total = data.fold(0.0, (sum, entry) => sum + entry.rating);
    return total / data.length;
  }

  Widget _buildTimeFrameSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SegmentedButton<String>(
        selected: {_selectedTimeFrame},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedTimeFrame = newSelection.first;
            _futureData = _storage.getAllEntries();
          });
        },
        segments: const [
          ButtonSegment(value: 'Semanal', label: Text('Semanal')),
          ButtonSegment(value: 'Mensual', label: Text('Mensual')),
        ],
      ),
    );
  }
}
