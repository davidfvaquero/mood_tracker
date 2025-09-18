import 'package:flutter/material.dart';
import 'package:mood_tracker/models/enhanced_mood_entry.dart';
import 'package:mood_tracker/services/enhanced_mood_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EnhancedMoodRatingScreen extends StatefulWidget {
  const EnhancedMoodRatingScreen({super.key});

  @override
  State<EnhancedMoodRatingScreen> createState() => _EnhancedMoodRatingScreenState();
}

class _EnhancedMoodRatingScreenState extends State<EnhancedMoodRatingScreen> {
  final EnhancedMoodStorage _storage = EnhancedMoodStorage();
  final TextEditingController _notesController = TextEditingController();
  
  int _overallMood = 5;
  int _energyLevel = 3;
  int _stressLevel = 3;
  Map<String, int> _selectedEmotions = {};
  List<String> _selectedActivities = [];
  List<String> _selectedTriggers = [];
  String? _location;
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitMoodEntry() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final entry = EnhancedMoodEntry(
        date: DateTime.now(),
        overallMood: _overallMood,
        emotions: Map.from(_selectedEmotions),
        activities: List.from(_selectedActivities),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        energyLevel: _energyLevel,
        stressLevel: _stressLevel,
        triggers: List.from(_selectedTriggers),
        location: _location,
        isQuickEntry: false,
      );

      await _storage.addMoodEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.moodStateRegisteredSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSaving(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildMoodSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mood, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.generalMoodState,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('😢', style: TextStyle(fontSize: 24)),
                Expanded(
                  child: Slider(
                    value: _overallMood.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _overallMood.toString(),
                    onChanged: (value) {
                      setState(() {
                        _overallMood = value.round();
                      });
                    },
                  ),
                ),
                const Text('😊', style: TextStyle(fontSize: 24)),
              ],
            ),
            Center(
              child: Text(
                AppLocalizations.of(context)!.scoreWithValue(_overallMood),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.specificEmotions,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.selectEmotionsAndIntensity,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EmotionType.all.map((emotion) {
                final isSelected = _selectedEmotions.containsKey(emotion);
                final intensity = _selectedEmotions[emotion] ?? 3;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedEmotions.remove(emotion);
                      } else {
                        _selectedEmotions[emotion] = 3;
                      }
                    });
                  },
                  onLongPress: () {
                    if (isSelected) {
                      _showIntensityDialog(emotion, intensity);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          EmotionType.emotionIcons[emotion] ?? '😐',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          emotion,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              intensity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedEmotions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.holdToAdjustIntensity,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyStressSliders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.battery_charging_full, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.energyAndStress,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Energy Level
            Text(AppLocalizations.of(context)!.energyLevel(_energyLevel)),
            Row(
              children: [
                const Text('😴'),
                Expanded(
                  child: Slider(
                    value: _energyLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        _energyLevel = value.round();
                      });
                    },
                  ),
                ),
                const Text('⚡'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stress Level
            Text(AppLocalizations.of(context)!.stressLevel(_stressLevel)),
            Row(
              children: [
                const Text('😌'),
                Expanded(
                  child: Slider(
                    value: _stressLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        _stressLevel = value.round();
                      });
                    },
                  ),
                ),
                const Text('😰'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_activity, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.activities,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.selectActivitiesYouDid,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityType.all.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedActivities.remove(activity);
                      } else {
                        _selectedActivities.add(activity);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ActivityType.activityIcons[activity] ?? '📋',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note_add, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.additionalNotes,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.specificMoodReminder,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntensityDialog(String emotion, int currentIntensity) {
    showDialog(
      context: context,
      builder: (context) {
        int tempIntensity = currentIntensity;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Text(EmotionType.emotionIcons[emotion] ?? '😐'),
                  const SizedBox(width: 8),
                  Text(emotion),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Intensidad: $tempIntensity/5'),
                  Slider(
                    value: tempIntensity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) {
                      setDialogState(() {
                        tempIntensity = value.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedEmotions[emotion] = tempIntensity;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recordMoodTitle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMoodSlider(),
            const SizedBox(height: 16),
            _buildEmotionSelector(),
            const SizedBox(height: 16),
            _buildEnergyStressSliders(),
            const SizedBox(height: 16),
            _buildActivitySelector(),
            const SizedBox(height: 16),
            _buildNotesSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitMoodEntry,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        AppLocalizations.of(context)!.saveMoodTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}