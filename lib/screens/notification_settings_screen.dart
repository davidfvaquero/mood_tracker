import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            SnackBar(
              content: Text(AppLocalizations.of(context)!.notificationPermissionDenied),
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
        title: AppLocalizations.of(context)!.howAreYouFeelingToday,
        body: AppLocalizations.of(context)!.timeForDailyMoodCheck,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.dailyReminderScheduledFor(_selectedTime.format(context)),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dailyReminderCanceled),
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
          title: AppLocalizations.of(context)!.howAreYouFeelingToday,
          body: AppLocalizations.of(context)!.timeForDailyMoodCheck,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.reminderUpdatedFor(_selectedTime.format(context)),
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
          title: Text(AppLocalizations.of(context)!.notificationSettings),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationSettings),
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
                        AppLocalizations.of(context)!.dailyReminderTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.dailyReminderDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.enableReminders),
                    subtitle: Text(
                      _notificationsEnabled
                          ? AppLocalizations.of(context)!.remindersActive
                          : AppLocalizations.of(context)!.remindersInactive,
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
                        AppLocalizations.of(context)!.reminderSchedule,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.selectReminderTime,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(AppLocalizations.of(context)!.reminderTime),
                    subtitle: Text(_selectedTime.format(context)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectTime,
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
                        AppLocalizations.of(context)!.information,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.reminderInfoText,
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