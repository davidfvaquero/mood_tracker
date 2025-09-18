import 'package:flutter/material.dart';
import 'package:mood_tracker/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getNotificationSettings();
    setState(() {
      _notificationsEnabled = settings['enabled'] ?? false;
      _selectedTime = TimeOfDay(
        hour: settings['hour'] ?? 20,
        minute: settings['minute'] ?? 0,
      );
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (enabled) {
      // Request permissions first
      final permissionGranted = await _notificationService.requestPermissions();
      
      if (!permissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permisos de notificación denegados. Ve a configuración para habilitarlos.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Schedule the notification with the current time
      await _notificationService.scheduleDailyMoodReminder(
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Debug pending notifications
      await _notificationService.debugPendingNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recordatorio diario programado para las ${_selectedTime.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Cancel notifications
      await _notificationService.cancelDailyReminder();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio diario cancelado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });

      // If notifications are enabled, update the schedule
      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyMoodReminder(
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Debug pending notifications
        await _notificationService.debugPendingNotifications();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recordatorio actualizado para las ${_selectedTime.format(context)}',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración de Notificaciones'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Notificaciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recordatorio Diario',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recibe un recordatorio diario para registrar tu estado de ánimo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Habilitar recordatorios'),
                    subtitle: Text(
                      _notificationsEnabled
                          ? 'Los recordatorios están activos'
                          : 'Los recordatorios están desactivados',
                    ),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    secondary: Icon(
                      _notificationsEnabled
                          ? Icons.notifications
                          : Icons.notifications_off,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Horario del Recordatorio',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona la hora en que quieres recibir el recordatorio',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Hora del recordatorio'),
                    subtitle: Text(_selectedTime.format(context)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectTime,
                    enabled: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Información',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Los recordatorios se enviarán todos los días a la hora seleccionada\n'
                    '• Puedes cambiar la hora en cualquier momento\n'
                    '• Si desactivas los recordatorios, se cancelarán todas las notificaciones programadas\n'
                    '• Asegúrate de tener los permisos de notificación habilitados en tu dispositivo',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}