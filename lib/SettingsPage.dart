import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/ProfilePage.dart';
import 'package:pro_2/providers/locale_provider.dart';
import 'package:pro_2/providers/theme_provider.dart';
import 'package:pro_2/localization/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _logout(BuildContext context, String langCode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.getText('logout', langCode)),
        content: Text(AppLocalizations.getText('logout_confirm', langCode)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.getText('cancel', langCode)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(AppLocalizations.getText('logout', langCode)),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add navigation to LoginPage here
            },
          ),
        ],
      ),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    final langCode = localeProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getText('settings', langCode)),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.onPrimary),
            title: Text(
              AppLocalizations.getText('profile', langCode),
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onPrimary,
            ),
            onTap: () => _goToProfile(context),
          ),
          Divider(color: theme.dividerColor),
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.onPrimary),
            title: Text(
              AppLocalizations.getText('language', langCode),
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(langCode == 'ar' ? 'العربية' : 'English'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onPrimary,
            ),
            onTap: () {
              final isArabic = langCode == 'ar';
              localeProvider.setLocale(Locale(isArabic ? 'en' : 'ar'));
            },
          ),
          Divider(color: theme.dividerColor),
          SwitchListTile(
            secondary: Icon(
              Icons.dark_mode,
              color: theme.colorScheme.onPrimary,
            ),
            title: Text(
              AppLocalizations.getText('dark_mode', langCode),
              style: theme.textTheme.bodyMedium,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          Divider(color: theme.dividerColor),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              AppLocalizations.getText('logout', langCode),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            onTap: () => _logout(context, langCode),
          ),
        ],
      ),
    );
  }
}
