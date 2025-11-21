// lib/providers/my_auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class MyAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  MyAuthProvider() {
    _user = _authService.currentUser;

    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<User?> loginWithGoogle() async {
    _user = await _authService.signInWithGoogle();
    notifyListeners();
    return _user;
  }

  Future<User?> loginWithFacebook() async {
    _user = await _authService.signInWithFacebook();
    notifyListeners();
    return _user;
  }

  Future<User?> loginWithApple() async {
    _user = await _authService.signInWithApple();
    notifyListeners();
    return _user;
  }
}
