import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../providers/my_auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _photoController;

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  fb_auth.User? _currentUser;

  @override
  void initState() {
    super.initState();

    final providerUser =
        Provider.of<MyAuthProvider>(context, listen: false).user;

    _currentUser = providerUser ?? _auth.currentUser;

    _nameController =
        TextEditingController(text: _currentUser?.displayName ?? '');
    _emailController = TextEditingController(text: _currentUser?.email ?? '');
    _photoController =
        TextEditingController(text: _currentUser?.photoURL ?? '');
  }

  /// ---------------------- UPDATE PROFILE ----------------------
  Future<void> _updateProfile() async {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final photo = _photoController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom ne peut pas être vide.")),
      );
      return;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir un email valide.")),
      );
      return;
    }

    try {
      // Update name
      await _currentUser!.updateDisplayName(name);

      // Update photo
      if (photo.isNotEmpty) {
        await _currentUser!.updatePhotoURL(photo);
      }

      // Update email (needs recent login)
      if (email != _currentUser!.email && email.isNotEmpty) {
        await _currentUser!.verifyBeforeUpdateEmail(email);
      }

      // Refresh user immediately
      await _currentUser!.reload();
      final refreshedUser = _auth.currentUser;

      // Update provider first to notify listeners
      final authProvider =
      Provider.of<MyAuthProvider>(context, listen: false);
      authProvider.setUser(refreshedUser);

      // Update local state
      if (mounted) {
        setState(() {
          _currentUser = refreshedUser;
          _nameController.text = refreshedUser?.displayName ?? '';
          _emailController.text = refreshedUser?.email ?? '';
          _photoController.text = refreshedUser?.photoURL ?? '';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour")),
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'requires-recent-login'
          ? "Vous devez vous reconnecter pour changer l'email"
          : e.message ?? "Erreur inconnue";

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $msg")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Affichage photo
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _photoController.text.isNotEmpty
                    ? NetworkImage(_photoController.text)
                    : null,
                child: _photoController.text.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Champ Nom
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Champ Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Champ Photo URL
            TextField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: "Photo URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton Enregistrer
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}


