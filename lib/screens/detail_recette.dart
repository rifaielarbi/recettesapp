import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';

class DetailRecetteScreen extends StatelessWidget {
  final Recette recette;
  const DetailRecetteScreen({super.key, required this.recette});

  // Fonction pour récupérer le drapeau et le nom du pays en français
  String _flagForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'italie':
        return '🇮🇹 Italien';
      case 'mexico':
        return '🇲🇽 Mexicain';
      case 'maroc':
        return '🇲🇦 Marocain';
      case 'france':
        return '🇫🇷 Français';
      default:
        return '🌍 $country';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes Mondiales'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Image ---
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(recette.image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),

          // --- Titre recette ---
          Text(recette.titre, style: AppTextStyles.titleXL),
          const SizedBox(height: 8),

          // --- Drapeau + Nom du pays en dessous du titre ---
          Text(
            _flagForCountry(recette.pays),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // --- Carte Infos ---
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                recette.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Ingrédients ---
          Text('Ingrédients', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          ...recette.ingredients.map(
            (e) => Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Icon(Icons.circle, size: 8, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e, style: const TextStyle(fontSize: 16))),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Bouton Voir recette ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              // TODO: Action pour voir la recette complète ou vidéo
            },
            child: const Text('Voir la recette'),
          ),
        ],
      ),
    );
  }
}
