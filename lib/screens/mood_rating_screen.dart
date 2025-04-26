import 'package:flutter/material.dart';
import 'package:mood_tracker/services/mood_storage.dart';
import '../models/mood_entry.dart';

class MoodRatingScreen extends StatefulWidget {
  const MoodRatingScreen({super.key});

  @override
  _MoodRatingScreenState createState() => _MoodRatingScreenState();
}

class _MoodRatingScreenState extends State<MoodRatingScreen> {
  final MoodStorage _storage =MoodStorage();

  int _selectedRating = 0;

  void _saveMood() async{
    if (_selectedRating == 0) return;
    
    final entry = MoodEntry(
      rating: _selectedRating,
      date: DateTime.now(),
    );
    
    await _storage.saveMood(entry);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estado guardado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Estado Actual')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Cómo te sientes hoy?',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: List.generate(10, (index) {
                final rating = index + 1;
                return ChoiceChip(
                  label: Text('$rating'),
                  selected: _selectedRating == rating,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRating = selected ? rating : 0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveMood,
              child: const Text('Guardar Estado'),
            ),
          ],
        ),
      ),
    );
  }
}