import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mood_tracker/services/mood_storage.dart';
import '../models/mood_entry.dart';

class MoodRatingScreen extends StatefulWidget {
  const MoodRatingScreen({super.key});

  @override
  _MoodRatingScreenState createState() => _MoodRatingScreenState();
}

class _MoodRatingScreenState extends State<MoodRatingScreen> {
  final MoodStorage _storage = MoodStorage();
  int _selectedRating = 1; // Cambiamos el valor inicial a 1
  final TextEditingController _notesController = TextEditingController();

  void _saveMood() async {
    if (_selectedRating == 0) return;

    final today = DateTime.now();
    final existingEntry = await _storage.getEntryByDate(today);

    if (existingEntry != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.existingEntry),
              content: Text(
                AppLocalizations.of(context)!.overwriteEntry,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppLocalizations.of(context)!.overwrite),
                ),
              ],
            ),
      );
      if (confirm != true) return;
    }

    final entry = MoodEntry(
      rating: _selectedRating,
      date: today,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await _storage.saveOrUpdateMood(entry);

    _notesController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.moodSavedCorrectly)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.myCurrentMood)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.howAreYouFeeling,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  Text(
                    '$_selectedRating',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Slider(
                    value: _selectedRating.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (double value) {
                      setState(() {
                        _selectedRating = value.round();
                      });
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      ),
                      Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas opcionales',
                  hintText: '¿Quieres añadir algún comentario?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMood,
                child: const Text('Guardar Estado'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
