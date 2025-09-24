import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../models/recette.dart';
import '../utils/constants.dart';

class RecetteCard extends StatelessWidget {

import 'package:recettes_mondiales/models/recette.dart';
import 'package:recettes_mondiales/utils/constant.dart';


class RecetteCard extends StatefulWidget {
 79ee234 (first commit)
  final Recette recette;
  final VoidCallback? onVoirDetails;

  const RecetteCard({super.key, required this.recette, this.onVoirDetails});

  @override


  _RecetteCardState createState() => _RecetteCardState();
}


class _RecetteCardState extends State<RecetteCard> {
  bool isFavorite = false;

  @override
 79ee234 (first commit)
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,

                child: Image.asset(recette.image, fit: BoxFit.cover),

                child: Image.asset(widget.recette.image, fit: BoxFit.cover),
 79ee234 (first commit)
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(recette.titre, style: AppTextStyles.subtitle.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('🇮🇹', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(recette.pays, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                      const Spacer(),
                      TextButton(
                        onPressed: onVoirDetails,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Voir détails'),
                      ),
                    ],
                  ),

                  Text(
                    widget.recette.titre,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.recette.titre,
                          style: AppTextStyles.titleXL,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
                    ],
                  )
 79ee234 (first commit)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}



}
 79ee234 (first commit)
