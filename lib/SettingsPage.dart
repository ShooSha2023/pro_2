import 'package:flutter/material.dart';
import 'package:pro_2/login_page.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/ProfilePage.dart';
import 'package:pro_2/providers/locale_provider.dart';
import 'package:pro_2/providers/theme_provider.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/services/token_manager.dart';
import 'package:pro_2/services/api.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context, String langCode) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.getText('logout', langCode)),
        content: Text(AppLocalizations.getText('logout_confirm', langCode)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.getText('cancel', langCode)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(AppLocalizations.getText('logout', langCode)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await TokenManager.clearToken();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  Future<void> _deleteAccount(BuildContext context, String langCode) async {
    final passwordController = TextEditingController();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.getText('delete_account', langCode)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.getText('delete_confirm', langCode)),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.getText('password', langCode),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.getText('cancel', langCode)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              AppLocalizations.getText('delete', langCode),
              style: const TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final password = passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.getText('enter_password', langCode)),
        ),
      );
      return;
    }

    final result = await ApiService.deleteAccount(password);

    if (result['success']) {
      await TokenManager.clearToken();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error'] ?? 'Error')));
    }
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
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text(
              AppLocalizations.getText('حذف الحساب', langCode),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            onTap: () => _deleteAccount(context, langCode),
          ),
          Divider(color: theme.dividerColor),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              AppLocalizations.getText('تسجيل الخروج', langCode),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            onTap: () => _logout(context, langCode),
          ),
        ],
      ),
    );
  }
}
