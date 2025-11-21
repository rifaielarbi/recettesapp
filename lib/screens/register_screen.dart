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
    }
    
    // Validation stricte de l'email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = "L'adresse e-mail saisie n'est pas valide.");
      return;
    }
    
    // Vérifications supplémentaires
    if (email.startsWith('.') || email.startsWith('-') || email.startsWith('_')) {
      setState(() => _emailError = "L'adresse e-mail ne peut pas commencer par un point, un tiret ou un underscore.");
      return;
    }
    
    if (email.contains('..') || email.contains('--') || email.contains('__')) {
      setState(() => _emailError = "L'adresse e-mail contient des caractères consécutifs invalides.");
      return;
    }
    
    final parts = email.split('@');
    if (parts.length != 2) {
      setState(() => _emailError = "L'adresse e-mail doit contenir exactement un @.");
      return;
    }
    
    final domain = parts[1];
    if (domain.startsWith('.') || domain.endsWith('.') || domain.contains('..')) {
      setState(() => _emailError = "Le domaine de l'adresse e-mail n'est pas valide.");
      return;
    }
    
    if (domain.split('.').length < 2) {
      setState(() => _emailError = "Le domaine doit contenir au moins un point (ex: .com, .fr).");
      return;
    }


    // ------------- Validation Mot de passe --------------
    if (password.isEmpty) {
      setState(() => _passwordError = "Veuillez saisir un mot de passe.");
      return;
    } else if (password.length < 8) {
      setState(() =>
      _passwordError = "Le mot de passe doit contenir au moins 8 caractères.");
      return;
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      setState(() =>
      _passwordError = "Le mot de passe doit contenir au moins une majuscule.");
      return;
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      setState(() =>
      _passwordError = "Le mot de passe doit contenir au moins une minuscule.");
      return;
    } else if (!RegExp(r'\d').hasMatch(password)) {
      setState(() =>
      _passwordError = "Le mot de passe doit contenir au moins un chiffre.");
      return;
    } else if (!RegExp(r'[!@#\$&*~^%_+=-]').hasMatch(password)) {
      setState(() =>
      _passwordError = "Le mot de passe doit contenir au moins un symbole spécial.");
      return;
    }

// --------- Validation Confirmation mot de passe -----
    if (confirmPassword.isEmpty) {
      setState(() =>
      _confirmPasswordError = "Veuillez confirmer votre mot de passe.");
      return;
    } else if (password != confirmPassword) {
      setState(() =>
      _confirmPasswordError = "Les mots de passe ne correspondent pas.");
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
          .set({
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur inattendue: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Champ mot de passe avec œil
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
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
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Description
              const Center(
                child: Text(
                  'Rejoignez-nous et explorez nos fonctionnalités !',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Mot de passe
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      obscureText: _obscurePassword,
                      toggleVisibility: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                    ),

                    if (_passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _passwordError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Confirmation mot de passe
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Retaper le mot de passe',
                      obscureText: _obscureConfirmPassword,
                      toggleVisibility: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),

                    if (_confirmPasswordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _confirmPasswordError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
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
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: colorScheme.onPrimary),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lien retour
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Déjà un compte ? Connectez-vous',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
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
