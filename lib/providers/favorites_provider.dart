import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  // IDs des recettes favorites
  final Set<String> _favoriteIds = {};

  // Getter pour récupérer les favoris
  Set<String> get favorites => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  // Charger les favoris depuis SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('favorite_'));

    _favoriteIds
      ..clear()
      ..addAll(
        keys
            .where((key) => prefs.getBool(key) ?? false)
            .map((key) => key.replaceFirst('favorite_', '')),
      );

    notifyListeners();
  }

  // Vérifier si une recette est favorite
  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  // Basculer l'état favorite d'une recette
  Future<void> toggleFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();

    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
      await prefs.setBool('favorite_$recipeId', false);
    } else {
      _favoriteIds.add(recipeId);
      await prefs.setBool('favorite_$recipeId', true);
    }

    notifyListeners();
  }

  // Recharger les favoris depuis SharedPreferences
  Future<void> refresh() async {
    await _loadFavorites();
  }
}
