import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';

class DetailRecetteScreen extends StatelessWidget {
  final Recette recette;
  const DetailRecetteScreen({super.key, required this.recette});

  String _flagForCountry(String country) {
    switch (country) {
      case 'French':
      case 'France':
        return '🇫🇷 Français';
      case 'Italian':
      case 'Italie':
        return '🇮🇹 Italien';
      case 'Moroccan':
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recettes Mondiales',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Image avec support réseau + fallback asset ---
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                recette.image.startsWith('http')
                    ? Image.network(
                      recette.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                    : Image.asset(recette.image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),

          // --- Titre ---
          Text(
            recette.titre,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          // --- Drapeau + Nom du pays ---
          Text(
            _flagForCountry(recette.pays),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // --- Description ---
          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                recette.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Ingrédients ---
          Text(
            'Ingrédients',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...recette.ingredients.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
