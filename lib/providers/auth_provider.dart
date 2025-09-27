import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Initialisation : récupère l'utilisateur courant
    _user = _authService.currentUser;

    // Écoute les changements de connexion Firebase
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  // Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // Connexion Google
  Future<User?> loginWithGoogle() async {
    _user = await _authService.signInWithGoogle();
    notifyListeners();
    return _user;
  }

  // Connexion Facebook
  Future<User?> loginWithFacebook() async {
    _user = await _authService.signInWithFacebook();
    notifyListeners();
    return _user;
  }

  // Connexion Apple
  Future<User?> loginWithApple() async {
    _user = await _authService.signInWithApple();
    notifyListeners();
    return _user;
  }
}
