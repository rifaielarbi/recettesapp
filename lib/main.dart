import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/my_auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/favorites_provider.dart';
import 'utils/constants.dart';
import 'screens/liste_recettes.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/chat_screen.dart';
import 'app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const RecettesApp(),
    ),
  );
}

class RecettesApp extends StatelessWidget {
  const RecettesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final authProvider = context.watch<MyAuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recettes Mondiales',
      locale: localeProvider.locale,
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(primary: AppColors.green),
      ),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

      // 🔹 Home dynamique selon l’état de connexion
      home:
          authProvider.isLoggedIn
              ? const ListeRecettesScreen()
              : const LoginScreen(),

      // 🔹 Routes supplémentaires
      routes: {
        '/settings': (_) => const SettingsScreen(),
        '/chat': (_) => const ChatScreen(),
      },
    );
  }
}
