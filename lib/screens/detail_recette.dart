import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';

class DetailRecetteScreen extends StatelessWidget {
  final Recette recette;
  const DetailRecetteScreen({super.key, required this.recette});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes Mondiales'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(recette.titre, style: AppTextStyles.titleXL),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(recette.image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recette.pays, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(children: [const Text('🇮🇹', style: TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(recette.pays)]),
                  const SizedBox(height: 12),
                  Text(recette.description, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ingrédients', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          ...recette.ingredients.map((e) => Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Icon(Icons.circle, size: 8, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e, style: const TextStyle(fontSize: 16))),
                ],
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {},
            child: const Text('Voir la recette'),
          ),
        ],
      ),
    );
  }
}


