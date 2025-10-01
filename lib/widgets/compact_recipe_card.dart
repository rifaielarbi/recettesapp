import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';
import 'FavoritesButton.dart';

class CompactRecipeCard extends StatelessWidget {
  final Recette recette;
  final VoidCallback? onTap;

  const CompactRecipeCard({super.key, required this.recette, this.onTap});

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.asset(recette.image, fit: BoxFit.cover),
                  ),
                ),
                // Bouton favoris en haut à droite de l'image
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: FavoritesButton(recipeId: recette.id),
                  ),
                ),
              ],
            ),
            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recette.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _flagForCountry(recette.pays),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recette.pays,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
