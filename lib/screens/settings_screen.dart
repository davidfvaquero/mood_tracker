import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker/themes/theme_provider.dart';
import 'package:mood_tracker/widgets/language_selector.dart';
import 'privacy_security_screen.dart';
import 'notification_settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: ListView(
        children: [
          Consumer<ThemeNotifier>(
            builder:
                (context, theme, child) => SwitchListTile(
                  title: Text(localizations.darkMode),
                  subtitle: Text(localizations.darkModeDescription),
                  secondary: const Icon(Icons.dark_mode),
                  value: theme.isDarkMode,
                  onChanged: (value) => theme.toggleTheme(value),
                ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(localizations.notifications),
            subtitle: Text(localizations.notificationsDescription),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.language),
            subtitle: Text(localizations.languageDescription),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ),
                ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(localizations.privacySecurity),
            subtitle: Text(localizations.privacySecurityDescription),
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
