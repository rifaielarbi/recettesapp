import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/my_auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _photoController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<MyAuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _photoController = TextEditingController(text: user?.photoURL ?? '');
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    try {
      await user.updateDisplayName(_nameController.text);
      await user.updatePhotoURL(_photoController.text);

      if (_emailController.text.isNotEmpty && _emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
      }

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      authProvider.setUser(refreshedUser);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profil mis à jour")));
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'requires-recent-login'
          ? "Vous devez vous reconnecter pour changer l'email"
          : e.message ?? "Erreur inconnue";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $message")));
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
    final user = Provider.of<MyAuthProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
            const SizedBox(height: 16),
            TextField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: "Photo URL",
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
