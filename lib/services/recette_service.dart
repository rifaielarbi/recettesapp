import 'dart:convert';
import 'package:flutter/services.dart';

class Recette {
  final String id;
  final String titre;
  final String pays;
  final String image;
  final String description;
  final List<String> ingredients;

  Recette({
    required this.id,
    required this.titre,
    required this.pays,
    required this.image,
    required this.description,
    required this.ingredients,
  });

  factory Recette.fromJson(Map<String, dynamic> json) {
    return Recette(
      id: json['id'] as String,
      titre: json['titre'] as String,
      pays: json['pays'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'pays': pays,
      'image': image,
      'description': description,
      'ingredients': ingredients,
    };
  }
}

class RecetteService {
  static List<Recette> _recettes = [];
  static bool _isLoaded = false;

  static Future<List<Recette>> getRecettes() async {
    if (!_isLoaded) {
      await _loadRecettes();
    }
    return _recettes;
  }

  static Future<void> _loadRecettes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/recettes_a_to_z.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> meals = jsonData['meals'] ?? [];
      
      _recettes = meals.map((meal) {
        // Convertir le format de l'API vers notre format
        final ingredients = <String>[];
        for (int i = 1; i <= 20; i++) {
          final ingredient = meal['strIngredient$i'];
          final measure = meal['strMeasure$i'];
          if (ingredient != null && ingredient.isNotEmpty) {
            ingredients.add('$ingredient ${measure ?? ''}'.trim());
          }
        }
        
        return Recette(
          id: meal['id'] ?? '',
          titre: meal['titre'] ?? meal['strMeal'] ?? 'Recette sans nom',
          pays: meal['pays'] ?? meal['strArea'] ?? 'Inconnu',
          image: meal['image'] ?? meal['strMealThumb'] ?? 'assets/images/logo.png',
          description: meal['description'] ?? meal['strInstructions'] ?? 'Aucune description disponible',
          ingredients: ingredients,
        );
      }).toList();
      _isLoaded = true;
    } catch (e) {
      print('Erreur lors du chargement des recettes: $e');
      _recettes = [];
    }
  }

  static String getRecettesAsString() {
    if (_recettes.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('Voici les recettes disponibles dans l\'application (${_recettes.length} recettes au total):');
    buffer.writeln();
    
    // Afficher seulement les 20 premières recettes pour éviter un prompt trop long
    final recettesToShow = _recettes.take(20).toList();
    
    for (final recette in recettesToShow) {
      buffer.writeln('• ${recette.titre} (${recette.pays})');
      buffer.writeln('  Description: ${recette.description.length > 200 ? recette.description.substring(0, 200) + '...' : recette.description}');
      buffer.writeln('  Ingrédients: ${recette.ingredients.take(5).join(', ')}${recette.ingredients.length > 5 ? '...' : ''}');
      buffer.writeln();
    }
    
    if (_recettes.length > 20) {
      buffer.writeln('... et ${_recettes.length - 20} autres recettes disponibles.');
    }
    
    return buffer.toString();
  }
}
