import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  fb_auth.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // Écoute les changements d'utilisateur
    _auth.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
        _nameController.text = user?.displayName ?? '';
        _emailController.text = user?.email ?? '';
      });
    });
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    try {
      await _currentUser!.updateDisplayName(_nameController.text);

      if (_emailController.text.isNotEmpty &&
          _emailController.text != _currentUser!.email) {
        await _currentUser!.verifyBeforeUpdateEmail(_emailController.text);
      }

      await _currentUser!.reload();
      final refreshedUser = _auth.currentUser;

      setState(() {
        _currentUser = refreshedUser;
        _nameController.text = refreshedUser?.displayName ?? '';
        _emailController.text = refreshedUser?.email ?? '';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil mis à jour")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
