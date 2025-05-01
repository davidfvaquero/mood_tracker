import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker/services/mood_storage.dart';
import 'package:mood_tracker/themes/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones'),
            value: true,
            onChanged: (value) {}, // TODO: Implementar lógica
          ),
          Consumer<ThemeNotifier>(
            builder:
                (context, theme, child) => SwitchListTile(
                  title: const Text('Modo Oscuro'),
                  secondary: const Icon(Icons.dark_mode),
                  value: theme.isDarkMode,
                  onChanged: (value) => theme.toggleTheme(value),
                ),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacidad y Seguridad'),
          ),
          ElevatedButton(
            onPressed: () async {
              await MoodStorage().deleteDuplicates();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fechas duplicadas eliminadas')),
              );
            },
            child: const Text('Eliminar fechas duplicadas'),
          ),
        ],
      ),
    );
  }
}
