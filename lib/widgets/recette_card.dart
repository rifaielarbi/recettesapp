import 'package:flutter/material.dart';
import '../models/recette.dart';
import 'FavoritesButton.dart';
import '../utils/constants.dart';

class RecetteCard extends StatefulWidget {
  final Recette recette;
  final VoidCallback? onVoirDetails;

  const RecetteCard({super.key, required this.recette, this.onVoirDetails});

  @override
  State<RecetteCard> createState() => _RecetteCardState();
}

class _RecetteCardState extends State<RecetteCard> {
  // 🔹 Fonction pour récupérer le drapeau selon le pays
  String _flagForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'italie':
        return '🇮🇹';
      case 'mexico':
        return '🇲🇽';
      case 'maroc':
        return '🇲🇦';
      case 'france':
        return '🇫🇷';
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
              child: Image.asset(widget.recette.image, fit: BoxFit.cover),
            ),
          ),

          // Titre et informations
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre en haut
                Text(
                  widget.recette.titre,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Ligne drapeau + nom pays + bouton détails
                Row(
                  children: [
                    Text(
                      _flagForCountry(widget.recette.pays),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.recette.pays,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onVoirDetails,
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
                  child: FavoritesButton(recipeId: widget.recette.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
