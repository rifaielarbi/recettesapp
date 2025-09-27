// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';
import '../edit_profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final loc = AppLocalizations.of(context);

    final fb_auth.User? currentUser = fb_auth.FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings), centerTitle: true),
      body: ListView(
        children: [
          _buildSectionTitle(loc.profile),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: Text(loc.editProfile),
            subtitle: Text(
              '${currentUser?.displayName ?? loc.name}, ${currentUser?.email ?? loc.email}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          const Divider(),

          _buildSectionTitle(loc.notifications),
          SwitchListTile(
            title: Text(loc.enableNotifications),
            value: notifProvider.enabled,
            onChanged: notifProvider.toggle,
          ),
          const Divider(),

          _buildSectionTitle(loc.appearance),
          SwitchListTile(
            title: Text(loc.darkMode),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggle(),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.orange),
            title: Text(loc.language),
            subtitle: Text(_getLocaleName(localeProvider.locale.languageCode)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(context, localeProvider, loc),
          ),
          const Divider(),

          _buildSectionTitle(loc.security),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.red),
            title: Text(loc.changePassword),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Ajouter logique de changement de mot de passe
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(loc.logout),
            onTap: () async {
              try {
                await fb_auth.FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('currentUser');

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("Erreur lors de la déconnexion : $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Impossible de se déconnecter")),
                );
              }
            },
          ),
          const Divider(),

          _buildSectionTitle(loc.about),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.green),
            title: Text(loc.version),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.purple),
            title: Text(loc.helpSupport),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.teal),
            title: Text(loc.shareApp),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services, color: Colors.brown),
            title: Text(loc.clearCache),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  String _getLocaleName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return code;
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleProvider localeProvider,
    AppLocalizations loc,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(loc.language),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Français'),
                  onTap: () {
                    localeProvider.setLocale('fr');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    localeProvider.setLocale('en');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('العربية'),
                  onTap: () {
                    localeProvider.setLocale('ar');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
