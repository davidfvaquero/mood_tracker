import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              localizations.languageDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // System Default Option
            FutureBuilder<bool>(
              future: localeProvider.isUsingSystemDefault,
              builder: (context, snapshot) {
                final isUsingSystemDefault = snapshot.data ?? false;
                
                return RadioListTile<String>(
                  title: Text(localizations.systemDefault),
                  subtitle: Text(
                    '${localizations.systemDefault} (${LocaleProvider.localeNames[localeProvider.deviceLanguageCode] ?? 'English'})',
                  ),
                  value: 'system',
                  groupValue: isUsingSystemDefault ? 'system' : localeProvider.locale?.languageCode,
                  onChanged: (value) async {
                    if (value == 'system') {
                      await localeProvider.setSystemLocale();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localizations.languageChanged(localizations.systemDefault),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
            
            const Divider(),
            
            // Language Options
            ...LocaleProvider.supportedLocales.map((locale) {
              final languageName = LocaleProvider.localeNames[locale.languageCode] ?? locale.languageCode;
              
              return RadioListTile<String>(
                title: Text(languageName),
                subtitle: Text(locale.languageCode.toUpperCase()),
                value: locale.languageCode,
                groupValue: localeProvider.locale?.languageCode,
                onChanged: (value) async {
                  if (value != null) {
                    await localeProvider.setLocale(Locale(value));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.languageChanged(languageName),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectLanguage),
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              LanguageSelector(),
            ],
          ),
        ),
      ),
    );
  }
}