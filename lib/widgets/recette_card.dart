import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';

import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';

class RecetteCard extends StatelessWidget {
  final Recette recette;
  final VoidCallback? onVoirDetails;

  const RecetteCard({super.key, required this.recette, this.onVoirDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partie image
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: recette.image.startsWith('http')
                    ? Image.network(
                  recette.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/pasta.png', // image par défaut
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  recette.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Partie texte et bouton
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recette.titre,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Emoji du pays (modifiable selon tes besoins)
                      const Text('🇮🇹', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        recette.pays,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onVoirDetails,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Voir détails'),
                      ),
                    ],
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