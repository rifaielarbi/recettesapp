import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('favorite_'));
    _favoriteIds = keys
        .where((key) => prefs.getBool(key) ?? false)
        .map((key) => key.replaceFirst('favorite_', ''))
        .toSet();
    notifyListeners();
  }

  bool isFavorite(String recipeId) {
    return _favoriteIds.contains(recipeId);
  }

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

  Future<void> refresh() async {
    await _loadFavorites();
  }
}

