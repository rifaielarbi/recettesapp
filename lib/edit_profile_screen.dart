import 'package:flutter/material.dart';
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
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              const SizedBox(height: 30),

              // Bouton Sauvegarder
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Ajouter la logique pour sauvegarder les données
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil mis à jour')),
                    );
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