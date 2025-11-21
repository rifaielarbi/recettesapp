// settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'support_page.dart';
import '../app_localizations.dart';
import '../edit_profile_screen.dart';
import '../providers/my_auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final loc = AppLocalizations.of(context);

    final fb_auth.User? currentUser =
        fb_auth.FirebaseAuth.instance.currentUser;

    // ---------- HELP ----------
    void _openHelp() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupportPage()),
      );
    }

    // ---------- SHARE ----------
    Future<void> _shareApp() async {
      try {
        await Share.share(
          "Découvrez l'application Recettes Mondiales !\nhttps://example.com",
          subject: "Recettes Mondiales",
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur lors du partage: ${e.toString()}"),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // ---------- CLEAR CACHE ----------
    Future<void> _clearCache() async {
      try {
        // Vider SharedPreferences (sauf les préférences importantes)
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        // Garder les préférences importantes comme les comptes sauvegardés
        final importantKeys = ['savedAccounts', 'notifications_enabled'];
        for (final key in keys) {
          if (!importantKeys.contains(key)) {
            await prefs.remove(key);
          }
        }

        // Vider le cache d'images
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        
        // Forcer le garbage collection si possible
        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cache vidé avec succès"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur lors du nettoyage: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // ---------- DONATION ----------
    Future<void> _makeDonation() async {
      try {
        final url = Uri.parse("https://www.paypal.com/donate");

        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Impossible d'ouvrir la page de don. Veuillez vérifier votre connexion internet."),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur lors de l'ouverture: ${e.toString()}"),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // ---------- CHANGE PASSWORD ----------
    Future<void> _showChangePasswordDialog(BuildContext context) async {
      final currentPasswordController = TextEditingController();
      final newPasswordController = TextEditingController();
      final confirmPasswordController = TextEditingController();
      bool obscureCurrent = true;
      bool obscureNew = true;
      bool obscureConfirm = true;

      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text("Changer le mot de passe"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: "Mot de passe actuel",
                        suffixIcon: IconButton(
                          icon: Icon(obscureCurrent ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: "Nouveau mot de passe",
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: "Confirmer le nouveau mot de passe",
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Annuler"),
                ),
                TextButton(
                  onPressed: () async {
                    final currentPwd = currentPasswordController.text;
                    final newPwd = newPasswordController.text;
                    final confirmPwd = confirmPasswordController.text;

                    if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Veuillez remplir tous les champs")),
                      );
                      return;
                    }

                    if (newPwd.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Le nouveau mot de passe doit contenir au moins 8 caractères")),
                      );
                      return;
                    }

                    if (newPwd != confirmPwd) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
                      );
                      return;
                    }

                    try {
                      // Réauthentifier avec le mot de passe actuel
                      final email = currentUser?.email;
                      if (email == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Erreur: email non disponible")),
                        );
                        return;
                      }

                      final credential = fb_auth.EmailAuthProvider.credential(
                        email: email,
                        password: currentPwd,
                      );
                      await currentUser!.reauthenticateWithCredential(credential);

                      // Changer le mot de passe
                      await currentUser!.updatePassword(newPwd);

                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mot de passe changé avec succès"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } on fb_auth.FirebaseAuthException catch (e) {
                      String errorMsg = "Erreur lors du changement de mot de passe";
                      if (e.code == 'wrong-password') {
                        errorMsg = "Mot de passe actuel incorrect";
                      } else if (e.code == 'weak-password') {
                        errorMsg = "Le nouveau mot de passe est trop faible";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur: ${e.toString()}"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text("Changer"),
                ),
              ],
            ),
          );
        },
      );

      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER PROFIL
            SliverToBoxAdapter(
              child: _buildHeader(context, currentUser),
            ),

            // CONTENU
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // NOTIFICATIONS
                  _ModernSettingsCard(
                    icon: Icons.notifications_rounded,
                    iconColor: Colors.orange,
                    title: loc.notifications,
                    children: [
                      _ModernSwitchTile(
                        title: loc.enableNotifications,
                        subtitle: "Recevoir les alertes",
                        value: notifProvider.enabled,
                        onChanged: notifProvider.toggle,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // APPARENCE
                  _ModernSettingsCard(
                    icon: Icons.palette_rounded,
                    iconColor: Colors.purple,
                    title: loc.appearance,
                    children: [
                      _ModernSwitchTile(
                        title: loc.darkMode,
                        subtitle: "Mode sombre",
                        value: themeProvider.isDark,
                        onChanged: themeProvider.setDark,
                      ),
                      _ModernListTile(
                        icon: Icons.language,
                        title: loc.language,
                        subtitle:
                        _getLocaleName(localeProvider.locale.languageCode),
                        onTap: () => _showLanguageDialog(
                            context, localeProvider, loc),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // SÉCURITÉ
                  _ModernSettingsCard(
                    icon: Icons.security_rounded,
                    iconColor: Colors.red,
                    title: loc.security,
                    children: [
                      _ModernListTile(
                        icon: Icons.lock_rounded,
                        title: loc.changePassword,
                        subtitle: "Changer votre mot de passe",
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // DONATION + COINS
                  _DonationCard(onDonate: _makeDonation),

                  const SizedBox(height: 16),

                  // ABOUT
                  _ModernSettingsCard(
                    icon: Icons.info_rounded,
                    iconColor: Colors.blue,
                    title: loc.about,
                    children: [
                      _ModernListTile(
                        icon: Icons.verified,
                        title: loc.version,
                        subtitle: "1.0.0",
                      ),
                      _ModernListTile(
                        icon: Icons.help,
                        title: loc.helpSupport,
                        subtitle: "Centre d'aide & contact",
                        onTap: _openHelp,
                      ),
                      _ModernListTile(
                        icon: Icons.share,
                        title: loc.shareApp,
                        subtitle: "Partager l'application",
                        onTap: _shareApp,
                      ),
                      _ModernListTile(
                        icon: Icons.cleaning_services,
                        title: loc.clearCache,
                        subtitle: "Vider le cache",
                        onTap: () async {
                          final ok = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Vider le cache ?"),
                              content: const Text(
                                  "Voulez-vous vraiment vider le cache ?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Confirmer"),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) _clearCache();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // LOGOUT
                  _buildLogoutButton(context, loc),

                  const SizedBox(height: 80),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ========= HEADER =========
  Widget _buildHeader(BuildContext context, fb_auth.User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green, AppColors.green.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // PHOTO
          CircleAvatar(
            radius: 50,
            backgroundImage:
            user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),

          const SizedBox(height: 16),

          Text(
            user?.displayName ?? "Arabi",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            user?.email ?? "email@example.com",
            style: TextStyle(color: Colors.white.withOpacity(.9)),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            icon: const Icon(Icons.edit),
            label: const Text("Modifier le profil"),
          ),
        ],
      ),
    );
  }

  // ========= LOGOUT BUTTON =========
  Widget _buildLogoutButton(BuildContext context, AppLocalizations loc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background =
        isDark ? theme.colorScheme.errorContainer.withOpacity(0.3) : Colors.red.shade50;
    final foreground = isDark ? theme.colorScheme.error : Colors.red;

    return ElevatedButton.icon(
      onPressed: () async {
        await fb_auth.FirebaseAuth.instance.signOut();
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("currentUser");

        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
        );
      },
      icon: Icon(Icons.logout, color: foreground),
      label: Text(
        loc.logout,
        style: theme.textTheme.titleMedium?.copyWith(color: foreground),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ========= LANGUES =========
  String _getLocaleName(String code) {
    switch (code) {
      case "fr":
        return "Français";
      case "en":
        return "English";
      case "ar":
        return "العربية";
      default:
        return code;
    }
  }

  void _showLanguageDialog(
      BuildContext context, LocaleProvider provider, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              flag: "🇫🇷",
              language: "Français",
              selected: provider.locale.languageCode == "fr",
              onTap: () {
                provider.setLocale("fr");
                Navigator.pop(ctx);
              },
            ),
            _LanguageOption(
              flag: "🇬🇧",
              language: "English",
              selected: provider.locale.languageCode == "en",
              onTap: () {
                provider.setLocale("en");
                Navigator.pop(ctx);
              },
            ),
            _LanguageOption(
              flag: "🇸🇦",
              language: "العربية",
              selected: provider.locale.languageCode == "ar",
              onTap: () {
                provider.setLocale("ar");
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// ============================= WIDGETS CUSTOM ==============================
// --------------------------------------------------------------------------

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
    final titleColor = theme.textTheme.titleMedium?.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(theme.brightness == Brightness.dark
                ? 0.25
                : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

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
    final iconColor = theme.iconTheme.color ?? theme.colorScheme.primary;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: (theme.textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.8),
    );
    final trailingColor = iconColor.withOpacity(0.6);

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(title, style: titleStyle),
      subtitle: subtitle != null ? Text(subtitle!, style: subtitleStyle) : null,
      trailing: onTap != null
          ? Icon(Icons.arrow_forward_ios, size: 16, color: trailingColor)
          : null,
      onTap: onTap,
    );
  }
}

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
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: (theme.textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.8),
    );

    return SwitchListTile(
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!, style: subtitleStyle) : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.green,
      inactiveThumbColor: theme.disabledColor,
      inactiveTrackColor: theme.disabledColor.withOpacity(0.3),
    );
  }
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseBorder = theme.dividerColor.withOpacity(isDark ? 0.6 : 0.3);
    final backgroundColor = selected
        ? AppColors.green.withOpacity(isDark ? 0.2 : 0.1)
        : (isDark ? theme.colorScheme.surface.withOpacity(0.4) : null);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.green : baseBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              language,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? AppColors.green
                    : theme.textTheme.bodyLarge?.color,
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

class _DonationCard extends StatelessWidget {
  final VoidCallback onDonate;
  final int coinBalance;

  const _DonationCard({
    required this.onDonate,
    this.coinBalance = 320,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final donationBg = isDark
        ? theme.colorScheme.primaryContainer.withOpacity(0.35)
        : const Color(0xFFFFE4B5);
    final donationFg = isDark
        ? theme.colorScheme.onPrimaryContainer
        : Colors.black87;
    final storeBg = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
        : const Color(0xFFFFF0F5);
    final storeBorder = isDark
        ? theme.colorScheme.outline.withOpacity(0.5)
        : Colors.pinkAccent;
    final balanceBg = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Column(
      children: [
        // BOUTON DONATION
        ElevatedButton.icon(
          onPressed: onDonate,
          icon: Icon(Icons.card_giftcard, color: donationFg),
          label: Text(
            "Make a Donation",
            style: theme.textTheme.titleMedium?.copyWith(
              color: donationFg,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: donationBg,
            foregroundColor: donationFg,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // COIN STORE
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: storeBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: storeBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "💰 Coin Store",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),

              // Balance
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: balanceBg,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "My balance: $coinBalance",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Coin Shop coming soon !")),
                        );
                      },
                      icon: const Icon(Icons.store, size: 18),
                      label: const Text("Coin Shop"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
