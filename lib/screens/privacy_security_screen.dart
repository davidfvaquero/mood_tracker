import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker/services/mood_storage.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y Seguridad')),
      body: Consumer<MoodStorage>(
        // Usar Consumer para acceder al provider
        builder:
            (context, moodStorage, child) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Eliminar todos los datos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Confirmar borrado'),
                              content: const Text(
                                '¿Estás seguro de que quieres eliminar TODOS los datos? '
                                'Esta acción no se puede deshacer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar todo'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await moodStorage.deleteAllData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Todos los datos han sido eliminados',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      ),
    );
  }
}
