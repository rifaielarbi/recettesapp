import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  /// Crée un compte Firebase avec validation sécurisée
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // ----------------- Validation Email -----------------
    if (email.isEmpty) {
      setState(() => _emailError = "Veuillez saisir votre adresse e-mail.");
      return;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = "L’adresse e-mail saisie n’est pas valide.");
      return;
    }

    // ------------- Validation Mot de passe --------------
    if (password.isEmpty) {
      setState(() => _passwordError = "Veuillez saisir un mot de passe.");
      return;
    } else if (password.length < 8) {
      setState(
        () =>
            _passwordError =
                "Le mot de passe doit contenir au moins 8 caractères.",
      );
      return;
    } else if (!RegExp(r'\d').hasMatch(password)) {
      setState(
        () =>
            _passwordError =
                "Le mot de passe doit contenir au moins un chiffre.",
      );
      return;
    } else if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      setState(
        () =>
            _passwordError =
                "Le mot de passe doit contenir au moins un symbole spécial.",
      );
      return;
    }

    // --------- Validation Confirmation mot de passe -----
    if (confirmPassword.isEmpty) {
      setState(
        () => _confirmPasswordError = "Veuillez confirmer votre mot de passe.",
      );
      return;
    } else if (password != confirmPassword) {
      setState(() {
        _passwordError = "Les mots de passe ne correspondent pas.";
        _confirmPasswordError = "Les mots de passe ne correspondent pas.";
      });
      return;
    }

    // --------------- Création du compte ----------------
    setState(() => _loading = true);
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({"email": email, "createdAt": FieldValue.serverTimestamp()});

      // Navigation vers LoginScreen et SnackBar
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Compte créé avec succès !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.green[900],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Erreur lors de la création du compte";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur inattendue: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Widget champ mot de passe avec œil pour montrer/cacher
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: theme.inputDecorationTheme.filled,
        fillColor: theme.inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: theme.iconTheme.color?.withOpacity(0.7),
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              Center(
                child: Text(
                  'Créer un compte',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Center(
                child: Text(
                  'Rejoignez-nous et explorez nos fonctionnalités !',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 32),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: theme.inputDecorationTheme.filled,
                        fillColor: theme.inputDecorationTheme.fillColor,
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

                    // Mot de passe
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      obscureText: _obscurePassword,
                      toggleVisibility:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
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
                    const SizedBox(height: 16),

                    // Confirmation mot de passe
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Retaper le mot de passe',
                      obscureText: _obscureConfirmPassword,
                      toggleVisibility:
                          () => setState(
                            () =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                          ),
                    ),
                    if (_confirmPasswordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _confirmPasswordError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Bouton créer compte
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Créer un compte',
                            style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
                          ),
                        ),
                    const SizedBox(height: 16),

                    // Déjà un compte ?
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Déjà un compte ? Connectez-vous',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
