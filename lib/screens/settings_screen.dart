import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker/themes/theme_provider.dart';
import 'privacy_security_screen.dart'; // Añade esta importación

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
            builder: (context, theme, child) => SwitchListTile(
              title: const Text('Modo Oscuro'),
              secondary: const Icon(Icons.dark_mode),
              value: theme.isDarkMode,
              onChanged: (value) => theme.toggleTheme(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacidad y Seguridad'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacySecurityScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}