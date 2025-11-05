import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _photoFile;
  String? _photoUrl;

  final ImagePicker _picker = ImagePicker();

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _nameController.text = user!.displayName ?? '';
      _emailController.text = user!.email ?? '';
      _photoUrl = user!.photoURL;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child('${user!.uid}.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Erreur upload image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? photoUrl = _photoUrl;

      if (_photoFile != null) {
        photoUrl = await _uploadImage(_photoFile!);
      }

      // Mettre à jour Firebase Auth
      await user!.updateDisplayName(_nameController.text);
      if (_emailController.text != user!.email) {
        await user!.updateEmail(_emailController.text);
      }
      if (photoUrl != null) {
        await user!.updatePhotoURL(photoUrl);
      }
      await user!.reload();


      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès !')),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'requires-recent-login'
          ? "Vous devez vous reconnecter pour changer l'email"
          : e.message ?? "Erreur inconnue";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $message")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _photoFile != null
                        ? FileImage(_photoFile!) as ImageProvider
                        : (_photoUrl != null
                        ? NetworkImage(_photoUrl!)
                        : null),
                    child: (_photoFile == null && _photoUrl == null)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email requis';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
