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

    return IconButton(
      icon: Icon(
        isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        favoritesProvider.toggleFavorite(recipeId);
      },
    );
  }
}