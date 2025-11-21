import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'liste_recettes.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({super.key});

  @override
  State<LoginWithEmailScreen> createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final AuthService _auth = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer =
        TapGestureRecognizer()
          ..onTap = () => debugPrint("Conditions générales cliquées");
    _privacyRecognizer =
        TapGestureRecognizer()
          ..onTap = () => debugPrint("Politique de confidentialité cliquée");
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _saveAccount(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAccounts = prefs.getStringList('savedAccounts') ?? [];
    if (!savedAccounts.contains(email)) {
      savedAccounts.add(email);
      await prefs.setStringList('savedAccounts', savedAccounts);
    }
  }

  bool isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^\+?\d{8,15}$');
    return phoneRegex.hasMatch(input);
  }

  Future<void> loginWithPhone(String phoneNumber) async {
    String verificationIdGlobal = "";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ListeRecettesScreen()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) async {
        verificationIdGlobal = verificationId;

        String smsCode = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final _codeCtrl = TextEditingController();
            return AlertDialog(
              title: const Text("Code SMS"),
              content: TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Entrez le code reçu",
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.of(context).pop(_codeCtrl.text.trim()),
                  child: const Text("Valider", style: TextStyle(fontSize: 14)),
                ),
              ],
            );
          },
        );

        if (smsCode.isNotEmpty) {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationIdGlobal,
            smsCode: smsCode,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ListeRecettesScreen()),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final input = _emailCtrl.text.trim();

    if (input.isEmpty) {
      setState(() => _emailError = "Veuillez saisir votre email ou numéro");
      return;
    }

    if (isPhoneNumber(input)) {
      await loginWithPhone(input);
      return;
    }

    if (_pwdCtrl.text.trim().length < 8) {
      setState(() => _passwordError = "Mot de passe invalide, réessayez.");
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await _auth.login(input, _pwdCtrl.text.trim());
      if (success && mounted) {
        await _saveAccount(input);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ListeRecettesScreen()),
          (route) => false,
        );
      } else {
        setState(() => _emailError = "Identifiants incorrects");
      }
    } catch (e) {
      setState(() => _emailError = "Erreur inattendue : ${e.toString()}");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(
        () =>
            _emailError =
                "Veuillez saisir votre email pour réinitialiser le mot de passe",
      );
      return;
    }

    // Validation de l'email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$'
    );
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = "Veuillez saisir une adresse e-mail valide.");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Si un compte existe avec cet email, un e-mail de réinitialisation a été envoyé. Vérifiez votre boîte de réception.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green[900],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        String errorMessage = "Erreur lors de l'envoi de l'email.";
        if (e.code == 'user-not-found') {
          errorMessage = "Aucun compte n'est associé à cet email.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "L'adresse email n'est pas valide.";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Trop de tentatives. Veuillez réessayer plus tard.";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur inattendue : ${e.toString()}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _pwdCtrl,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Mot de passe",
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Connectez-vous",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Saisissez votre email ou numéro de téléphone pour commencer.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email ou numéro",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _emailError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    if (_passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _passwordError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: const Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                logo: const Icon(Icons.facebook, color: Colors.blue, size: 24),
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
    );
  }
}
