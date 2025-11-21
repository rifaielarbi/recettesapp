import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  bool _enabled = true;
  static const String _prefKey = 'notifications_enabled';

  bool get enabled => _enabled;

  NotificationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors du chargement des préférences de notification: $e");
    }
  }

  Future<void> toggle(bool value) async {
    if (_enabled == value) return; // Pas de changement
    
    _enabled = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
    } catch (e) {
      debugPrint("Erreur lors de la sauvegarde des préférences de notification: $e");
    }
  }
}