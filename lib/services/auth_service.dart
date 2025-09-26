import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // -------------------
  // Inscription classique
  // -------------------
  Future<bool> register(String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("Inscription réussie pour $email");
      return true;
    } on FirebaseAuthException catch (e) {
      print("Erreur inscription: ${e.code} - ${e.message}");
      return false;
    }
  }

  // -------------------
  // Connexion email
  // -------------------
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Connexion réussie pour $email");
      return true;
    } on FirebaseAuthException catch (e) {
      print("Erreur login: ${e.code} - ${e.message}");
      return false;
    }
  }

  // -------------------
  // Déconnexion
  // -------------------
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    print("Utilisateur déconnecté");
  }

  // -------------------
  // Connexion Google
  // -------------------
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "email": userCred.user!.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Connexion Google réussie pour ${userCred.user!.email}");
      return userCred.user;
    } catch (e) {
      print("Erreur Google Sign-In: $e");
      return null;
    }
  }

  // -------------------
  // Connexion Facebook
  // -------------------
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        print("Connexion Facebook annulée ou échouée: ${result.status}");
        return null;
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString, // corrige l'erreur .token
      );

      final userCred = await _auth.signInWithCredential(credential);

      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "email": userCred.user!.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Connexion Facebook réussie pour ${userCred.user!.email}");
      return userCred.user;
    } catch (e) {
      print("Erreur Facebook Sign-In: $e");
      return null;
    }
  }

  // -------------------
  // Connexion Apple
  // -------------------
  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCred = await _auth.signInWithCredential(oauthCredential);

      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "email": userCred.user!.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Connexion Apple réussie pour ${userCred.user!.email}");
      return userCred.user;
    } catch (e) {
      print("Erreur Apple Sign-In: $e");
      return null;
    }
  }

  // -------------------
  // Utilisateur courant
  // -------------------
  User? get currentUser => _auth.currentUser;
}
