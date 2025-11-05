// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../app_localizations.dart';
import '../edit_profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final loc = AppLocalizations.of(context);

    final fb_auth.User? currentUser = fb_auth.FirebaseAuth.instance.currentUser;

    // --- Ouvre la page d'aide/support (ou email) ---
    Future<void> _openHelp() async {
      // remplace '' par un url
      const supportUrl = '';
      final uri = Uri.parse(supportUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // fallback: tenter mailto
        final mailto = Uri(
          scheme: 'mailto',
          path: 'support@example.com',
          queryParameters: {'subject': 'Support Recettes Mondiales'},
        );
        if (await canLaunchUrl(mailto)) {
          await launchUrl(mailto);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d’ouvrir la page de support'),
            ),
          );
        }
      }
    }

    // --- Partager l'application ---
    void _shareApp() {
      // Remplace par ton message et lien réel (Play Store / App Store)
      const message =
          'Découvre Recettes Mondiales — des recettes du monde entier !\n\n'
          'Télécharge : https://example.com/app';
      Share.share(message, subject: 'Recettes Mondiales');
    }

    // --- Vider le cache (SharedPreferences + image cache) ---
    Future<void> _clearCache() async {
      try {
        // Clear shared prefs keys used by app (ou clear all)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Clear Flutter image cache
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cache vidé avec succès')));
      } catch (e) {
        debugPrint('Erreur clear cache: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de vider le cache')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header avec photo de profil
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green, AppColors.green.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            currentUser?.photoURL != null
                                ? Image.network(
                                  currentUser!.photoURL!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser?.displayName ?? 'Arabi',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ?? 'email@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bouton Éditer profil
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier le profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white.withOpacity(0.15)
                            : Colors.white,
                        foregroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu des paramètres
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Section Notifications
                  _ModernSettingsCard(
                    icon: Icons.notifications_rounded,
                    iconColor: Colors.orange,
                    title: loc.notifications,
                    children: [
                      _ModernSwitchTile(
                        title: loc.enableNotifications,
                        subtitle: 'Recevoir les alertes',
                        value: notifProvider.enabled,
                        onChanged: notifProvider.toggle,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section Apparence
                  _ModernSettingsCard(
                    icon: Icons.palette_rounded,
                    iconColor: Colors.purple,
                    title: loc.appearance,
                    children: [
                      _ModernSwitchTile(
                        title: loc.darkMode,
                        subtitle: 'Mode sombre',
                        value: themeProvider.isDark,
                        onChanged: (value) => themeProvider.setDark(value),
                      ),
                      _ModernListTile(
                        icon: Icons.language_rounded,
                        title: loc.language,
                        subtitle: _getLocaleName(
                          localeProvider.locale.languageCode,
                        ),
                        onTap:
                            () => _showLanguageDialog(
                              context,
                              localeProvider,
                              loc,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section Sécurité
                  _ModernSettingsCard(
                    icon: Icons.security_rounded,
                    iconColor: Colors.red,
                    title: loc.security,
                    children: [
                      _ModernListTile(
                        icon: Icons.lock_rounded,
                        title: loc.changePassword,
                        subtitle: 'Modifier votre mot de passe',
                        onTap: () {
                          // TODO: Ajouter logique de changement de mot de passe
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section À propos (avec Help / Share / Clear Cache)
                  _ModernSettingsCard(
                    icon: Icons.info_rounded,
                    iconColor: Colors.blue,
                    title: loc.about,
                    children: [
                      _ModernListTile(
                        icon: Icons.verified_rounded,
                        title: loc.version,
                        subtitle: '1.0.0',
                        onTap: null,
                      ),
                      _ModernListTile(
                        icon: Icons.help_outline,
                        title: loc.helpSupport,
                        subtitle: 'Centre d\'aide & contact',
                        onTap: _openHelp,
                      ),
                      _ModernListTile(
                        icon: Icons.share_rounded,
                        title: loc.shareApp,
                        subtitle: 'Partager avec vos amis',
                        onTap: _shareApp,
                      ),
                      _ModernListTile(
                        icon: Icons.cleaning_services_rounded,
                        title: loc.clearCache,
                        subtitle: 'Libérer de l\'espace local',
                        onTap: () async {
                          // confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Vider le cache'),
                                  content: const Text(
                                    'Voulez-vous vraiment vider le cache et les préférences locales ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Confirmer'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await _clearCache();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bouton Déconnexion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await fb_auth.FirebaseAuth.instance.signOut();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('currentUser');

                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          debugPrint("Erreur lors de la déconnexion : $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Impossible de se déconnecter"),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(loc.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red.withOpacity(0.2)
                            : Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.language,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _LanguageOption(
                  flag: '🇫🇷',
                  language: 'Français',
                  selected: localeProvider.locale.languageCode == 'fr',
                  onTap: () {
                    localeProvider.setLocale('fr');
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageOption(
                  flag: '🇬🇧',
                  language: 'English',
                  selected: localeProvider.locale.languageCode == 'en',
                  onTap: () {
                    localeProvider.setLocale('en');
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageOption(
                  flag: '🇸🇦',
                  language: 'العربية',
                  selected: localeProvider.locale.languageCode == 'ar',
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

// Widget Carte de paramètres moderne
class _ModernSettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _ModernSettingsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

// Widget ListTile moderne
class _ModernListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _ModernListTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: theme.textTheme.titleMedium?.color)),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              )
              : null,
      trailing:
          onTap != null
              ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.iconTheme.color?.withOpacity(0.6),
              )
              : null,
      onTap: onTap,
    );
  }
}

// Widget Switch moderne
class _ModernSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              )
              : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.green,
    );
  }
}

// Widget Option de langue
class _LanguageOption extends StatelessWidget {
  final String flag;
  final String language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected 
                    ? AppColors.green 
                    : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
              ),
            ),
            const Spacer(),
            if (selected) Icon(Icons.check_circle, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}
