import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../widgets/FavoritesButton.dart';
import '../utils/constants.dart';

class RecetteCard extends StatelessWidget {
  final Recette recette;
  final VoidCallback? onVoirDetails;

  const RecetteCard({super.key, required this.recette, this.onVoirDetails});

  // 🔹 Retourne le drapeau selon le pays
  String _flagForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'france':
      case 'french':
        return '🇫🇷';
      case 'italie':
      case 'italian':
        return '🇮🇹';
      case 'maroc':
      case 'maroccan':
        return '🇲🇦';
      case 'mexique':
      case 'mexican':
        return '🇲🇽';
      case 'espagne':
      case 'spanish':
        return '🇪🇸';
      default:
        return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de la recette
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                recette.image,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.white),
                      ),
                    ),
              ),
            ),
          ),

          // Titre et infos
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recette.titre,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Ligne drapeau + pays + bouton détails
                Row(
                  children: [
                    Text(
                      _flagForCountry(recette.pays),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      recette.pays,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    if (onVoirDetails != null)
                      TextButton(
                        onPressed: onVoirDetails,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Voir détails'),
                      ),
                  ],
                ),

                // Bouton favoris
                Align(
                  alignment: Alignment.centerRight,
                  child: FavoritesButton(recipeId: recette.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
