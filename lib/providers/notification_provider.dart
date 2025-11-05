import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  bool _enabled = true;

  bool get enabled => _enabled;

  void toggle(bool value) {
    _enabled = value;
    notifyListeners();
  }
}