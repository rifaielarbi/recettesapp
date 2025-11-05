import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Besoin d’aide ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choisissez un sujet ou écrivez-nous directement :',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Champ pour écrire un message
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre message ici...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50],
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Envoyer
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Action d'envoi du message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message envoyé !')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Envoyer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                'Sujets fréquents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),

              // Liste de sujets
              Column(
                children: [
                  SupportCard(title: 'Problème de connexion', icon: Icons.lock),
                  SupportCard(title: 'Paiement / Facturation', icon: Icons.payment),
                  SupportCard(title: 'Suggestions de recettes', icon: Icons.restaurant_menu),
                  SupportCard(title: 'Autres questions', icon: Icons.help_outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const SupportCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Action quand on clique sur un sujet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vous avez choisi: $title')),
          );
        },
      ),
    );
  }
}
