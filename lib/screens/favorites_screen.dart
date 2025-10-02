import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recette.dart';
import '../widgets/compact_recipe_card.dart';
import '../providers/favorites_provider.dart';
import 'detail_recette.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Recette> allRecipes;

  const FavoritesScreen({super.key, required this.allRecipes});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    // Filtrer les recettes favorites
    final favorites =
        allRecipes.where((r) => favoritesProvider.isFavorite(r.id)).toList();

    final int count = favorites.length;
    final String recipeLabel = count > 1 ? 'recettes' : 'recette';
    final String savedLabel = count > 1 ? 's' : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes Favoris',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count $recipeLabel sauvegardée$savedLabel',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Grille de recettes ou message vide
            Expanded(
              child:
                  favorites.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun favori pour le moment',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajoutez des recettes à vos favoris',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final r = favorites[index];
                          return CompactRecipeCard(
                            recette: r,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => DetailRecetteScreen(recette: r),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
