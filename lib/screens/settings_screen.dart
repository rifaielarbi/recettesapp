import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../app_localizations.dart';
import '../edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          // Profil
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(loc.profile, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(loc.editProfile),
            subtitle: Text('${loc.name}, ${loc.email}, ${loc.photo}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          const Divider(),

          // Notifications
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(loc.notifications, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: Text(loc.enableNotifications),
            value: notifProvider.enabled,
            onChanged: (val) => notifProvider.toggle(val),
          ),
          const Divider(),

          // Apparence
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(loc.appearance, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: Text(loc.darkMode),
            value: theme.isDark,
            onChanged: (_) => theme.toggle(),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.language),
            subtitle: Text(
              localeProvider.locale.languageCode == 'fr'
                  ? 'Français'
                  : localeProvider.locale.languageCode == 'en'
                  ? 'English'
                  : 'العربية',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
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
            },
          ),
          const Divider(),

          // Sécurité
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(loc.security, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(loc.changePassword),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const Divider(),

          // À propos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(loc.about, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(loc.version),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(loc.helpSupport),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}