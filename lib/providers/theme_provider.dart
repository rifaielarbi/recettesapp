import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  // Fournit le brightness correspondant
  Brightness get brightness => _isDark ? Brightness.dark : Brightness.light;

  ThemeProvider() {
    _loadTheme();
  }

  // Charger le thème depuis SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    notifyListeners(); // Notifie uniquement après le chargement
  }

  // Basculer le thème et sauvegarder
  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }

  // Définir directement le thème
  Future<void> setDark(bool value) async {
    if (_isDark == value) return; // éviter un rebuild inutile
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}