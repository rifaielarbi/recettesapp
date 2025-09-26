import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

import '../services/auth_service.dart';
import 'login_with_email_screen.dart';
import 'register_screen.dart';
import 'liste_recettes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  List<String> _savedAccounts = [];

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  final String _faceIDText = "Connectez-vous avec Face ID";

  @override
  void initState() {
    super.initState();
    _termsRecognizer =
        TapGestureRecognizer()
          ..onTap = () => debugPrint("Conditions générales cliquées");
    _privacyRecognizer =
        TapGestureRecognizer()
          ..onTap = () => debugPrint("Politique de confidentialité cliquée");

    _loadSavedAccounts();
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedAccounts = prefs.getStringList('savedAccounts') ?? [];
    });
  }

  Future<void> _saveAccount(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_savedAccounts.contains(email)) {
      _savedAccounts.add(email);
      await prefs.setStringList('savedAccounts', _savedAccounts);
      setState(() {});
    }
  }

  Future<void> _authenticateWithFaceID() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        debugPrint("Face ID non disponible");
        return;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (!availableBiometrics.contains(BiometricType.face)) {
        debugPrint("Face ID non détecté sur cet appareil");
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Connectez-vous avec Face ID',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ListeRecettesScreen()),
        );
      }
    } catch (e) {
      debugPrint("Erreur Face ID : $e");
    }
  }

  Widget _socialButton({
    required Widget logo,
    required String text,
    required VoidCallback onPressed,
    TextStyle? textStyle,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: logo,
              ),
            ),
            Center(
              child: Text(
                text,
                style: textStyle ?? const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Center(child: Text("Choisir un compte")),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ..._savedAccounts.map(
                          (email) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(
                                email,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Supprimer le compte',
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  _savedAccounts.remove(email);
                                  await prefs.setStringList(
                                    'savedAccounts',
                                    _savedAccounts,
                                  );
                                  setState(() {});
                                  setStateDialog(() {});
                                },
                              ),
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                await _saveAccount(email);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ListeRecettesScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Divider(),
                        Card(
                          color: Colors.grey[100],
                          child: ListTile(
                            leading: const Icon(Icons.add),
                            title: const Text("Ajouter un compte"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginWithEmailScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Image.asset(
                    'assets/images/logo_Aceuil.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "Bienvenue !",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Vous n'avez pas de compte ? ",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _authenticateWithFaceID,
                  child: Text(
                    _faceIDText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginWithEmailScreen(),
                        ),
                      ),
                  child: const Text(
                    "S’identifier",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _showChangeAccountDialog,
                  child: const Text(
                    "Changer de compte",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Expanded(
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        endIndent: 8,
                      ),
                    ),
                    Text(
                      "OU",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _socialButton(
                  logo: const Icon(Icons.apple, color: Colors.black, size: 24),
                  text: "Se connecter avec Apple",
                  onPressed: () async {
                    final user = await _auth.signInWithApple();
                    if (user != null) {
                      await _saveAccount(user.email ?? "");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListeRecettesScreen(),
                        ),
                      );
                    }
                  },
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _socialButton(
                  logo: Image.asset(
                    'assets/images/google_logo.png',
                    width: 24,
                    height: 24,
                  ),
                  text: "Se connecter avec Google",
                  onPressed: () async {
                    final user = await _auth.signInWithGoogle();
                    if (user != null) {
                      await _saveAccount(user.email ?? "");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListeRecettesScreen(),
                        ),
                      );
                    }
                  },
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _socialButton(
                  logo: const Icon(
                    Icons.facebook,
                    color: Colors.blue,
                    size: 24,
                  ),
                  text: "Se connecter avec Facebook",
                  onPressed: () async {
                    final user = await _auth.signInWithFacebook();
                    if (user != null) {
                      await _saveAccount(user.email ?? "");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListeRecettesScreen(),
                        ),
                      );
                    }
                  },
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      children: [
                        const TextSpan(
                          text:
                              "En cliquant sur « Continuer », vous reconnaissez avoir lu et accepté nos ",
                        ),
                        TextSpan(
                          text: "conditions générales",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        const TextSpan(text: " et notre "),
                        TextSpan(
                          text: "politique de confidentialité",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
