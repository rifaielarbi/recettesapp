import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // Charger la langue depuis SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'fr';
    if (code != _locale.languageCode) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  // Définir la langue et sauvegarder
  Future<void> setLocale(String code) async {
    if (code == _locale.languageCode) return; 
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    notifyListeners();
  }
}
