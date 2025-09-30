import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class RecettesFromJson extends StatefulWidget {
  const RecettesFromJson({super.key});

  @override
  State<RecettesFromJson> createState() => _RecettesFromJsonState();
}

class _RecettesFromJsonState extends State<RecettesFromJson> {
  List<dynamic> recipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    final jsonStr = await rootBundle.loadString('assets/data/recettes_a_to_z.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    setState(() {
      recipes = data['meals'] as List<dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recettes')),
      body: recipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe['titre'] ?? recipe['name'] ?? 'Sans titre'),
            subtitle: Text(recipe['pays'] ?? ''),
          );
        },
      ),
    );
  }
}