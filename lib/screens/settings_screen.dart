import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker/themes/theme_provider.dart';
import 'package:mood_tracker/services/notification_service.dart';
import 'privacy_security_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _testNotification(BuildContext context) async {
    final notificationService = NotificationService();
    
    // Request permissions first
    final permissionGranted = await notificationService.requestPermissions();
    
    if (permissionGranted) {
      await notificationService.showTestNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Notificación de prueba enviada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permisos de notificación denegados'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testScheduledNotification(BuildContext context) async {
    final notificationService = NotificationService();
    
    // Request permissions first
    final permissionGranted = await notificationService.requestPermissions();
    
    if (permissionGranted) {
      await notificationService.showTestScheduledNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Notificación programada para dentro de 10 segundos!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permisos de notificación denegados'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          Consumer<ThemeNotifier>(
            builder:
                (context, theme, child) => SwitchListTile(
                  title: const Text('Modo Oscuro'),
                  secondary: const Icon(Icons.dark_mode),
                  value: theme.isDarkMode,
                  onChanged: (value) => theme.toggleTheme(value),
                ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Probar Notificaciones'),
            subtitle: const Text('Enviar una notificación de prueba'),
            onTap: () => _testNotification(context),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Probar Notificación Programada'),
            subtitle: const Text('Notificación en 10 segundos'),
            onTap: () => _testScheduledNotification(context),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Configurar Recordatorios'),
            subtitle: const Text('Programa notificaciones diarias'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Configurar Recordatorios'),
            subtitle: const Text('Programar notificaciones diarias'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacidad y Seguridad'),
            onTap:
                () => Navigator.push(
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
