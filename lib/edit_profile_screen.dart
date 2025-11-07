import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _photoUrl = '';

  fb_auth.User? _currentUser;

  void _showNiceSnack({
    required String message,
    required Color background,
    IconData icon = Icons.check_circle_rounded,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
      _name = user?.displayName ?? '';
      _email = user?.email ?? '';
      _photoUrl = user?.photoURL ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    try {
      if (_name != (_currentUser!.displayName ?? '')) {
        await _currentUser!.updateDisplayName(_name);
      }
      if (_email.isNotEmpty && _email != (_currentUser!.email ?? '')) {
        await _currentUser!.verifyBeforeUpdateEmail(_email);
        if (mounted) {
          _showNiceSnack(
            message:
                'Email de vérification envoyé. Validez pour finaliser la mise à jour.',
            background: Colors.blueGrey.shade700,
            icon: Icons.email_rounded,
          );
        }
      }
      try {
        final uid = _currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'displayName': _name,
          'email': _email,
          'photoURL': _photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
      }

      await _currentUser!.reload();
      _currentUser = fb_auth.FirebaseAuth.instance.currentUser;

      if (mounted) {
        _showNiceSnack(
          message: 'Profil mis à jour',
          background: Colors.green.shade700,
          icon: Icons.check_circle_rounded,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showNiceSnack(
          message: 'Erreur : $e',
          background: Colors.red.shade700,
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.editProfile)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Ajouter la logique pour changer la photo
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                    child: _photoUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nom
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: loc.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${loc.name} est requis';
                  }
                  return null;
                },
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: loc.email,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${loc.email} est requis';
                  }
                  if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              const SizedBox(height: 30),

              // Bouton Sauvegarder
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _saveProfile();
                  }
                },
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}