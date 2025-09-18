import 'package:flutter/material.dart';
import 'package:mood_tracker/services/enhanced_mood_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuickMoodCheckInWidget extends StatefulWidget {
  final VoidCallback? onMoodSaved;
  
  const QuickMoodCheckInWidget({
    super.key,
    this.onMoodSaved,
  });

  @override
  State<QuickMoodCheckInWidget> createState() => _QuickMoodCheckInWidgetState();
}

class _QuickMoodCheckInWidgetState extends State<QuickMoodCheckInWidget> {
  final EnhancedMoodStorage _storage = EnhancedMoodStorage();
  int _selectedMood = 5;
  bool _isSubmitting = false;

  final List<String> _moodEmojis = [
    '😢', '😟', '😕', '😐', '🙂', '😊', '😄', '😃', '😁', '🤩'
  ];

  final List<String> _moodLabels = [
    'Terrible', 'Muy mal', 'Mal', 'Neutro', 'Bien', 
    'Muy bien', 'Genial', 'Excelente', 'Increíble', 'Eufórico'
  ];

  List<String> _getMoodLabels(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.terrible,
      localizations.veryBad,
      localizations.bad,
      localizations.neutral,
      localizations.good,
      localizations.veryGood,
      localizations.great,
      localizations.excellent,
      localizations.amazing,
      localizations.euphoric,
    ];
  }

  Future<void> _saveQuickMood() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _storage.addQuickMoodEntry(
        overallMood: _selectedMood,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_moodEmojis[_selectedMood - 1]),
                const SizedBox(width: 8),
                const Text('¡Estado de ánimo guardado!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        widget.onMoodSaved?.call();
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

  void _showQuickCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.speed, color: Colors.blue),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.quickCheckin),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.howDoYouFeelNow),
              const SizedBox(height: 20),
              
              // Mood emoji display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _moodEmojis[_selectedMood - 1],
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _moodLabels[_selectedMood - 1],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_selectedMood/10',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mood slider
              Slider(
                value: _selectedMood.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) {
                  setDialogState(() {
                    _selectedMood = value.round();
                  });
                },
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '😢 ${AppLocalizations.of(context)!.veryBad}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.veryGood} 🤩',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () async {
                await _saveQuickMood();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.quickCheckin,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Registra tu estado de ánimo de forma rápida',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick mood buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 5; i++)
                  _buildQuickMoodButton(
                    mood: i * 2, // 2, 4, 6, 8, 10
                    emoji: _moodEmojis[i * 2 - 1],
                    label: _moodLabels[i * 2 - 1],
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // More detailed button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showQuickCheckInDialog,
                icon: const Icon(Icons.tune),
                label: Text(AppLocalizations.of(context)!.customSelection),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMoodButton({
    required int mood,
    required String emoji,
    required String label,
  }) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedMood = mood;
        });
        await _saveQuickMood();
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuickMoodCheckInScreen extends StatelessWidget {
  const QuickMoodCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.quickCheckin),
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            QuickMoodCheckInWidget(),
            const SizedBox(height: 24),
            Card(
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'About Quick Check-in',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Record your mood in seconds\n'
                      '• Perfect for multiple daily entries\n'
                      '• Use quick buttons or customize your selection\n'
                      '• You can add more details later if you want',
                      style: TextStyle(height: 1.5),
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