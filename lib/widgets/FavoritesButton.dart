import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesButton extends StatelessWidget {
  final String recipeId;

  const FavoritesButton({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(recipeId);

    return GestureDetector(
      onTap: () => favoritesProvider.toggleFavorite(recipeId),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8), // espace autour du cœur
        child: Icon(
          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isFavorite ? Colors.red : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
