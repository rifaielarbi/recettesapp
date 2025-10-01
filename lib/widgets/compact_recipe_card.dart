import 'package:flutter/material.dart';
import '../models/recette.dart';
import 'FavoritesButton.dart';

class CompactRecipeCard extends StatelessWidget {
  final Recette recette;
  final VoidCallback? onTap;

  const CompactRecipeCard({super.key, required this.recette, this.onTap});

  String _flagForCountry(String country) {
    switch (country) {
      case 'French':
      case 'France':
        return '🇫🇷 Français';
      case 'Italian':
      case 'Italie':
        return '🇮🇹 Italien';
      case 'Maroccan':
      case 'Maroc':
        return '🇲🇦 Marocain';
      case 'British':
        return '🇬🇧 Britannique';
      case 'Malaysian':
        return '🇲🇾 Malaisien';
      case 'Indian':
        return '🇮🇳 Indien';
      case 'American':
        return '🇺🇸 Américain';
      case 'Mexican':
      case 'Mexico':
        return '🇲🇽 Mexicain';
      case 'Russian':
        return '🇷🇺 Russe';
      case 'Canadian':
        return '🇨🇦 Canadien';
      case 'Jamaican':
        return '🇯🇲 Jamaïcain';
      case 'Chinese':
        return '🇨🇳 Chinois';
      case 'Dutch':
        return '🇳🇱 Néerlandais';
      case 'Vietnamese':
        return '🇻🇳 Vietnamien';
      case 'Polish':
        return '🇵🇱 Polonais';
      case 'Irish':
        return '🇮🇪 Irlandais';
      case 'Croatian':
        return '🇭🇷 Croate';
      case 'Filipino':
        return '🇵🇭 Philippin';
      case 'Ukrainian':
        return '🇺🇦 Ukrainien';
      case 'Japanese':
        return '🇯🇵 Japonais';
      case 'Tunisian':
        return '🇹🇳 Tunisien';
      case 'Turkish':
        return '🇹🇷 Turc';
      case 'Greek':
        return '🇬🇷 Grec';
      case 'Uruguayan':
        return '🇺🇾 Uruguayen';
      case 'Egyptian':
        return '🇪🇬 Égyptien';
      case 'Portuguese':
        return '🇵🇹 Portugais';
      case 'Kenyan':
        return '🇰🇪 Kenyen';
      case 'Thai':
        return '🇹🇭 Thaïlandais';
      case 'Spanish':
        return '🇪🇸 Espagnol';
      default:
        return '🌍 $country';
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child:
                        recette.image.startsWith('http')
                            ? Image.network(
                              recette.image,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, progress) =>
                                      progress == null
                                          ? child
                                          : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                                  ),
                            )
                            : Image.asset(recette.image, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: FavoritesButton(recipeId: recette.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    _flagForCountry(recette.pays),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
